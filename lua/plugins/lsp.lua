return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      diagnostics = {
        update_in_insert = true,
      },
      servers = {
        roslyn_ls = { enabled = false },
        copilot = {
          cmd_env = {
            XDG_CONFIG_HOME = vim.fn.stdpath("config") .. "/copilot",
          },
        },
      },
    },
  },
}
