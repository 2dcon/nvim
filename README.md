# 💤 Custom LazyVim Configuration

This is a highly customized Neovim configuration built on top of [LazyVim](https://github.com/LazyVim/LazyVim). It adds modern editor behaviors, advanced keymaps, and integration hooks.

---

## Added Functions & Customizations

### 1. Modern Editor Mappings & Behaviors
* **Close File (`Ctrl+W`)**: Pressing `<C-w>` in normal, insert, visual, or select modes closes the current buffer/file using `Snacks.bufdelete` (saving layouts and prompting for unsaved edits).
* **Comment Toggle (`Ctrl+/` / `Ctrl+_`)**: 
  * In Insert Mode: Toggles commenting on the current line and returns you to Insert mode at the exact same cursor column.
  * In Visual/Select Mode: Toggles commenting on the active selection.
* **Undo (`Ctrl+Z`)**: Map `<C-z>` in normal, insert, and visual modes to perform standard undo.
* **Copy/Paste (`Ctrl+C` / `Ctrl+V`)**:
  * `<C-c>` in visual/select modes copies the selection to the system clipboard and enters insert mode.
  * `<C-v>` in insert/visual/select modes pastes the system clipboard (overwriting selection if active).
  * `<BS>` / `<Del>` in select mode deletes selection and returns to insert mode.
* **Auto Insert Mode on Click & Exit**: Clicking inside a regular editor pane or terminal pane automatically triggers Insert mode. Conversely, focusing non-editor/non-terminal panes (like Neo-tree or Outline) will automatically exit Insert mode.

### 2. Shift Selection (Keyboard text selection)
* **Arrow Selection**: Holding `<S-Up>`, `<S-Down>`, `<S-Left>`, or `<S-Right>` in insert or normal mode initiates select mode (mimicking standard GUI editors).
* **Home/End Selection**: `<S-Home>` and `<S-End>` select from the cursor position to the start or end of the line.
* **Smart Clipboard Preservation**: Starting a selection caches the current clipboard registers. If you press `<Esc>` to cancel the selection, the clipboard is restored to its pre-selection state, preventing visual highlights from polluting your clipboard history.


### 3. IntelliSense Suggestions Dismissal
* **Dismiss Menu (`Ctrl+C`)**: If the completion suggestion list (`blink.cmp`) is active, pressing `<C-c>` closes/hides the menu while keeping you in insert mode. If the menu is closed, it drops you into normal mode.

### 4. Git Agent Review Mode
* **Auto-Trigger**: On window focus (`FocusGained`), if there are unstaged changes matching files modified by the AI agent (tracked in the memory file `/dev/shm/agent_review_files.txt`), a prompt asks if you want to start a review.
* **Manual Trigger**: Run `<leader>gr` to start a review of all unstaged changes.
* **Review Interface**: Opens the diff in a vertical split (`Gitsigns diffthis`) with helper keymaps:
  * `<F9>`: Accept changes for the current file (`git add`).
  * `<F10>`: Accept all changes.
  * `<F11>`: Discard/Reject changes for the current file (`git checkout --`).
  * `<F12>`: Discard/Reject all changes.

### 5. C# Execution Mappings
* **Bottom Pane Run (`<F5>`)**: Compiles and executes the current C# project inside a bottom horizontal Kitty pane (`csharp_dbg_pane`). Reuses the pane (interrupted via Ctrl+C) if already open, adds execution headers, and closes when a key is pressed.
* **New Tab Run (`<F6>`)**: Compiles and executes the current C# project inside a new Kitty terminal tab.

### 6. File Explorer Improvements (Neo-tree)
* **Copy Paths (`Y`)**: Pressing `Y` inside Neo-tree opens a dropdown menu allowing you to copy the node's absolute path, relative path, or filename directly to the system clipboard.

### 7. Layout & UI Customization
* **Auto-Outline**: Automatically opens the outline sidebar pane on the right-hand side when opening directories.
* **Darker Backgrounds**: The TokyoNight colorscheme is configured to use the `"night"` style variant for a much darker editing background.
* **Global Hidden Cursor in Normal Mode**: Uses terminal escape sequences to completely hide the cursor in Normal mode globally across all buffers and sidebars, while restoring the cursor in all other modes (like Visual, Insert, and Command-line).
* **Outline Auto-Jump**: Configured `outline.nvim` to automatically jump to the corresponding code symbol in the editor as soon as an item is selected or single-clicked in the outline sidebar. It automatically handles instant highlight updates and snaps the cursor column to 0 to prevent selection shifting issues.











