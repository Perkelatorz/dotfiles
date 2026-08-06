# Neovim

Layout: **`init.lua`**, **`lua/config/core/`** (options, spell, docs, keymaps, autocmds, colorscheme), **`lua/config/pack.lua`** (plugins via **`vim.pack`**), **`lua/config/plugins/`** (each plugin’s `setup()`).

**Leader:** `<Space>`.

**OS packages (Arch):** managed in **yadm** — see **`~/.config/yadm/packages/dev.pkgs`** (and **`base.pkgs`**) and run **`yadm bootstrap`**. **Mason / LSP** still install into `~/.local/share/nvim/mason` when you use Neovim.

**Dependencies & reinstall:** see **`DEPENDENCIES.md`**. To wipe downloaded plugins, Mason, Tree-sitter, and Nvim cache then reinstall on next start: **`~/.config/nvim/scripts/reset-nvim-data.sh`** (use **`--yes`** for non-interactive; **`--reset-lock`** to drop **`nvim-pack-lock.json`** too).

## Plugins and lockfile

Declare repos in **`lua/config/pack.lua`** (`:help vim.pack`). On multiple machines, commit **`nvim-pack-lock.json`** (e.g. with yadm) so every host gets the same revisions. After changing the pack list, restart Nvim so the lockfile can refresh. Upgrades: **`:lua vim.pack.update()`** (`:help vim.pack.update()`).

## LSP (Mason)

**`lua/config/plugins/lsp.lua`** — `mason-lspconfig` installs:

`lua_ls`, `ts_ls`, `eslint`, `svelte`, `tailwindcss`, `gopls`, `pyright`, `dockerls`, `docker_compose_language_service`, `ansiblels`, `rust_analyzer`, `vue_ls`, `bashls`, `taplo`, `html`, `jsonls`, `cssls`, `graphql`, `marksman`, `yamlls`.

**Nix / `.nix`:** **`nil_ls`** runs only if a **`nil`** binary is on **`PATH`** (e.g. AUR **`nil-git`**). Mason’s **`nil`** package is not used (it requires the Nix package manager to build).

**YAML:** **`yamlls`** (schemas) + **`yamlfmt`** via Conform + **`yamllint`** / **`ansible_lint`** via nvim-lint on save. **`<leader>cf`** format, **`<leader>cl`** lint.

**Markdown:** **render-markdown.nvim**; **`<leader>mp`** Glow preview (split term); **`<leader>mt`** / **`<leader>mv`** toggle / preview rendering; **`<leader>mb`** live browser preview (see *Notes* below).

**CSV/TSV:** **csvview.nvim** (auto under ~12k lines); **`<leader>cv`** toggles.

Use filetypes **`yaml.ansible`** and **`yaml.docker-compose`** where relevant (see **`lang-samples/`** modelines).

## Terminals — none

There is no terminal plugin. Interactive shells are the window manager's job (mango),
which handles splitting, tiling and focus better than an editor can. `<Leader>cc` (Claude
Code), `<Leader>tt`/`<Leader>th` (shells) and `<Leader>gy` (yadm diff) are gone along with
toggleterm; run those in their own WM window.

The one exception is `<Leader>mp`, a read-only Glow pager in a plain `:terminal` split —
see `lua/config/plugins/live_preview.lua`. `<Leader>q` wipes it.

## Keymap philosophy — stay close to stock Vim

**Rule: don't shadow a built-in unless the replacement is a strict superset, or the
built-in is trivially reachable another way.** The point is to keep learning real Vim,
so muscle memory transfers to any `vi` on any box.

Built-ins that *are* shadowed, and why each earns it:

| Key(s) | Owner | Justification |
|---|---|---|
| `f` `F` `t` `T` `;` `,` | flash.nvim | **Superset.** Same character motion, same repeat direction — only jump labels are added. Nothing to unlearn. |
| `s` `S` | flash.nvim | Real replacement. Vim equivalents: `cl` for `s`, `cc` for `S`. |
| `S` (visual) | nvim-surround | Standard surround verb; visual `S` ≈ `cc` in a selection. |
| `r` `R` (op-pending/visual) | flash.nvim | Vim leaves these largely unused in operator-pending. |
| `<Esc>` (normal) | `nohlsearch` | Vim leaves `<Esc>` a no-op in normal mode. |
| `Y`, visual `*` `#` `Q`, insert `<C-U>` `<C-W>` | **Neovim itself** | Built-in defaults, not this config. Leave alone. |

Deliberately **not** remapped (these were removed — see the comment block in
`lua/config/core/keymaps.lua` for the Vim way to get each result): `n` `N` `<C-d>` `<C-u>`
(auto-centering), `J` and `*` (mark-`z` cursor tricks), visual `<` `>` (reselect), visual
`p` (`"_dP`), `Q` (was `<nop>`).

Two built-ins were being destroyed by plugin defaults and have been reclaimed:

- **`m`** — sets a mark (`ma`, then `` `a ``/`'a`). arrow.nvim had taken it; moved to `<leader>'`.
- **`;`** — repeats `f`/`t`. arrow.nvim had taken it, which silently broke repeat-f/t and
  undercut flash's whole reason for existing; moved to `<leader>;`. `;`/`,` now work.

Audit this at any time with `<leader>kc` / `<leader>kk` (see below).

## Finding keymaps

**`lua/config/plugins/keyhelp.lua`** — searchable keymap browsers under **`<leader>k`**,
plus **`:Keys [ctrl|alt|leader|fn]`**.

| Key | Shows |
|---|---|
| `<leader>kc` | **Ctrl combos** |
| `<leader>ka` | Alt/Meta combos |
| `<leader>kk` | Everything |
| `<leader>kl` | Leader maps |
| `<leader>kf` | Function keys |
| `<leader>kn` / `ki` / `kx` / `kt` | which-key root for normal / insert / visual / terminal |
| `<leader>kb` | Buffer-local only (same as `<leader>?`) |

**Why which-key alone isn't enough:** which-key only pops up for a *prefix* — it waits
after `<leader>` or `<C-w>` and lists what may follow. A single-keypress mapping like
`<C-s>` or `<C-d>` fires immediately, so there is nothing to disambiguate and no popup
ever appears. No which-key setting changes that; you need a browser, which is what
`<leader>kc` is. Telescope's `keymaps` builtin reads live from `nvim_get_keymap()`, so
these lists cannot drift from what is actually bound.

Its default mode list (`n, i, c, x`) drops visual/select/op-pending/terminal maps, so
`keyhelp` passes all eight modes explicitly.

> A mapping only appears with a label if it carries a `desc`. A which-key-only
> annotation (`wk.add`) labels the popup but leaves the real mapping blank, so it stays
> blank in these pickers — see `codeium.lua` for the `maparg()`→`mapset()` round-trip
> that attaches a real `desc` without disturbing the plugin's callback or `expr` flag.

## Notes (Obsidian vault, preview, tables)

Vault: **`$NOTES`** (exported from `~/.config/zsh/.zprofile`, default **`~/notes`**) —
plain Markdown, so the Obsidian desktop app opens the same folder. Replicated
between machines by **Syncthing** over the tailnet; `.stignore` there excludes
`.git` and Obsidian's `workspace.json`.

From a shell, **`notes`** / **`nn`** (`~/.config/zsh/notes.zsh`) is the other front
end: `notes` opens the index, `notes <words>` fuzzy-picks, `notes grep <pat>` opens
on a matching line, `notes today` / `notes new <title>` / `notes cd`. It always
launches Nvim *inside* the vault so Telescope's `find_files`/`live_grep` search the
right tree, and creates notes via `:Obsidian new` so filenames match the ones made
in-editor. `notes help` lists everything.

**`lua/config/plugins/obsidian.lua`** — **obsidian.nvim** (pinned 3.x) under **`<leader>o`**:

| Key | Action | Key | Action |
|---|---|---|---|
| `<leader>oo` | quick switch note | `<leader>ob` | backlinks to this note |
| `<leader>of` | grep the vault | `<leader>ol` | links in this note |
| `<leader>on` | new note | `<leader>oc` | table of contents |
| `<leader>oN` | new from template | `<leader>or` | rename (updates links) |
| `<leader>od` | today's daily note | `<leader>op` | paste image from clipboard |
| `<leader>oy` / `<leader>om` | yesterday / tomorrow | `<leader>oT` | insert template here |
| `<leader>oD` | browse dailies | `<leader>ot` | browse tags |

In a note: **`<CR>`** follows the link under the cursor, **`<C-Space>`** cycles the
checkbox, and `j`/`k` move by screen line (notes soft-wrap). Visual mode:
**`<leader>oe`** extract selection to a new note, **`<leader>ok`** / **`<leader>oK`**
link selection to an existing / new note.

Rendering is **render-markdown.nvim**'s job — obsidian.nvim's own `ui` is disabled
because both draw on the same conceal/extmark ranges. Completion for `[[wiki]]`
links and `#tags` arrives through obsidian.nvim's in-process LSP, so the existing
`nvim_lsp` cmp source picks it up with no extra cmp source registered.

**Preview** — three weights: `<leader>mt` in-buffer (render-markdown), `<leader>mp`
Glow pager, `<leader>mb` **live-preview.nvim** in a real browser (live updates,
mermaid, KaTeX; `<leader>mB` stops the server, `<leader>mf` picks a file).

**Tables** — **vim-table-mode**, auto-enabled for `markdown`/`text`/`gitcommit`: typing
`|` re-aligns the whole table as you go. Maps live under **`<leader>t`** (moved off the
plugin's default `<Leader>t`, which is this config's terminal group): `<leader>tm`
toggle, `<leader>tr` realign, `<leader>tt` tableize a selection, `<leader>tdd` /
`<leader>tdc` delete row / column, `<leader>tic` insert column, `<leader>ts` sort,
`<leader>tfa` add formula. Cell motions `[|` `]|` `{|` `}|` and text objects `ci|` /
`ca|` work inside a table. Corner chars are forced to `|` so output is valid
GitHub/Obsidian Markdown rather than the plugin's default reStructuredText borders.

> Ordering note: vim-table-mode is Vimscript and binds its maps the moment `vim.pack`
> sources it, so its `g:table_mode_*` options are set in `table_mode.prelude()`, called
> from **`init.lua`** *before* `config.pack`. Setting them in `setup()` silently no-ops.

## Language smoke tests

Open files under **`lang-samples/`** (see **`lang-samples/README.md`**) to verify LSP, Tree-sitter, and format-on-save without a full app repo.

## Formatting (Conform + Mason tools)

**`lua/config/plugins/format.lua`** — Prettier (web, JSON, markdown, …), **yamlfmt** for plain / Docker Compose YAML, **Ruff** for Python, **goimports** + **gofmt** for Go (needs **Go** on `PATH` for `gofmt`), **Stylua** (Lua), **shfmt** (shell), **Taplo** (TOML); Ansible YAML skips Prettier (ansiblels + ansible_lint).

**`lua/config/plugins/mason.lua`** — CLIs such as `prettier`, `ruff`, `stylua`, `shfmt`, `shellcheck`, `goimports`, `golangci-lint`, `hadolint`, `ansible-lint`, `actionlint`, `yamlfmt`, `yamllint`, `glow`.

## Git / diagnostics / find

- **Gitsigns** (`]c` / `[c`, `<leader>gs` / `<leader>gr` / … in git buffers).
- **Diffview** — `<leader>go` / `<leader>gO` / `<leader>gh` / `<leader>gH`.
- **Diagnostics** — `]d` / `[d`, `<leader>df`, `<leader>dl`; **Trouble** under `<leader>x`.
- **Telescope** — `<leader>f…` (fzf-native sorter when built).

## Tree-sitter

**`lua/config/plugins/treesitter.lua`** — Installs missing parsers after startup (capped parallelism). First run after adding languages can still compile for a while; use **`:TSLog`** if something fails.

## Docs (browser / Zeal)

**`lua/config/core/docs.lua`** — `<leader>cd` / `<leader>cz`, `:Docs`, `<leader>c.`. Optional **`g:docs_zeal_docsets`** overrides per filetype.
