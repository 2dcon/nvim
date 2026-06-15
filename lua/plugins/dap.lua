return {
  {
    "mfussenegger/nvim-dap",
    opts = function()
      local dap = require("dap")

      -- 1. Tell DAP where to find the netcoredbg binary installed by Mason
      dap.adapters.coreclr = {
        type = "executable",
        command = vim.fn.stdpath("data") .. "/mason/bin/netcoredbg",
        args = { "--interpreter=vscode" },
      }

      -- 2. Setup the launch configuration for C# files
      dap.configurations.cs = {
        {
          type = "coreclr",
          name = "launch - netcoredbg",
          request = "launch",
          program = function()
            return vim.fn.input("Path to dll: ", vim.fn.getcwd() .. "/bin/Debug/", "file")
          end,
        },
      }

      -- 3. Automatically break and jump on uncaught exceptions
      dap.listeners.after.event_initialized["dapui_config"] = function()
        dap.set_exception_breakpoints({ "user-unhandled" })
      end
    end,
  },
}
