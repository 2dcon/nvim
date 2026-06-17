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
        hl.SnacksIndentScope = { fg = "#9c9854" }
        -- Reversed colors for LSP references instead of underlines
        hl.LspReferenceText = { reverse = true }
        hl.LspReferenceRead = { reverse = true }
        hl.LspReferenceWrite = { reverse = true }
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
