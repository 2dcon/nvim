local has_sln = #vim.fs.find(function(name) return name:match("%.sln$") end, { limit = 1, upward = true, stop = vim.env.HOME }) > 0
  or #vim.fn.glob("*.sln", true, true) > 0
  or #vim.fn.glob("*/*.sln", true, true) > 0

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
