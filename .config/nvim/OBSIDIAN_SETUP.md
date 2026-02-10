# Obsidian.nvim Setup

Obsidian-style note-taking in Neovim: wiki links, daily notes, backlinks, and vault search.

## 1. Set your vault path

Edit `lua/nvim/plugins/obsidian.lua` and set `workspaces` to your vault path(s):

```lua
workspaces = {
	{ name = "main", path = "~/vault" },
	-- { name = "work", path = "~/vaults/work" },
},
```

If you use the Obsidian app, use the same folder as your vault root (where `.obsidian` lives).

## 2. Requirements

- **ripgrep** (`rg`) on your `PATH` for search and completion.
- Telescope and nvim-cmp are already in your config (used by Obsidian).

## 3. Keybindings (all under `<leader>o`)

| Key | Action |
|-----|--------|
| `on` | New note |
| `oq` | Quick switch (jump to note) |
| `of` | Follow link under cursor |
| `ob` | Backlinks to current note |
| `ot` | Today's daily note |
| `od` | Dailies picker |
| `os` | Search vault |
| `otl` | Insert template |
| `oo` | Open current note in Obsidian app |
| `oc` | Toggle checkbox (in note) |

**In note:** `gf` on a `[[link]]` follows the link. `<cr>` on a link or checkbox does the right thing.

## 4. Completion

In markdown buffers inside your vault:

- `[[` — complete wiki links
- `[` — complete markdown links  
- `#` — complete tags

Completion is provided via nvim-cmp (no extra config).

## 5. Optional: templates

Create a `templates` folder in your vault. Use `:ObsidianTemplate` (or `<leader>otl`) to insert a template, or `:ObsidianNewFromTemplate` to create a new note from a template.

---

**Oil** (edit directory as buffer) is still on **`<leader>-`** (minus). Obsidian uses **`<leader>o`** (letter o).
