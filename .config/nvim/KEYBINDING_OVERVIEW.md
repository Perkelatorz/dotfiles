# Keybinding Overview

**Leader:** `<Space>`

Press `<leader>` and wait for which-key to see all prefixes.

---

## By prefix (alphabetical)

| Prefix | Group | Bindings |
|--------|--------|----------|
| **a** | AI | ao, ai, aO, aq, ac, as, af, ab, ad, al, ae, ag, aP, aG, aK, aD, aL, ap, a?, aw, aC, aA, aS, aj, aJ, aT |
| **b** | Buffer | bd, bD, [b, ]b |
| **c** | Code | ca, ct, ch, cs |
| **d** | Diagnostics/Diff | d, D, dt, do, du |
| **e** | Explorer | ee, ef, ec, er |
| **f** | Find | ff, fr, fs, fc, ft, fb |
| **g** | Case | gu, gl, g~ |
| **h** | Git hunk | hs, hr, hS, hR, hu, hp, hb, hB, hd, hD, [h, ]h |
| **H** | HTTP (Kulala) | Hr, Ht, H[, H], Hi, Hc, Hs, Hq |
| **j** | Flash | j (Flash jump) |
| **l** | Live / LazyGit | ls, lS, lc, lC, ll, lg |
| **m** | Markdown/Format | mv, ms, mp |
| **n** | Clear/Number | nh, +, =, nx, nr |
| **o** | Obsidian | on, oq, of, ob, ot, od, os, otl, oo, oc |
| **-** | Oil | - (Oil floating) |
| **q** | Quit | q, Q |
| **r** | Rename/Restart | rn, rs |
| **s** | Svelte/Search | sc, sp, sl, sr |
| **S** | Flash | S (Flash Treesitter) |
| **t** | Tab/Toggle/Spell | tn, tc, to, tp, tN, tm, t1–5, tr, tw, tl, ts |
| **u** | UI toggle | uh, uv |
| **v** | Version/Checkpoint | vc, vr, vd, vx, vC, vP, vR, vS |
| **w** | Save/Window/Session | w, W, w=, w\|, w_, wr, ws |
| **x** | Trouble | xw, xd, xq, xl, xt |
| **y** | Yank path | yp, yr, yn |
| **z** | Terminal | zt, zf, zv, zx |

---

## Quick reference by action

### Most used
- **Save/quit:** `w` save, `W` save all, `q` quit, `Q` force quit
- **Find:** `ff` files, `fr` recent, `fs` grep, `fb` buffers
- **Terminal:** `zt` toggle, `zf` float, `zv` vertical, `zx` close all
- **LSP:** `d` line diag, `D` diag list, `ca` code action, `rn` rename
- **Checkpoint (AI undo):** `vc` create, `vr` restore, `vd` diff

### Navigation (no leader)
- **Buffers:** `[b` `]b`
- **Quickfix:** `[q` `]q` `[Q` `]Q`
- **Location list:** `[l` `]l` `[L` `]L`
- **Diagnostics:** `[d` `]d` `[D` `]D` (errors only)
- **Git hunks:** `[h` `]h`
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

- **w / W** — save / save all  
- **q / Q** — quit / force quit  
- **b / bD** — delete buffer / force delete  
- **t / tN** — previous tab / next tab  
- **v / vC, vP, vR, vS** — checkpoint variants  
- **R, U** — reload buffers, undo to previous save  
- **d / D** — line diagnostic / diagnostics list  
- **a** — many AI binds use second key as capital (aO, aP, aG, aK, aD, aL, aC, aA, aS, aT)  
- **h / hS, hR, hB, hD** — git hunk variants  

Everything else is lowercase.

---

## Layout summary

- **a** = AI (OpenCode, Codeium, Cursor Agent)
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
