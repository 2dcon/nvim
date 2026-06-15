return {
  {
    "nvim-neo-tree/neo-tree.nvim",
    opts = {
      filesystem = {
        filtered_items = {
          visible = true, -- Show hidden files/folders by default (dimmed)
          hide_dotfiles = false,
          hide_gitignored = false,
          never_show = {
            ".git", -- Still hide the raw .git directory to keep clean, or keep it visible if preferred
          },
        },
      },
    },
  },
}
