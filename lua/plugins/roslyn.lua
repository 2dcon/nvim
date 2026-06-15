return {
  {
    "seblyng/roslyn.nvim",
    ft = { "cs", "razor" },
    dependencies = {
      "Crashdummyy/mason-registry",
    },
    config = function()
      local has_blink, blink = pcall(require, "blink.cmp")
      local capabilities = has_blink 
        and blink.get_lsp_capabilities() 
        or vim.lsp.protocol.make_client_capabilities()

      require("roslyn").setup({
        args = {
          "--logLevel=Information",
          "--extensionLogDirectory=" .. vim.fs.dirname(vim.lsp.get_log_path()),
        },
        config = {
          name = "roslyn", -- Explicitly name the server instance to satisfy _transport.lua
          on_attach = function(client, bufnr)
            -- Your LSP keymaps here
          end,
          capabilities = capabilities,
        },
      })
    end,
  },
}
