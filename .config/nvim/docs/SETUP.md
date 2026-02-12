# Setup Guides

## AI: Codeium (Windsurf)

Free AI completion with ghost text. **First time:** `:Codeium Auth` or `<leader>aa`.

**Keys:** `aw` toggle · `ac` chat · `aa` auth · `as` status

**Accept suggestion (insert):** `Alt+y` full · `Alt+w` word · `Alt+l` line · `C-]` clear

Ghost text uses a faded purple color (not green) so it doesn’t look like comments.

---

## AI: Cursor Agent (CLI)

Use Cursor’s AI from Neovim via the CLI.

### Install Cursor CLI

```bash
curl https://cursor.com/install -fsSL | bash
agent --version
```

Sign in at cursor.com or in the Cursor app so the CLI can use your account.

### Keys

| Key | Action |
|-----|--------|
| `<leader>aj` | Agent at **project root** |
| `<leader>al` | Agent in **current dir** |
| `<leader>at` | List / resume **sessions** |

### In Agent terminal

- **Submit:** `Ctrl+Enter` or `Ctrl+/`
- **Attach file:** `Ctrl+Shift+F`
- **Attach buffers:** `Ctrl+Shift+A`
- **Hide:** `q` or `Ctrl+W`n

---

## Go

**LSP:** gopls (Mason) · **Format:** goimports + gofumpt (format on save)

**Keys (in .go buffers):** `<leader>Gr` run · `Gt` test package · `Ga` test all · `Gb` build

**Setup:** Install Go, open a `.go` file; Mason installs gopls etc. Run `:Mason` to verify.

---

## Obsidian

Obsidian-style notes: wiki links, daily notes, backlinks. Set vault path in `lua/nvim/plugins/obsidian.lua`.

**Keys:** `on` new · `oq` quick switch · `of` follow link · `ob` backlinks · `ot` today · `od` dailies · `os` search · `otl` template · `oo` open in Obsidian app · `oc` checkbox

**Requirements:** `rg` on PATH for search.

---

## Plugin Notes

- **Telescope vs Trouble:** Both show diagnostics. Telescope = one-off picker; Trouble = persistent list (quickfix, loclist, todos). Keep both unless you never use Trouble.
- **nvim-tree + Oil:** Tree = sidebar; Oil = edit folder as buffer.
- **Codeium + Kulala:** Codeium = AI completion; Kulala = HTTP client.
- **Flash:** Jump labels (`s`, `S`); char motion (`f`/`F`/`t`/`T`) with labels when enabled.
