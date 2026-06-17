return {
  {
    "nvim-neo-tree/neo-tree.nvim",
    opts = {
      window = {
        mappings = {
          ["<LeftMouse>"] = "open",
          ["Y"] = function(state)
            local node = state.tree:get_node()
            local filepath = node:get_id()
            local filename = node.name
            local modify = vim.fn.fnamemodify
            
            local results = {
              filepath,                     -- Absolute path
              modify(filepath, ":."),      -- Relative to CWD
              filename                     -- Filename only
            }

            vim.ui.select({
              "1. Absolute path: " .. results[1],
              "2. Path relative to CWD: " .. results[2],
              "3. Filename: " .. results[3],
            }, {
              prompt = "Choose to copy to clipboard:",
            }, function(choice)
              if choice then
                local idx = tonumber(choice:sub(1, 1))
                if idx and results[idx] then
                  vim.fn.setreg("+", results[idx])
                  vim.notify("Copied: " .. results[idx])
                end
              end
            end)
          end,
        },
      },
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
