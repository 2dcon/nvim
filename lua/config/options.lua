-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

local opt = vim.opt

opt.expandtab = false   -- Keep actual tabs, do not convert them to spaces
opt.tabstop = 4         -- Render a hard tab character as 4 columns wide
opt.shiftwidth = 4      -- Use 4 columns when indenting with codes like `>>`
opt.softtabstop = 4     -- Make Backspace/Tab handle 4 spaces at a time if encountered

-- Enter Select Mode (which allows typing to overwrite text) when selecting with mouse or shift-keys
vim.opt.selectmode = "mouse,key"


