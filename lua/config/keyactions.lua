local M = {}

-- Helper function to fetch the relative file path safely
local function get_relative_path()
  local path = vim.fn.expand("%:.")
  if path == "" then
    vim.notify("No file path found for the current buffer", vim.log.levels.WARN)
    return nil
  end
  return path
end

-- Helper to list all active Kitty sockets
local function get_kitty_sockets()
  local listen_on = vim.env.KITTY_LISTEN_ON
  if not listen_on or listen_on == "" then
    local sockets = {}
    local f = io.open("/proc/net/unix", "r")
    if f then
      for line in f:lines() do
        local socket = line:match("(@mykitty%-%d+)")
        if socket then
          table.insert(sockets, "unix:" .. socket)
        end
      end
      f:close()
    end
    return sockets
  end

  local socket_path = listen_on:gsub("^unix:", "")
  local prefix = socket_path:match("^([^%-]+)")
  if not prefix or prefix == "" then
    return { listen_on }
  end

  local escaped_prefix = prefix:gsub("([^%w])", "%%%1")
  local pattern = "(" .. escaped_prefix .. "%-%d+)"

  local sockets = {}
  local f = io.open("/proc/net/unix", "r")
  if f then
    for line in f:lines() do
      local socket = line:match(pattern)
      if socket then
        table.insert(sockets, "unix:" .. socket)
      end
    end
    f:close()
  end

  local found_current = false
  for _, s in ipairs(sockets) do
    if s == listen_on then
      found_current = true
      break
    end
  end
  if not found_current then
    table.insert(sockets, listen_on)
  end

  return sockets
end

-- Helper to get a socket we can use to run general commands (like launch)
local function get_command_socket()
  local listen_on = vim.env.KITTY_LISTEN_ON
  if listen_on and listen_on ~= "" then
    return listen_on
  end
  local sockets = get_kitty_sockets()
  if sockets and #sockets > 0 then
    return sockets[1]
  end
  return nil
end

-- Helper to run a kitty remote control command on a specific socket
local function run_kitty_command(socket, args)
  local cmd = string.format("kitty @ --to=%s %s", vim.fn.shellescape(socket), args)
  return vim.fn.system(cmd)
end

-- Helper to check if a window is running agy
local function is_agy_window(win)
  if win.foreground_processes then
    for _, proc in ipairs(win.foreground_processes) do
      if proc.cmdline and proc.cmdline[1] then
        local exe = proc.cmdline[1]
        if exe == "agy" or exe:match("/agy$") then
          return true
        end
      end
    end
  end
  if win.last_reported_cmdline == "agy" or (win.last_reported_cmdline and win.last_reported_cmdline:match("/agy$")) then
    return true
  end
  if win.title and win.title:match("agy") then
    return true
  end
  return false
end

-- Helper to check if two paths match, ignoring trailing slashes
local function paths_match(p1, p2)
  if not p1 or not p2 then return false end
  local n1 = p1:gsub("/+$", "")
  local n2 = p2:gsub("/+$", "")
  return n1 == n2
end

-- Find any kitty window running agy across all active sockets
-- If nvim_cwd is provided, prioritizes a window whose cwd matches nvim_cwd.
local function find_agy_kitty_window(nvim_cwd)
  local sockets = get_kitty_sockets()
  local first_fallback_socket, first_fallback_win_id, first_fallback_cwd = nil, nil, nil

  for _, socket in ipairs(sockets) do
    local ok, output = pcall(run_kitty_command, socket, "ls")
    if ok and output and output ~= "" then
      local ok_decode, data = pcall(vim.json.decode, output)
      if ok_decode and data then
        for _, os_win in ipairs(data) do
          if os_win.tabs then
            for _, tab in ipairs(os_win.tabs) do
              if tab.windows then
                for _, win in ipairs(tab.windows) do
                  if is_agy_window(win) then
                    if nvim_cwd and paths_match(win.cwd, nvim_cwd) then
                      return socket, win.id, win.cwd
                    end
                    if not first_fallback_socket then
                      first_fallback_socket = socket
                      first_fallback_win_id = win.id
                      first_fallback_cwd = win.cwd
                    end
                  end
                end
              end
            end
          end
        end
      end
    end
  end
  return first_fallback_socket, first_fallback_win_id, first_fallback_cwd
end

-- Send text to a specific kitty window on a specific socket
local function send_text_to_kitty_window(socket, win_id, text)
  local to_arg = (socket and socket ~= "") and string.format("--to=%s ", vim.fn.shellescape(socket)) or ""
  local cmd = string.format("echo -n %s | kitty @ %ssend-text --match id:%d --stdin", vim.fn.shellescape(text), to_arg, win_id)
  vim.fn.system(cmd)
end

-- Focus a specific kitty window on a specific socket
local function focus_kitty_window(socket, win_id)
  local to_arg = (socket and socket ~= "") and string.format("--to=%s ", vim.fn.shellescape(socket)) or ""
  local cmd = string.format("kitty @ %sfocus-window --match id:%d", to_arg, win_id)
  vim.fn.system(cmd)
end

-- Launch agy in a new OS window with specified working directory
local function launch_agy_kitty_window(cwd)
  local socket = get_command_socket()
  local folder_name = vim.fs.basename(cwd)
  local cmd
  if socket then
    cmd = string.format(
      "kitty @ --to=%s launch --type=os-window --cwd=%s --tab-title=%s agy",
      vim.fn.shellescape(socket),
      vim.fn.shellescape(cwd),
      vim.fn.shellescape(folder_name)
    )
  else
    cmd = string.format(
      "kitty @ launch --type=os-window --cwd=%s --tab-title=%s agy",
      vim.fn.shellescape(cwd),
      vim.fn.shellescape(folder_name)
    )
  end
  local output = vim.fn.system(cmd)
  local clean_output = output:gsub("%s+", "")
  local new_win_id = tonumber(clean_output)
  return socket, new_win_id
end

-- Launch agy in a new tab in the OS window containing the matched window
local function launch_agy_kitty_tab(socket, match_win_id, cwd)
  local folder_name = vim.fs.basename(cwd)
  local cmd = string.format(
    "kitty @ --to=%s launch --type=tab --match=window_id:%d --cwd=%s --tab-title=%s agy",
    vim.fn.shellescape(socket),
    match_win_id,
    vim.fn.shellescape(cwd),
    vim.fn.shellescape(folder_name)
  )
  local output = vim.fn.system(cmd)
  local clean_output = output:gsub("%s+", "")
  local new_win_id = tonumber(clean_output)
  return new_win_id
end

-- Get existing agy window or create a new tab if working directory doesn't match
local function get_or_create_agy_window(nvim_cwd)
  local kitty_socket, kitty_win_id, win_cwd = find_agy_kitty_window(nvim_cwd)
  if kitty_socket and kitty_win_id then
    if not paths_match(win_cwd, nvim_cwd) then
      local new_win_id = launch_agy_kitty_tab(kitty_socket, kitty_win_id, nvim_cwd)
      if new_win_id then
        return kitty_socket, new_win_id, true
      end
    end
    return kitty_socket, kitty_win_id, false
  end
  return nil, nil, false
end

-- Handle the ctrl+l action: check for agy terminal, open one if missing, or paste if present
local function handle_ctrl_l(text)
  local nvim_cwd = vim.fn.getcwd()
  local kitty_socket, kitty_win_id, is_new_tab = get_or_create_agy_window(nvim_cwd)

  if kitty_socket and kitty_win_id then
    if is_new_tab then
      vim.notify("Sent to agy: " .. text .. " (Opened new agy tab)", vim.log.levels.INFO)
      vim.defer_fn(function()
        send_text_to_kitty_window(kitty_socket, kitty_win_id, text)
        focus_kitty_window(kitty_socket, kitty_win_id)
      end, 150)
    else
      vim.notify("Sent to agy: " .. text, vim.log.levels.INFO)
      send_text_to_kitty_window(kitty_socket, kitty_win_id, text)
      focus_kitty_window(kitty_socket, kitty_win_id)
    end
    return
  end

  -- Fallback: Create a new OS window
  local current_file = vim.api.nvim_buf_get_name(0)
  local cwd
  if current_file and current_file ~= "" then
    cwd = vim.fs.dirname(current_file)
  else
    cwd = nvim_cwd
  end

  vim.notify("Sent to agy: " .. text .. " (Opening new agy window)", vim.log.levels.INFO)
  local socket, new_win_id = launch_agy_kitty_window(cwd)
  if new_win_id then
    vim.defer_fn(function()
      send_text_to_kitty_window(socket, new_win_id, text)
      focus_kitty_window(socket, new_win_id)
    end, 300)
  end
end

function M.duplicate_lines()
  -- Get the start and end lines of the current selection
  local start_line = vim.fn.line("v")
  local end_line = vim.fn.line(".")

  -- If the user selected upwards, swap the lines to keep order correct
  if start_line > end_line then
    start_line, end_line = end_line, start_line
  end

  -- Grab the full content of those lines (handling partial selections automatically)
  local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)

  -- Paste the cloned lines directly below the selection block
  vim.api.nvim_buf_set_lines(0, end_line, end_line, false, lines)

  -- Exit the old visual mode selection cleanly
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", true)

  -- Schedule the cursor to move and re-select the newly created block (IDE style)
  vim.schedule(function()
    vim.api.nvim_win_set_cursor(0, { end_line + 1, 0 })
    if #lines > 1 then
      vim.cmd("normal! V" .. (#lines - 1) .. "j")
    else
      vim.cmd("normal! V")
    end
  end)
end

function M.delete_current_line()
  vim.cmd('delete')
  vim.cmd('redraw')
end

function M.ctrl_l_normal()
  if vim.bo.filetype == "neo-tree" then
    local source = vim.b.neo_tree_source or "filesystem"
    local success, manager = pcall(require, "neo-tree.sources.manager")
    if success and manager then
      local state = manager.get_state(source)
      if state and state.tree then
        local node = state.tree:get_node()
        if node then
          local path = node:get_id()
          if path and path ~= "" then
            local relative_path = vim.fn.fnamemodify(path, ":.")
            handle_ctrl_l(relative_path .. " ")
            return
          end
        end
      end
    end
  end

  local nvim_cwd = vim.fn.getcwd()
  local kitty_socket, kitty_win_id, is_new_tab = get_or_create_agy_window(nvim_cwd)

  if kitty_socket and kitty_win_id then
    if is_new_tab then
      vim.defer_fn(function()
        focus_kitty_window(kitty_socket, kitty_win_id)
      end, 150)
    else
      focus_kitty_window(kitty_socket, kitty_win_id)
    end
  else
    local current_file = vim.api.nvim_buf_get_name(0)
    local cwd
    if current_file and current_file ~= "" then
      cwd = vim.fs.dirname(current_file)
    else
      cwd = nvim_cwd
    end
    launch_agy_kitty_window(cwd)
  end
end

function M.ctrl_l_visual()
  local relative_path = get_relative_path()
  if not relative_path then return end

  -- Get the bounds of the visual selection
  local start_line = vim.fn.line("v")
  local end_line = vim.fn.line(".")

  -- Sort them in case the selection was made bottom-to-top
  if start_line > end_line then
    start_line, end_line = end_line, start_line
  end

  local result
  if start_line == end_line then
    result = string.format("%s:%d", relative_path, start_line)
  else
    result = string.format("%s:%d-%d", relative_path, start_line, end_line)
  end

  -- Clean exit out of visual mode back to normal mode
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", false)

  -- Schedule the handler to run after escaping visual mode
  vim.schedule(function()
    handle_ctrl_l(result .. " ")
  end)
end

function M.ctrl_l_insert()
  local line = vim.api.nvim_get_current_line()
  handle_ctrl_l(line .. "\n")
end

local function get_free_port()
  local uv = vim.uv or vim.loop
  local server = uv.new_tcp()
  uv.tcp_bind(server, "127.0.0.1", 0)
  local port = uv.tcp_getsockname(server).port
  uv.close(server)
  return port
end

-- Hook nvim-dap output events to write to the session's temp_file
local dap_ok, dap = pcall(require, "dap")
if dap_ok then
  dap.listeners.after.event_output['kitty-output'] = function(session, body)
    local temp_file = session.config.temp_file
    if temp_file then
      pcall(function()
        local f = io.open(temp_file, "a")
        if f then
          f:write(body.output)
          f:close()
        end
      end)
    end
  end
end

function M.run_csharp_project()
  vim.cmd("silent! wa")
  local current_file = vim.api.nvim_buf_get_name(0)
  
  if current_file == "" then
    vim.notify("No active file", vim.log.levels.WARN)
    return
  end

  local dir = vim.fs.dirname(current_file)
  local csproj_path = nil

  for i = 1, 4 do
    local ok, files = pcall(vim.fn.readdir, dir)
    if ok then
      for _, file in ipairs(files) do
        if file:match("%.csproj$") then
          csproj_path = dir .. "/" .. file
          break
        end
      end
    end
    if csproj_path then
      break
    end
    local parent = vim.fs.dirname(dir)
    if parent == dir then
      break
    end
    dir = parent
  end

  if not csproj_path then
    vim.notify("No csproj found after 4 iterations!", vim.log.levels.WARN)
    return
  end

  local csproj_dir = vim.fs.dirname(csproj_path)
  local project_name = vim.fs.basename(csproj_path):gsub("%.csproj$", "")

  -- 1. Build the project
  vim.notify("Building C# project: " .. project_name, vim.log.levels.INFO)
  local build_cmd = string.format("dotnet build %s", vim.fn.shellescape(csproj_path))
  local build_out = vim.fn.system(build_cmd)
  if vim.v.shell_error ~= 0 then
    vim.notify("Build failed:\n" .. build_out, vim.log.levels.ERROR)
    return
  end

  -- 2. Locate the compiled DLL
  local pattern = csproj_dir .. "/bin/Debug/**/" .. project_name .. ".dll"
  local matches = vim.fn.glob(pattern, true, true)
  if #matches == 0 then
    vim.notify("Could not find compiled DLL matching " .. project_name .. ".dll", vim.log.levels.ERROR)
    return
  end
  table.sort(matches, function(a, b)
    return vim.fn.getftime(a) > vim.fn.getftime(b)
  end)
  local dll_path = matches[1]

  -- 3. Get a free port for netcoredbg server
  local port = get_free_port()
  local netcoredbg_path = vim.fn.stdpath("data") .. "/mason/bin/netcoredbg"

  -- Create a temporary file to pipe output to the Kitty tab
  local temp_file = os.tmpname()
  local f_init = io.open(temp_file, "w")
  if f_init then
    f_init:write("")
    f_init:close()
  end

  -- 4. Launch netcoredbg in a new Kitty tab and tail the temp file
  local listen_on = vim.env.KITTY_LISTEN_ON
  local shell_cmd = string.format(
    "touch %s && tail -n +1 -f %s & TAIL_PID=$!; %s --server=%d --interpreter=vscode; kill $TAIL_PID; rm %s; echo; echo 'Debugger session finished. Press any key to close...'; read -n 1 -s",
    vim.fn.shellescape(temp_file),
    vim.fn.shellescape(temp_file),
    vim.fn.shellescape(netcoredbg_path),
    port,
    vim.fn.shellescape(temp_file)
  )
  local cmd
  if listen_on and listen_on ~= "" then
    cmd = string.format(
      "kitty @ --to=%s launch --type=tab --cwd=%s bash -c %s 2>&1",
      vim.fn.shellescape(listen_on),
      vim.fn.shellescape(csproj_dir),
      vim.fn.shellescape(shell_cmd)
    )
  else
    vim.notify("KITTY_LISTEN_ON environment variable is not set. Please restart your Kitty terminal to apply the remote control socket configuration.", vim.log.levels.WARN)
    cmd = string.format(
      "kitty @ launch --type=tab --cwd=%s bash -c %s 2>&1",
      vim.fn.shellescape(csproj_dir),
      vim.fn.shellescape(shell_cmd)
    )
  end
  
  local output = vim.fn.system(cmd)
  if vim.v.shell_error ~= 0 then
    vim.notify("Kitty execution failed: " .. output, vim.log.levels.ERROR)
    os.remove(temp_file)
    return
  end

  -- 5. Start DAP session connecting to the launched netcoredbg server
  vim.defer_fn(function()
    local dap_session = require("dap")
    dap_session.adapters.coreclr_kitty = {
      type = "server",
      host = "127.0.0.1",
      port = port,
    }
    
    dap_session.run({
      type = "coreclr_kitty",
      name = "launch - netcoredbg (Kitty)",
      request = "launch",
      program = dll_path,
      cwd = csproj_dir,
      temp_file = temp_file, -- Store it on configuration so listener can access it
    })
  end, 200)
end

return M

