---
name: keymap
description: Edits Neovim keybindings and actions using a split architecture rule.
---

# Objective
Create or edit keybindings for Neovim.

# Files to edit
1. **Key Definitions (`./lua/config/keymaps.lua`)**: 
	- The key and the function to call from keyactions.lua when the key is pressed
2. **Key Actions (`./lua/config/keyactions.lua`)**:
	- Functions for keys to execute

# Execution Protocol
When the user asks to modify a keybinding, analyze the intent before editing any files:

- **Scenario A: Changing the physical key trigger**
  *Intent:* The user wants to change *how* they trigger the shortcut (e.g., changing `ctrl+a` to `ctrl+b`).
  *Action:* You must ONLY edit `keymaps.lua`. Leave `keyactions.lua` entirely untouched.

- **Scenario B: Changing the function behavior**
  *Intent:* The user wants to change *what happens* when the key is pressed (e.g., make ctrl+d to delete lines instead of duplicating lines).
  *Action:* You must ONLY edit `keyactions.lua`. Leave `keymaps.lua` entirely untouched.

