# Keybindings & Commands Reference

**Leader:** `<Space>` · Press `<leader>` and wait (~500ms) for which-key, or `<leader>?` anytime.

---

## By Prefix (<leader>X)

| Prefix | Group | Keys |
|--------|-------|------|
| `a` | AI | aw, ac, aa, as (Codeium), aj, al, at (Cursor Agent) |
| `b` | Buffer | bd, bx, [b, ]b |
| `c` | Code | ca, ct, ch, cs (code action, colorscheme, color highlighter, CSV) |
| `d` | Diagnostics/Diff | dd, dl, dt, do, du |
| `e` | Explorer | ee, ef, ec, er (nvim-tree) |
| `f` | Find | ff, fr, fs, fc, ft, fb (Telescope) |
| `g` | Case | gu, gl, g~ |
| `G` | Go | Gr, Gt, Ga, Gb (in .go buffers) |
| `h` | Git hunk | hs, hr, hp, hb, hl, [c, ]c |
| `H` | HTTP (Kulala) | Hr, Ht, H[, H], Hi, Hc, Hs, Hq |
| `l` | Live/LazyGit | ls, lz, lc, lx, ll, lg |
| `m` | Markdown/Format | mv, ms, mp |
| `n` | Clear/Number | nh, +, =, nx, nr |
| `o` | Obsidian | on, oq, of, ob, ot, od, os, oc |
| `-` | Oil | Oil (floating) |
| `r` | Rename/Restart | rn, rs, rr |
| `s` | Svelte/Search | sc, sp, sl, sr |
| `t` | Tab/Toggle/Spell | tn, tc, to, tp, tj, tm, t1–5, tr, tw, tl, ts |
| `u` | UI toggle | uh (inlay hints), uv (virtual text) |
| `v` | Checkpoint | vc, vr, vd, vx, vh, vj, vk, vl |
| `w` | Save/Window/Session | w, ww, w=, w\|, w_, wr, ws |
| `x` | Trouble | xw, xd, xq, xl, xt |
| `y` | Yank path | yp, yr, yn |
| `z` | Terminal | zt, zf, zv, zx |

---

## Essential Keybindings

### Terminal (`<leader>z`)
```
zt    Toggle (bottom)    zf    Floating
zv    Vertical           zx    Shutdown all
zc    Send cd to current file dir (in terminal)
```

### AI Checkpoint
```
vc    Create (single)    vr    Restore    vd    Diff
vh    Checkpoint open    vj    Project    vk    Restore all    vl    Show changes
```

### Quick Actions
```
w     Save    ww    Save all    q    Quit    qq    Force quit
sr    Search and replace word under cursor
```

### Find (Telescope)
```
ff    Files    fr    Recent    fs    Grep    fc    Cursor word    ft    Todos    fb    Buffers
```

### Code
```
ca    Code action    rn    Rename    dd    Line diagnostic (float)    dl    Diagnostics (Telescope)
rs    Restart LSP    gR    Refs (Telescope)
K     Hover doc    gd    Definition    gD    Declaration    gi    Implementation    gR    Refs (Telescope)
```

### Navigation (no leader)
```
[b ]b    Buffers      [q ]q    Quickfix      [l ]l    Location list
[d ]d    Diagnostics  [D ]D    Errors only   [c ]c    Git hunks
[t ]t    Todo         [s ]s    Spell
```

### Flash (no leader)
```
s    Jump (fuzzy)     S    Treesitter     f/F/t/T    Go to char (with labels)
```

### Git
```
lg    LazyGit    hs    Stage hunk    hr    Reset hunk    hp    Preview hunk    hb    Blame
```

### Explorer
```
ee    Toggle nvim-tree    -    Oil (floating)
```

---

## Commands

| Command | Purpose |
|---------|---------|
| `:Mason` | Mason UI (LSP, formatters) |
| `:LspInfo` | LSP status |
| `:LspRestart` | Restart LSP |
| `:TSUpdate` | Update treesitter parsers |
| `:TSCheckSvelte` | Check Svelte parsers |
| `:Inspect` | Highlight group under cursor |
| `:InspectTree` | Syntax tree |
| `:StartupTime` | Startup time |
| `:MemoryUsage` | Memory usage |
| `:checkhealth` | Neovim health |
| `:ColorschemeToggle` | Purpleator ↔ Nightfox |

---

## Common Workflows

**Run server:** `<leader>zt` → run command → `<leader>zt` to hide (server keeps running)

**Hover documentation (like VS Code):** Put cursor on a symbol and press **K**, or rest for ~500ms for auto-hover.

**Navigate errors:** `]d` next diagnostic, `<leader>dd` show details, `<leader>ca` code action

**Git:** `<leader>lg` LazyGit, or `<leader>hs`/`hr` hunks

**AI undo:** `<leader>vc` before edit, `<leader>vr` to restore
