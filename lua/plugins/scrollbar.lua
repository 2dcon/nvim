return {
  "dstein64/nvim-scrollview",
  event = { "BufReadPost", "BufNewFile" },
  config = function()
    local colors = require("tokyonight.colors").setup()
    vim.api.nvim_set_hl(0, "ScrollView", { bg = colors.bg_highlight })

    require("scrollview").setup({
      current_only = true,
      signs_on_startup = { "diagnostics", "search", "conflicts" },
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
