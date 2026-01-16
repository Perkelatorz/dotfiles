# AI Configuration Summary

This Neovim configuration includes three AI tools for different use cases:

## 🤖 AI Tools Overview

### 1. **Windsurf (Codeium)** - AI Autocompletion
**Best for:** Inline code suggestions as you type

- **Status:** ✅ Actively maintained
- **Cost:** ✅ **Completely FREE**
- **Context:** Workspace-aware with LSP integration
- **Integration:** Native nvim-cmp support + virtual text

**Usage:**
- Suggestions appear automatically as gray ghost text while typing
- Press `<Tab>` to accept full suggestion
- Press `<M-w>` (Alt-W) to accept next word only
- Press `<M-l>` (Alt-L) to accept line only
- Press `<C-]>` to clear suggestion
- Press `<M-]>` / `<M-[>` (Alt-] / Alt-[) to cycle suggestions

**Setup (First Time):**
1. Open Neovim
2. Run `:Codeium Auth`
3. Browser opens with authentication page
4. Create free account or log in
5. Copy token and paste in Neovim prompt
6. Start coding - suggestions appear automatically!

**Keybindings:**
- `<leader>aw` - Toggle Windsurf on/off
- `<leader>aC` - Open Windsurf Chat (browser)
- `<leader>aA` - Authenticate Windsurf
- `<leader>aS` - Show Windsurf status

**Commands:**
- `:Codeium Auth` - Authenticate (first time setup)
- `:Codeium Toggle` - Toggle on/off globally
- `:Codeium Chat` - Open chat in browser
- `:Codeium Status` - Check connection status

---

### 2. **OpenCode** - AI Assistant
**Best for:** Interactive AI coding assistance

**Keybindings:**
- `<leader>ao` - Launch OpenCode
- `<leader>aog` - Toggle OpenCode window
- `<leader>aoi` - Open input window
- `<leader>aoo` - Open output window
- `<leader>aoq` - Close UI windows
- `<leader>ao/` - Quick chat

---

### 3. **CodeCompanion** - AI Chat
**Best for:** Chat-based code assistance and explanations

**Requires:** Anthropic API key (Claude)

**Keybindings:**
- `<leader>aa` - CodeCompanion actions menu
- `<leader>ac` - Toggle chat window
- `<leader>at` - Open new chat
- `<leader>ai` - Add visual selection to chat
- `<leader>ap` - Inline prompt

**Setup:**
Add to `~/.config/nvim/secrets.lua`:
```lua
return {
  ANTHROPIC_API_KEY = "your-key-here",
}
```

Or set environment variable:
```bash
export ANTHROPIC_API_KEY="your-key-here"
```

---

## 🎯 When to Use Each Tool

| Tool | Use Case | Cost |
|------|----------|------|
| **Windsurf** | Auto-complete code as you type | Free |
| **OpenCode** | Interactive coding assistance | Free |
| **CodeCompanion** | Chat about code, get explanations | Requires API key |

---

## 🚀 Quick Start

### For Autocompletion (Windsurf):
1. Run `:Codeium Auth` in Neovim
2. Authenticate in browser (free account)
3. Start typing - see inline suggestions!
4. Press `<Tab>` to accept

### For Chat (CodeCompanion):
1. Add Anthropic API key to `secrets.lua`
2. Press `<leader>ac` to open chat
3. Ask questions or request code

### For AI Assistant (OpenCode):
1. Press `<leader>ao`
2. Start interacting!

---

## 📊 Completion Source Priority

In the completion menu (triggered by `<C-Space>`):

1. **[AI]** - Windsurf/Codeium suggestions (highest priority, max 3 items)
2. **[LSP]** - Language server completions
3. **[Snip]** - Code snippets
4. **[Buf]** - Buffer text
5. **[Path]** - File paths

---

## 💡 Windsurf Virtual Text Features

### Inline Suggestions (Ghost Text)
Windsurf shows AI completions as gray ghost text while you type:

```python
def calculate_fibonacci(|
                        └─ (gray text: n): ...)
```

### Intelligent Completion
- **Tab completion:** Accepts when no cmp menu is visible
- **Smart context:** Uses LSP workspace root for better suggestions
- **Multi-line:** Can suggest entire functions/blocks
- **Fast:** Minimal delay (75ms) after typing stops

### Keybinding Modes

**Insert Mode (while typing):**
- `<Tab>` - Accept full suggestion
- `<M-w>` - Accept next word
- `<M-l>` - Accept next line
- `<C-]>` - Clear current suggestion
- `<M-]>` - Next suggestion
- `<M-[>` - Previous suggestion

**Normal Mode:**
- `<leader>aw` - Toggle Windsurf globally
- `<leader>aS` - Show status notification

---

## ⚙️ Configuration Files

- **Windsurf/Codeium:** `~/.config/nvim/lua/nvim/plugins/codeium.lua`
- **OpenCode:** `~/.config/nvim/lua/nvim/plugins/opencode.lua`
- **CodeCompanion:** `~/.config/nvim/lua/nvim/plugins/codecompanion.lua`
- **nvim-cmp:** `~/.config/nvim/lua/nvim/plugins/nvim-cmp.lua`

---

## 🔧 Customization

### Disable Inline Suggestions (Menu Only)
If you only want Windsurf in the completion menu:

Edit `codeium.lua`:
```lua
virtual_text = {
  enabled = false,  -- Disable inline ghost text
},
```

### Change Suggestion Color
Edit `codeium.lua` and add:
```lua
virtual_text = {
  enabled = true,
  -- Add this to change color
  virtual_text_priority = 65535,
},
```

Then set highlight in your colorscheme:
```lua
vim.api.nvim_set_hl(0, "CodeiumSuggestion", { fg = "#808080", italic = true })
```

### Adjust Idle Delay
Edit `codeium.lua`:
```lua
virtual_text = {
  idle_delay = 150,  -- Change from 75ms to 150ms
},
```

### Disable for Specific Filetypes
Edit `codeium.lua`:
```lua
virtual_text = {
  filetypes = {
    markdown = false,  -- Disable in markdown
    text = false,      -- Disable in text files
  },
},
```

### Adjust Completion Priority
Edit `nvim-cmp.lua` sources section to reorder priorities.

---

## 🐛 Troubleshooting

### Windsurf not showing suggestions:

**Check authentication:**
```vim
:Codeium Status
```

**Re-authenticate if needed:**
```vim
:Codeium Auth
```

**Toggle to restart:**
```vim
:Codeium Toggle
:Codeium Toggle
```

**Check logs:**
Windsurf logs are in: `~/.cache/nvim/codeium/codeium.log`

### nvim-cmp not showing AI completions:

**Verify Windsurf is running:**
```vim
:Codeium Status
```

**Try manual trigger:**
Press `<C-Space>` in insert mode

**Check cmp sources:**
```vim
:CmpStatus
```
Should show `codeium` as available source

### Inline suggestions not appearing:

**Check virtual_text is enabled:**
Look for `virtual_text = { enabled = true }` in `codeium.lua`

**Verify you're in insert mode:**
Ghost text only appears while typing in insert mode

**Check filetype isn't disabled:**
Some filetypes may be disabled in config

### Tab key not working:

**Conflict with other plugins:**
If Tab is mapped by another plugin, Windsurf falls back gracefully

**Change accept key:**
Edit `codeium.lua` and change `accept = "<Tab>"` to another key like `<C-y>`

---

## 🆚 Why Windsurf Over Other Options?

| Feature | Windsurf | GitHub Copilot | Supermaven |
|---------|----------|----------------|------------|
| **Cost** | Free | $10/month | Free tier |
| **Maintenance** | Active | Active | Inactive (6+ months) |
| **nvim-cmp** | Native | Via plugin | Via plugin |
| **Chat** | Built-in | Separate | None |
| **Context** | Workspace-aware | File-based | Large window |
| **Setup** | Free account | Paid subscription | Free account |

---

## 📝 Notes

- **Windsurf/Codeium** runs locally but connects to cloud for AI
- **OpenCode** is free and open source
- **CodeCompanion** requires paid Anthropic API access
- All three can be used together or independently
- Disable any tool by removing/commenting its plugin file

---

## 🎓 Tips & Best Practices

1. **Use the right tool for the job:**
   - Quick completions → Windsurf inline
   - Complex refactoring → OpenCode or CodeCompanion chat
   - Learning/explaining → CodeCompanion

2. **Combine tools:**
   - Get inline suggestion from Windsurf
   - Ask CodeCompanion to explain it
   - Use OpenCode to refactor it

3. **Manage performance:**
   - Disable Windsurf in large files if needed
   - Use `:Codeium Toggle` when not needed
   - Adjust `idle_delay` if too aggressive

4. **Keyboard-first workflow:**
   - Learn the Alt+W/L for partial acceptance
   - Use Alt+]/[ to cycle through multiple options
   - Master `<leader>a` prefix for all AI tools

---

For full documentation, see `NVIM_CONFIG_DOCS.md`
