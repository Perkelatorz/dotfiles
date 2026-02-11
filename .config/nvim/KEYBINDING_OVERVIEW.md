# Keybinding Overview

**Leader:** `<Space>`

Press `<leader>` and wait for which-key to see all prefixes.

---

## By prefix (alphabetical)

| Prefix | Group | Bindings |
|--------|--------|----------|
| **a** | AI | aw, ac, aa, as (Codeium), aj, al, at (Cursor Agent) |
| **b** | Buffer | bd, bx, [b, ]b |
| **c** | Code | ca, ct, ch, cs |
| **d** | Diagnostics/Diff | df, dl, dt, do, du |
| **e** | Explorer | ee, ef, ec, er |
| **f** | Find | ff, fr, fs, fc, ft, fb |
| **g** | Case | gu, gl, g~ |
| **G** | Go (in .go buffers) | Gr, Gt, Ga, Gb |
| **h** | Git hunk | hs, hr, hx, he, hu, hp, hb, hl, hd, hy, [c, ]c |
| **H** | HTTP (Kulala) | Hr, Ht, H[, H], Hi, Hc, Hs, Hq |
| **j** | Flash | j (Flash jump) |
| **l** | Live / LazyGit | ls, lz, lc, lx, ll, lg |
| **m** | Markdown/Format | mv, ms, mp |
| **n** | Clear/Number | nh, +, =, nx, nr |
| **o** | Obsidian | on, oq, of, ob, ot, od, os, otl, oo, oc |
| **-** | Oil | - (Oil floating) |
| **q** | Quit | q, qq |
| **r** | Rename/Restart | rn, rs, rr (reload) |
| **s** | Svelte/Search | sc, sp, sl, sr |
| **S** | Flash | S (Flash Treesitter) |
| **t** | Tab/Toggle/Spell | tn, tc, to, tp, tj, tm, t1–5, tr, tw, tl, ts |
| **u** | UI toggle | uh, uv |
| **v** | Version/Checkpoint | vc, vr, vd, vx, vh, vj, vk, vl |
| **w** | Save/Window/Session | w, ww, w=, w\|, w_, wr, ws |
| **x** | Trouble | xw, xd, xq, xl, xt |
| **y** | Yank path | yp, yr, yn |
| **z** | Terminal | zt, zf, zv, zx |

---

## Quick reference by action

### Most used
- **Save/quit:** `w` save, `W` save all, `q` quit, `Q` force quit
- **Find:** `ff` files, `fr` recent, `fs` grep, `fb` buffers
- **Terminal:** `zt` toggle, `zf` float, `zv` vertical, `zx` close all
- **LSP:** `df` line diag, `dl` diag list, `ca` code action, `rn` rename
- **Checkpoint (AI undo):** `vc` create, `vr` restore, `vd` diff

### AI (`<leader>a`) — Codeium + Cursor Agent
- **Codeium:** `aw` toggle, `ac` chat, `aa` auth, `as` status
- **Cursor Agent:** `aj` root, `al` cwd, `at` sessions
- **Accept suggestion (insert):** `Alt+y` full, `Alt+w` word, `Alt+l` line

### Navigation (no leader)
- **Buffers:** `[b` `]b`
- **Quickfix:** `[q` `]q` `[Q` `]Q`
- **Location list:** `[l` `]l` `[L` `]L`
- **Diagnostics:** `[d` `]d` `[D` `]D` (errors only)
- **Git hunks:** `[c` `]c` (gitsigns convention)
- **Todo:** `[t` `]t`
- **Spell (Vim default):** `[s` `]s` `z=` `zg` `zw` `zug`

### Single-key (no second key)
- **Flash jump:** `j`
- **Flash Treesitter:** `S`
- **Oil:** `-`
- **LSP refs:** `gR`

---

## Remaining capitals

Used only where a “stronger” or alternate action is useful:

- **w / ww** — save / save all  
- **q / qq** — quit / force quit  
- **b / bx** — delete buffer / force delete  
- **t / tj** — previous tab (tp) / next tab (tj)  
- **v / vh, vj, vk, vl** — checkpoint (session/project/restore/show)  
- **R, U** — reload buffers, undo to previous save  
- **df / dl** — line diagnostic (float) / diagnostics list  
- **h** — git: hx (stage buffer), he (reset buffer), hl (line blame), hy (diff ~)

Everything else is lowercase.

---

## Layout summary

- **a** = AI (Codeium, Cursor Agent)
- **b** = Buffer
- **c** = Code (actions, colorscheme, color highlighter, CSV)
- **d** = Diagnostics + diff
- **e** = Explorer (nvim-tree)
- **f** = Find (Telescope)
- **g** = Case (upper/lower/toggle)
- **h** = Git hunks | **H** = HTTP (Kulala)
- **l** = Live server + LazyGit
- **m** = Markdown + format
- **n** = Clear highlights, number +/- , hex
- **t** = Tab, toggles, spell
- **z** = Terminal
- **y** = Yank path
- **v** = Checkpoint/version
- **w** = Save, window, session
- **x** = Trouble
- **-** = Oil
