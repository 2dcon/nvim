return {
  "petertriho/nvim-scrollbar",
  event = { "BufReadPost", "BufNewFile" },
  config = function()
    local scrollbar = require("scrollbar")
    local colors = require("tokyonight.colors").setup()
    scrollbar.setup({
      show = true,
      handle = {
        text = " ",
        blend = 30,
        color = colors.bg_highlight,
      },
      marks = {
        Search = { color = colors.orange, priority = 0 },
        Error = { color = colors.error, priority = 1 },
        Warn = { color = colors.warning, priority = 2 },
        Info = { color = colors.info, priority = 3 },
        Hint = { color = colors.hint, priority = 4 },
        Misc = { color = colors.dark3, priority = 5 },
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
