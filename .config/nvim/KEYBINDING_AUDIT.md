# Keybinding Audit & Reference

Summary of keybinding review and changes made.

---

## Fixes applied

### 1. **Resolved conflict: `<leader>fr`**
- **Before:** Both “Copy relative path” (keymaps.lua) and “Telescope oldfiles” (telescope.lua) used `<leader>fr`. Telescope overwrote the copy binding.
- **After:** Copy-path actions use the **yank** prefix:
  - `<leader>yp` — Yank full path
  - `<leader>yr` — Yank relative path  
  - `<leader>yn` — Yank filename
- **Result:** `<leader>f` is only for Find (Telescope); `<leader>y` is for yanking paths.

### 2. **Which-key group labels**
- `<leader>d`: "Diff" → **"Diagnostics/Diff"** (covers `<leader>d`, `<leader>D`, `<leader>dt`, `do`, `du`).
- `<leader>l`: "Lazy" → **"Live server / LazyGit"** (covers live server + LazyGit).
- `<leader>m`: "Markdown" → **"Markdown/Format"** (covers preview and `<leader>mp` format).
- `<leader>w`: **"Save/Window/Session"** (save, window resize, session).
- **New:** `<leader>y` — **"Yank path"** (yp, yr, yn).

---

## Prefix overview

| Prefix | Group | Examples |
|--------|--------|----------|
| `<leader>a` | AI | OpenCode, Codeium, Cursor Agent (ao, aw, aj, aJ, aT…) |
| `<leader>b` | Buffer | bd, bD, [b, ]b |
| `<leader>c` | Code | ca (code action), ct (colorscheme), ch (color highlighter), cs (CSV) |
| `<leader>d` | Diagnostics/Diff | d (line diag), D (Telescope diag), dt, do, du |
| `<leader>e` | Explorer | ee, ef, ec, er (nvim-tree) |
| `<leader>f` | Find | ff, fr, fs, fc, ft, fb (Telescope) |
| `<leader>g` | Case | gu, gl, g~ (uppercase, lowercase, toggle) |
| `<leader>h` | Git hunk | hs, hr, hp, hb, hB, hd, hD, [h, ]h |
| `<leader>H` | HTTP (Kulala) | Hr, Ht, H[, H], Hi, Hc, Hs, Hq |
| `<leader>l` | Live/LazyGit | ls, lS, lc, lC, ll (live server), lg (LazyGit) |
| `<leader>m` | Markdown/Format | mv, ms (preview), mp (format) |
| `<leader>n` | Clear/Number | nh (nohl), +, =, nx, nr |
| `<leader>q` | Quit | q, Q |
| `<leader>r` | Rename/Restart | rn (rename), rs (LSP restart) |
| `<leader>s` | Svelte/Search | sc, sp, sl (Svelte), sr (search-replace) |
| `<leader>t` | Tab/Toggle/Spell | tn, tc, to, tp, tN, tm, t1–5, tr, tw, tl, ts |
| `<leader>z` | Terminal | zt, zf, zv, zx |
| `<leader>u` | UI toggle | uh (inlay hints), uv (virtual text diag) |
| `<leader>v` | Version/Checkpoint | vc, vr, vd, vx, vC, vP, vR, vS |
| `<leader>w` | Save/Window/Session | w, W, w=, w\|, w_, wr, ws |
| `<leader>x` | Trouble | xw, xd, xq, xl, xt |
| `<leader>y` | Yank path | yp, yr, yn |
| `<leader>-` | Oil | Oil (floating) |
| `<leader>j` | Flash | Flash jump |
| `<leader>S` | Flash | Flash Treesitter |

---

## No-leader navigation (Vim style)

| Keys | Action |
|------|--------|
| `[b` `]b` | Prev/next buffer |
| `[q` `]q` `[Q` `]Q` | Quickfix |
| `[l` `]l` `[L` `]L` | Location list |
| `[d` `]d` `[D` `]D` | Diagnostics / errors only |
| `[h` `]h` | Git hunks |
| `[s` `]s` | Spell |
| `[t` `]t` | Todo comments |
| `gR` | LSP references (Telescope) |

---

## Optional future tweaks

1. **Terminal on `<leader>z`**  
   Terminal has its own prefix (z = shell): `<leader>zt` (toggle), `zf` (float), `zv` (vertical), `zx` (shutdown all). `<leader>t` is only tabs, toggles, and spell.

2. **Session vs Window under `<leader>w`**  
   Single-key `<leader>w` is save; `<leader>wr`/`ws` are session. No conflict; optional: session under `<leader>S` (capital) if you want “S = Session”.

3. **Consistency**  
   Most prefixes are lowercase; `<leader>D` (diagnostics) and `<leader>Q` (force quit) use capital for “stronger” action, which is consistent.

---

## Quick reference (path & find)

| Key | Action |
|-----|--------|
| `<leader>ff` | Find files |
| `<leader>fr` | Recent files |
| `<leader>fs` | Live grep |
| `<leader>fc` | Grep word under cursor |
| `<leader>ft` | Find todos |
| `<leader>fb` | Buffers |
| `<leader>yp` | Yank full path |
| `<leader>yr` | Yank relative path |
| `<leader>yn` | Yank filename |

Press `<leader>` and wait for which-key to see all prefixes; then press the next key(s) for that group.
