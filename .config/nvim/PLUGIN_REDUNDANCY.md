# Plugin Redundancy Summary

Quick overview of redundant or overlapping plugins in your Neovim config.

---

## Definitely redundant (safe to remove)

### 1. **schemastore.nvim** (standalone file)
- **File:** `lua/nvim/plugins/schemastore.lua`
- **Why redundant:** Schemastore is already a **dependency** of `nvim-lspconfig` and is used inside `lspconfig.lua` for JSON and YAML schemas. The standalone plugin file adds no extra config—it only declares the plugin.
- **Action:** The standalone `schemastore.lua` has been removed. LSP config will still load schemastore when needed.

---

## Overlap (optional to trim)

### 2. **Diagnostics: Telescope vs Trouble**
- **Telescope (LSP):** `<leader>dl` = buffer diagnostics, `<leader>df` = line diagnostic float.
- **Trouble:** `<leader>xw` = workspace diagnostics, `<leader>xd` = document diagnostics, `<leader>xq` = quickfix, `<leader>xl` = loclist, `<leader>xt` = todos.
- **Overlap:** Both can show diagnostics. Telescope is a one-off picker; Trouble is a persistent list (quickfix/loclist/todos).
- **Recommendation:** Keep both unless you never use Trouble. If you only use `<leader>dl` and `<leader>df`, you could remove Trouble and its keybindings—but you’d lose the Trouble list UI for quickfix/loclist/todos.

### 3. **Plenary.nvim**
- Declared in `init.lua` and as a dependency of Codeium, Telescope, todo-comments, lazygit.
- **Not redundant:** The one in `init.lua` is for early load; others are dependency declarations. Lazy deduplicates, so only one copy loads.

---

## Not redundant (often confused)

| Plugins | Why both are needed |
|--------|----------------------|
| **nvim-tree** + **oil** | Tree = sidebar file explorer; Oil = edit folder as buffer (e.g. rename/delete in place). |
| **flash** | Jump/label motion (Arrow was removed; use Telescope for file/buffer navigation). |
| **friendly-snippets** + **nvim-svelte-snippets** | General VS Code–style snippets vs Svelte-only snippets; both feed LuaSnip. |
| **Comment.nvim** + **nvim-ts-context-commentstring** | Comment does the keymap/commenting; ts-context-commentstring provides the comment string (e.g. `//` vs `<!--`). |
| **conform.nvim** | Only formatter (format-on-save, `<leader>mp`); no duplicate formatter. |
| **Codeium** + **Kulala** | Codeium = inline AI completion; Kulala = HTTP/REST client. |
| **markdown-preview** + **prelive** | Markdown preview in browser vs live static file server; different use cases. |
| **lualine** + **tabline** (core) | Lualine = statusline (bottom); tabline = tab bar (top). |

---

## Summary

- **Removed:** Standalone `schemastore.lua` (redundant with lspconfig dependency).
- **Optional:** Consider dropping Trouble only if you don’t use its list views (quickfix/loclist/todos).
- Everything else listed above is either a dependency or a distinct feature.
