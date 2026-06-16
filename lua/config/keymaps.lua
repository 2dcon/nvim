local actions = require("config.keyactions")

-- 1. Unmap any old instances or default shortcuts to prevent collision
pcall(vim.keymap.del, "n", "<C-l>")
pcall(vim.keymap.del, "v", "<C-l>")
pcall(vim.keymap.del, "i", "<C-l>")
pcall(vim.keymap.del, "i", "<C-/>")
pcall(vim.keymap.del, "i", "<C-_>")
pcall(vim.keymap.del, "n", "<F2>")
pcall(vim.keymap.del, "i", "<F2>")

---- Duplicate lines
-- 1. Edit Mode (Insert Mode): Duplicate current line and put cursor at the end
vim.keymap.set('i', '<C-d>', '<Esc>yypA', { desc = "Duplicate current line" })

-- 2. View Mode (Visual Mode): Duplicate all selected lines line-wise
vim.keymap.set('v', '<C-d>', actions.duplicate_lines, { desc = "Duplicate selected lines line-wise" })
---- Duplicate lines ----

---- Delete lines
-- 1. Edit Mode (Insert Mode): Delete current line and stay in insert mode
vim.keymap.set('i', '<C-S-D>', actions.delete_current_line, { desc = "Delete current line safely" })

-- 2. View Mode (Visual Mode): Delete all selected lines
vim.keymap.set('v', '<C-S-D>', 'd', { desc = "Delete selected lines" })
---- Delete lines ----

---- Move lines
-- 1. Edit Mode (Insert Mode): Move current line up/down
vim.keymap.set('i', '<A-Up>', '<Esc><cmd>m .-2<cr>==gi', { desc = "Move line up" })
vim.keymap.set('i', '<A-Down>', '<Esc><cmd>m .+1<cr>==gi', { desc = "Move line down" })

-- 2. View Mode (Visual Mode): Move selected lines up/down
vim.keymap.set('v', '<A-Up>', ":m '<-2<cr>gv=gv", { desc = "Move selected lines up" })
vim.keymap.set('v', '<A-Down>', ":m '>+1<cr>gv=gv", { desc = "Move selected lines down" })
---- Move lines ----

-- 2. Normal Mode: Check/Open agy or copy/paste path with single cursor line
vim.keymap.set("n", "<C-l>", actions.ctrl_l_normal, { desc = "Run agy or copy relative path and line number to agy", nowait = true, silent = true })

-- 3. Visual Mode: Check/Open agy or copy/paste path with line number range
vim.keymap.set("v", "<C-l>", actions.ctrl_l_visual, { desc = "Run agy or copy relative path and line range to agy", nowait = true, silent = true })

-- 4. Insert Mode: Send current line to agy terminal
vim.keymap.set("i", "<C-l>", actions.ctrl_l_insert, { desc = "Send current line to agy", nowait = true, silent = true })

-- 5. Insert Mode: Toggle comment line
vim.keymap.set("i", "<C-/>", "<Esc>gccgi", { remap = true, silent = true, desc = "Toggle comment line" })
vim.keymap.set("i", "<C-_>", "<Esc>gccgi", { remap = true, silent = true, desc = "Toggle comment line" })

-- 5a. Visual & Select Mode: Toggle comment selection
vim.keymap.set("v", "<C-/>", "gc", { remap = true, silent = true, desc = "Toggle comment selection" })
vim.keymap.set("v", "<C-_>", "gc", { remap = true, silent = true, desc = "Toggle comment selection" })

-- 6. Normal & Insert Modes: Rename symbol (variable/function)
vim.keymap.set({ "n", "i" }, "<F2>", actions.rename_symbol, { desc = "Rename symbol", nowait = true, silent = true })

-- 6a. Git Review: Start agent changes review
vim.keymap.set("n", "<leader>gr", actions.agent_review_start, { desc = "Start Agent Review", silent = true })

-- 2. Update the keybind to call the global function
vim.keymap.set({ "n", "i", "c" }, "<F5>", function() actions.run_csharp_project(false) end, { desc = "Run C# project in Kitty pane" })
vim.keymap.set({ "n", "i", "c" }, "<F6>", function() actions.run_csharp_project(true) end, { desc = "Run C# project in Kitty tab" })

-- select mode
local modes = { "i", "n", "v" }

-- Shift + Arrows to initiate selection across all modes
vim.keymap.set("i", "<S-Up>", "<Esc>v<Up><C-g>", { desc = "Select Up" })
vim.keymap.set("i", "<S-Down>", "<Esc>v<Down><C-g>", { desc = "Select Down" })
vim.keymap.set("i", "<S-Left>", "<Esc>v<Left><C-g>", { desc = "Select Left" })
vim.keymap.set("i", "<S-Right>", "<Esc>v<Right><C-g>", { desc = "Select Right" })
vim.keymap.set("n", "<S-Up>", "v<Up><C-g>", { desc = "Select Up" })
vim.keymap.set("n", "<S-Down>", "v<Down><C-g>", { desc = "Select Down" })
vim.keymap.set("n", "<S-Left>", "v<Left><C-g>", { desc = "Select Left" })
vim.keymap.set("n", "<S-Right>", "v<Right><C-g>", { desc = "Select Right" })

-- Maintain the native selection block when holding shift inside Select Mode
vim.keymap.set("s", "<S-Left>", "<Left>")
vim.keymap.set("s", "<S-Right>", "<Right>")
vim.keymap.set("s", "<S-Up>", "<Up>")
vim.keymap.set("s", "<S-Down>", "<Down>")

-- MODERN EDITOR BEHAVIOR: Make Backspace and Delete wipe out the selection
-- and instantly return you to Insert Mode
vim.keymap.set("s", "<BS>", "<C-o>c", { desc = "Delete Selection" })
vim.keymap.set("s", "<Del>", "<C-o>c", { desc = "Delete Selection" })

-- MODERN EDITOR BEHAVIOR: Copy/Paste with Ctrl+C and Ctrl+V
vim.keymap.set("v", "<C-c>", '"+yi', { desc = "Copy selection and enter insert mode" })
vim.keymap.set("s", "<C-c>", '<C-g>"+yi', { desc = "Copy selection and enter insert mode" })
vim.keymap.set("i", "<C-v>", "<C-r><C-o>+", { desc = "Paste clipboard" })
vim.keymap.set("v", "<C-v>", '"_c<C-r><C-o>+', { desc = "Paste clipboard over selection" })
vim.keymap.set("s", "<C-v>", '<C-g>"_c<C-r><C-o>+', { desc = "Paste clipboard over selection" })

---- Undo with Ctrl+Z
vim.keymap.set("n", "<C-z>", "u", { desc = "Undo" })
vim.keymap.set("i", "<C-z>", "<C-o>u", { desc = "Undo" })
vim.keymap.set("v", "<C-z>", "<Esc>u", { desc = "Undo" })
---- Undo with Ctrl+Z ----

---- Disable Visual mode keys
vim.keymap.set("n", "v", "<nop>", { desc = "Disable Visual mode" })
vim.keymap.set("n", "V", "<nop>", { desc = "Disable Visual line mode" })
vim.keymap.set("n", "<C-v>", "<nop>", { desc = "Disable Visual block mode" })
---- Disable Visual mode keys ----

---- Close current file with Ctrl+W
vim.keymap.set({ "n", "i", "v", "s" }, "<C-w>", actions.close_current_file, { desc = "Close current file" })
---- Close current file with Ctrl+W ----



