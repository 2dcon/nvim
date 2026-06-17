-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- Automatically change Neovim's working directory if opened with a directory path
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    local arg = vim.fn.argv(0)
    if arg ~= "" and vim.fn.isdirectory(arg) == 1 then
      vim.cmd("cd " .. vim.fn.fnameescape(arg))
    end
  end,
})

-- Automatically enter Insert Mode when opening a terminal
vim.api.nvim_create_autocmd("TermOpen", {
  callback = function()
    vim.cmd("startinsert")
    -- Map LeftRelease to trigger Insert mode after click in terminal normal mode
    vim.keymap.set("n", "<LeftRelease>", "<LeftRelease>i", { buffer = true })
  end,
})

-- Automatically enter Insert Mode when focusing a terminal window
vim.api.nvim_create_autocmd({ "BufEnter", "WinEnter" }, {
  callback = function()
    if vim.bo.buftype == "terminal" then
      vim.cmd("startinsert")
    end
  end,
})

-- Automatically enter Insert Mode on mouse click for regular text files
vim.api.nvim_create_autocmd({ "BufEnter", "WinEnter" }, {
  callback = function(ev)
    vim.schedule(function()
      if vim.api.nvim_buf_is_valid(ev.buf) then
        if vim.bo[ev.buf].modifiable and vim.bo[ev.buf].buftype == "" and vim.bo[ev.buf].filetype ~= "neo-tree" and vim.bo[ev.buf].filetype ~= "Outline" then
          vim.keymap.set("n", "<LeftRelease>", "<LeftRelease>i", { buffer = ev.buf })
        end
      end
    end)
  end,
})

-- Automatically exit Insert Mode when focusing non-editor/non-terminal panes
vim.api.nvim_create_autocmd({ "BufEnter", "WinEnter" }, {
  callback = function(ev)
    vim.schedule(function()
      if vim.api.nvim_buf_is_valid(ev.buf) then
        local buftype = vim.bo[ev.buf].buftype
        local filetype = vim.bo[ev.buf].filetype
        local modifiable = vim.bo[ev.buf].modifiable
        
        local mode = vim.api.nvim_get_mode().mode
        if string.sub(mode, 1, 1) == "i" then
          local is_special = not modifiable or buftype ~= "" or filetype == "neo-tree" or filetype == "Outline"
          if is_special and buftype ~= "terminal" then
            vim.cmd("stopinsert")
          end
        end
      end
    end)
  end,
})

-- Auto-commit and push Neovim config changes when exiting Neovim
vim.api.nvim_create_autocmd("VimLeavePre", {
  group = vim.api.nvim_create_augroup("GitAutoPushConfig", { clear = true }),
  callback = function()
    local config_path = vim.fn.stdpath("config")
    local cwd = vim.fn.getcwd()

    -- Skip if current working directory is the config path (as GitAutoPushCWD will handle it)
    if vim.fn.fnamemodify(cwd, ":p") == vim.fn.fnamemodify(config_path, ":p") then
      return
    end

    local git_dir = config_path .. "/.git"

    -- Check if Neovim config is a git repository
    if vim.fn.isdirectory(git_dir) == 0 then
      return
    end

    -- Skip auto-sync if a git operation (rebase, merge, cherry-pick, revert) is in progress
    local git_ops_in_progress = vim.fn.isdirectory(git_dir .. "/rebase-merge") == 1
      or vim.fn.isdirectory(git_dir .. "/rebase-apply") == 1
      or vim.fn.filereadable(git_dir .. "/MERGE_HEAD") == 1
      or vim.fn.filereadable(git_dir .. "/CHERRY_PICK_HEAD") == 1
      or vim.fn.filereadable(git_dir .. "/REVERT_HEAD") == 1

    if git_ops_in_progress then
      return
    end

    -- Run git status to see if there are any changes (modified, untracked, deleted, etc.)
    local status = vim.fn.system("git -C " .. vim.fn.shellescape(config_path) .. " status --porcelain")
    if vim.v.shell_error ~= 0 then
      return
    end

    status = vim.trim(status)
    if status == "" then
      return -- No changes to commit/push
    end

    -- Check for unresolved conflict markers in the git status output
    for line in string.gmatch(status, "[^\r\n]+") do
      local prefix = string.sub(line, 1, 2)
      if prefix == "DD" or prefix == "AU" or prefix == "UD" or prefix == "UA" or prefix == "DU" or prefix == "AA" or prefix == "UU" then
        return
      end
    end

    -- Construct the git commit & push command
    local commit_msg = "Auto-commit: update config on exit (" .. os.date("%Y-%m-%d %H:%M:%S") .. ")"
    local log_file = config_path .. "/git-autopush.log"

    local cmd = string.format(
      "(git -C %s add -A && git -C %s commit -m %s && GIT_TERMINAL_PROMPT=0 git -C %s push) > %s 2>&1",
      vim.fn.shellescape(config_path),
      vim.fn.shellescape(config_path),
      vim.fn.shellescape(commit_msg),
      vim.fn.shellescape(config_path),
      vim.fn.shellescape(log_file)
    )

    -- Run the commands as a detached job (run-and-forget).
    -- This starts the processes in the background and allows Neovim to close instantly.
    vim.fn.jobstart({ "sh", "-c", cmd }, { detach = true })
  end,
})

-- Auto-commit and push the current working directory if it's a git repo
vim.api.nvim_create_autocmd("VimLeavePre", {
  group = vim.api.nvim_create_augroup("GitAutoPushCWD", { clear = true }),
  callback = function()
    local cwd = vim.fn.getcwd()

    -- Check if CWD is inside a git repository
    local is_git = vim.fn.system("git -C " .. vim.fn.shellescape(cwd) .. " rev-parse --is-inside-work-tree")
    if vim.v.shell_error ~= 0 or vim.trim(is_git) ~= "true" then
      return
    end

    -- Get absolute git directory path to check for active operations
    local git_dir = vim.fn.system("git -C " .. vim.fn.shellescape(cwd) .. " rev-parse --absolute-git-dir")
    if vim.v.shell_error ~= 0 then
      return
    end
    git_dir = vim.trim(git_dir)

    -- Skip auto-sync if a git operation (rebase, merge, cherry-pick, revert) is in progress
    local git_ops_in_progress = vim.fn.isdirectory(git_dir .. "/rebase-merge") == 1
      or vim.fn.isdirectory(git_dir .. "/rebase-apply") == 1
      or vim.fn.filereadable(git_dir .. "/MERGE_HEAD") == 1
      or vim.fn.filereadable(git_dir .. "/CHERRY_PICK_HEAD") == 1
      or vim.fn.filereadable(git_dir .. "/REVERT_HEAD") == 1

    if git_ops_in_progress then
      return
    end

    -- Run git status to see if there are any changes
    local status = vim.fn.system("git -C " .. vim.fn.shellescape(cwd) .. " status --porcelain")
    if vim.v.shell_error ~= 0 then
      return
    end

    status = vim.trim(status)
    if status == "" then
      return -- No changes to commit/push
    end

    -- Check for unresolved conflict markers in the git status output
    for line in string.gmatch(status, "[^\r\n]+") do
      local prefix = string.sub(line, 1, 2)
      if prefix == "DD" or prefix == "AU" or prefix == "UD" or prefix == "UA" or prefix == "DU" or prefix == "AA" or prefix == "UU" then
        return
      end
    end

    -- Construct the git commit & push command
    -- Message format: Backup@YY/MM/DD-HH:MM
    local commit_msg = os.date("Backup@%y/%m/%d-%H:%M")
    local log_file = cwd .. "/git-autopush.log"

    local cmd = string.format(
      "(git -C %s add -A && git -C %s commit -m %s && GIT_TERMINAL_PROMPT=0 git -C %s push) > %s 2>&1",
      vim.fn.shellescape(cwd),
      vim.fn.shellescape(cwd),
      vim.fn.shellescape(commit_msg),
      vim.fn.shellescape(cwd),
      vim.fn.shellescape(log_file)
    )

    -- Run the commands as a detached job (run-and-forget)
    vim.fn.jobstart({ "sh", "-c", cmd }, { detach = true })
  end,
})

-- Automatically open Outline when opening a directory (folder)
local function open_outline_if_dir()
  local buf_name = vim.api.nvim_buf_get_name(0)
  if buf_name ~= "" and vim.fn.isdirectory(buf_name) == 1 then
    vim.schedule(function()
      require("lazy").load({ plugins = { "outline.nvim" } })
      pcall(vim.cmd, "OutlineOpen!")
    end)
  end
end

-- Run immediately when autocmds.lua loads (covers startup with a directory)
open_outline_if_dir()

-- Also watch for subsequent directory buffer entries
vim.api.nvim_create_autocmd("BufEnter", {
  group = vim.api.nvim_create_augroup("OutlineAutoOpen", { clear = true }),
  callback = open_outline_if_dir,
})

-- Automatically check for git changes on FocusGained to trigger agent review
vim.api.nvim_create_autocmd("FocusGained", {
  group = vim.api.nvim_create_augroup("AgentReviewTrigger", { clear = true }),
  callback = function()
    pcall(function()
      require("config.keyactions").agent_review_check_git()
    end)
  end,
})

-- Option C: Completely hide/show terminal cursor globally in Normal mode (lightweight version)
local term_cursor_group = vim.api.nvim_create_augroup("TerminalCursorHide", { clear = true })

local function hide_cursor()
  if vim.api.nvim_get_mode().mode == "n" then
    io.write("\27[?25l")
  end
end

-- Hide on mode entry
vim.api.nvim_create_autocmd("ModeChanged", {
  group = term_cursor_group,
  pattern = "*:n",
  callback = hide_cursor,
})

-- Show on mode exit
vim.api.nvim_create_autocmd("ModeChanged", {
  group = term_cursor_group,
  pattern = "n:*",
  callback = function()
    io.write("\27[?25h")
  end,
})

-- Ensure cursor is restored when leaving or suspending Neovim
vim.api.nvim_create_autocmd({ "VimLeave", "VimSuspend" }, {
  group = term_cursor_group,
  callback = function()
    io.write("\27[?25h")
  end,
})

-- Hide cursor immediately on load if starting in Normal mode
hide_cursor()

-- Map double-click in Outline buffer to go to symbol position (CR)
vim.api.nvim_create_autocmd("FileType", {
  pattern = "Outline",
  callback = function()
    -- Jump to symbol on double-click (covers all modes)
    vim.keymap.set({ "n", "v", "s", "x" }, "<2-LeftMouse>", function()
      local pos = vim.fn.getmousepos()
      if pos.winid == vim.api.nvim_get_current_win() and pos.line > 0 then
        vim.api.nvim_win_set_cursor(0, { pos.line, 0 })
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<CR>", true, false, true), "m", true)
      end
    end, { buffer = true, silent = true, desc = "Jump to symbol on double-click" })
    
    -- Disable drag-selection across modes to prevent visual jumping glitches
    vim.keymap.set({ "n", "v", "s", "x" }, "<LeftDrag>", "<Nop>", { buffer = true, silent = true })

    -- Update outline highlights and snap cursor to column 0 on cursor move (fixes highlight and shift bugs)
    vim.api.nvim_create_autocmd("CursorMoved", {
      buffer = 0,
      callback = function()
        vim.schedule(function()
          pcall(function()
            require("outline").follow_cursor({ focus_outline = false })
          end)
        end)
      end,
    })
  end,
})









