return {
  -- Configure Tokyonight with the "night" style
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    opts = {
      style = "night", -- Set style to "night" (much darker than storm)
      transparent = false,
      styles = {
        sidebars = "dark",
        floats = "dark",
      },
      on_highlights = function(hl, c)
        -- Dim the active scope vertical line to a subtle dark slate blue
        hl.SnacksIndentScope = { fg = "#3d59a1" }
      end,
    },
  },

  -- Set active colorscheme to tokyonight-night
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "tokyonight-night",
    },
  },
}
