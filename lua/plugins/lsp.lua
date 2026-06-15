return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      diagnostics = {
        update_in_insert = true,
      },
      servers = {
        roslyn_ls = { enabled = false },
      },
    },
  },
}
