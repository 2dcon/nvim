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

-- Auto-commit and push Neovim config changes when exiting Neovim
vim.api.nvim_create_autocmd("VimLeavePre", {
  group = vim.api.nvim_create_augroup("GitAutoPushConfig", { clear = true }),
  callback = function()
    local config_path = vim.fn.stdpath("config")
    local git_dir = config_path .. "/.git"

    -- Check if Neovim config is a git repository
    if vim.fn.isdirectory(git_dir) == 0 then
      return
    end

    -- Skip auto-sync if a git operation (rebase, merge, cherry-pick, revert) is in progress
    local git_ops_in_progress = vim.fn.isdirectory(git_dir .. "/rebase-merge") == 1
      or vim.fn.isdirectory(git_dir .. "/rebase-apply") == 1
      or vim.fn.filereadable(git_dir .. "/MERGE_HEAD") == 1
      or vim.fn.filereadable(git_dir .. "/CHERRY_PICK_HEAD") == 1
      or vim.fn.filereadable(git_dir .. "/REVERT_HEAD") == 1

    if git_ops_in_progress then
      print("\n[GitAutoPush] Git operation in progress. Skipping auto-sync on exit.")
      return
    end

    -- Run git status to see if there are any changes (modified, untracked, deleted, etc.)
    local status = vim.fn.system("git -C " .. vim.fn.shellescape(config_path) .. " status --porcelain")
    if vim.v.shell_error ~= 0 then
      return
    end

    status = vim.trim(status)
    if status == "" then
      return -- No changes to commit/push
    end

    -- Check for unresolved conflict markers in the git status output
    for line in string.gmatch(status, "[^\r\n]+") do
      local prefix = string.sub(line, 1, 2)
      if prefix == "DD" or prefix == "AU" or prefix == "UD" or prefix == "UA" or prefix == "DU" or prefix == "AA" or prefix == "UU" then
        print("\n[GitAutoPush] Git conflicts detected. Skipping auto-sync on exit.")
        vim.fn.input("Press ENTER to exit...")
        return
      end
    end

    -- Print status message
    print("\n[GitAutoPush] Syncing Neovim configuration to git...")

    -- Stage changes
    vim.fn.system("git -C " .. vim.fn.shellescape(config_path) .. " add -A")
    if vim.v.shell_error ~= 0 then
      vim.api.nvim_err_writeln("[GitAutoPush] Failed to stage config changes.")
      vim.fn.input("Press ENTER to exit...")
      return
    end

    -- Commit changes
    local commit_msg = "Auto-commit: update config on exit (" .. os.date("%Y-%m-%d %H:%M:%S") .. ")"
    vim.fn.system("git -C " .. vim.fn.shellescape(config_path) .. " commit -m " .. vim.fn.shellescape(commit_msg))
    if vim.v.shell_error ~= 0 then
      vim.api.nvim_err_writeln("[GitAutoPush] Failed to commit config changes.")
      vim.fn.input("Press ENTER to exit...")
      return
    end

    -- Push changes (using GIT_TERMINAL_PROMPT=0 to prevent hanging on authentication prompts)
    local push_cmd = "GIT_TERMINAL_PROMPT=0 git -C " .. vim.fn.shellescape(config_path) .. " push"
    local push_out = vim.fn.system(push_cmd)

    if vim.v.shell_error ~= 0 then
      vim.api.nvim_err_writeln("[GitAutoPush] Failed to push config changes:\n" .. push_out)
      vim.fn.input("Press ENTER to exit...")
    else
      print("[GitAutoPush] Neovim configuration successfully pushed to remote!")
    end
  end,
})
