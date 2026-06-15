local function get_opened_dir()
  local arg = vim.fn.argv(0)
  if type(arg) == "string" and arg ~= "" then
    local path = vim.fn.fnamemodify(arg, ":p")
    if vim.fn.isdirectory(path) == 1 then
      return path
    else
      return vim.fs.dirname(path)
    end
  end
  return vim.fn.getcwd()
end

local function get_solution_dir(target_dir)
  -- 1. Check upward for a .sln file
  local upward_sln = vim.fs.find(function(name) return name:match("%.sln$") end, { limit = 1, upward = true, path = target_dir, stop = vim.env.HOME })
  if #upward_sln > 0 then
    return vim.fs.dirname(upward_sln[1])
  end

  -- 2. Check current directory for a .sln file
  local local_sln = vim.fn.glob(target_dir .. "/*.sln", true, true)
  if #local_sln > 0 then
    return target_dir
  end

  -- 3. Check one level down for a .sln file
  local sub_sln = vim.fn.glob(target_dir .. "/*/*.sln", true, true)
  if #sub_sln > 0 then
    return vim.fs.dirname(sub_sln[1])
  end

  return nil
end

local target_dir = get_opened_dir():gsub("/+$", "")
local solution_dir = get_solution_dir(target_dir)
local has_sln = solution_dir ~= nil

return {
  {
    "seblyng/roslyn.nvim",
    ft = { "cs", "razor" },
    lazy = not has_sln,
    dependencies = {
      "Crashdummyy/mason-registry",
    },
    config = function()
      local has_blink, blink = pcall(require, "blink.cmp")
      local capabilities = has_blink 
        and blink.get_lsp_capabilities() 
        or vim.lsp.protocol.make_client_capabilities()

      local user_config = {
        args = {
          "--logLevel=Information",
          "--extensionLogDirectory=" .. vim.fs.dirname(vim.lsp.get_log_path()),
        },
        config = {
          name = "roslyn", -- Explicitly name the server instance to satisfy _transport.lua
          on_init = function(client)
            if type(client.config.root_dir) == "function" then
              client.config.root_dir = client.root_dir
            end
          end,
          on_attach = function(client, bufnr)
            -- Your LSP keymaps here
          end,
          capabilities = capabilities,
        },
      }

      require("roslyn").setup(user_config)
      vim.lsp.config("roslyn", user_config.config)

      -- If we are in a C# solution, start the LSP immediately on the current startup buffer
      if has_sln then
        vim.schedule(function()
          local config = vim.lsp.config["roslyn"]
          if config then
            local bufnr = vim.api.nvim_get_current_buf()
            local start_config = vim.tbl_extend("force", config, { root_dir = solution_dir })
            vim.lsp.start(start_config, { bufnr = bufnr })
          end
        end)
      end
    end,
  },
}
