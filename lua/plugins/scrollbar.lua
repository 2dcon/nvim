return {
  "petertriho/nvim-scrollbar",
  event = { "BufReadPost", "BufNewFile" },
  config = function()
    local scrollbar = require("scrollbar")
    scrollbar.setup({
      show = true,
      handle = {
        text = " ",
        blend = 30,
        color = nil,
        color_nr = nil,
        highlight = "CursorColumn",
      },
      marks = {
        Search = { text = { "-", "=" }, priority = 0, highlight = "Search" },
        Error = { text = { " ", " " }, priority = 1, highlight = "DiagnosticSignError" },
        Warn = { text = { " ", " " }, priority = 2, highlight = "DiagnosticSignWarn" },
        Info = { text = { " ", " " }, priority = 3, highlight = "DiagnosticSignInfo" },
        Hint = { text = { " ", " " }, priority = 4, highlight = "DiagnosticSignHint" },
        Misc = { text = { " ", " " }, priority = 5, highlight = "Normal" },
      },
      excluded_filetypes = {
        "cmp_menu",
        "cmp_docs",
        "Notify",
        "noice",
        "prompt",
        "TelescopePrompt",
        "neo-tree",
      },
    })
  end,
}
