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
