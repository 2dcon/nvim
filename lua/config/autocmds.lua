-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- Automatically change Neovim's working directory if opened with a directory path
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    local arg = vim.fn.argv(0)
    if arg ~= "" and vim.fn.isdirectory(arg) == 1 then
      vim.cmd("cd " .. vim.fn.fnameescape(arg))
    end
  end,
})

-- Automatically enter Insert Mode when opening a terminal
vim.api.nvim_create_autocmd("TermOpen", {
  callback = function()
    vim.cmd("startinsert")
    -- Map LeftRelease to trigger Insert mode after click in terminal normal mode
    vim.keymap.set("n", "<LeftRelease>", "<LeftRelease>i", { buffer = true })
  end,
})

-- Automatically enter Insert Mode when focusing a terminal window
vim.api.nvim_create_autocmd({ "BufEnter", "WinEnter" }, {
  callback = function()
    if vim.bo.buftype == "terminal" then
      vim.cmd("startinsert")
    end
  end,
})

-- Automatically enter Insert Mode on mouse click for regular text files
vim.api.nvim_create_autocmd({ "BufEnter", "WinEnter" }, {
  callback = function()
    if vim.bo.modifiable and vim.bo.buftype == "" then
      vim.keymap.set("n", "<LeftRelease>", "<LeftRelease>i", { buffer = true })
    end
  end,
})



