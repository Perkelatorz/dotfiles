# Neovim

Layout: **`init.lua`**, **`lua/config/core/`** (options, spell, docs, keymaps, autocmds, colorscheme), **`lua/config/pack.lua`** (plugins via **`vim.pack`**), **`lua/config/plugins/`** (each plugin’s `setup()`).

**Leader:** `<Space>`.

**OS packages (Arch):** managed in **yadm** — see **`~/.config/yadm/packages/core.pkgs`** (Neovim block) and run **`yadm bootstrap`**. **Mason / LSP** still install into `~/.local/share/nvim/mason` when you use Neovim.

**Dependencies & reinstall:** see **`DEPENDENCIES.md`**. To wipe downloaded plugins, Mason, Tree-sitter, and Nvim cache then reinstall on next start: **`~/.config/nvim/scripts/reset-nvim-data.sh`** (use **`--yes`** for non-interactive; **`--reset-lock`** to drop **`nvim-pack-lock.json`** too).

## Plugins and lockfile

Declare repos in **`lua/config/pack.lua`** (`:help vim.pack`). On multiple machines, commit **`nvim-pack-lock.json`** (e.g. with yadm) so every host gets the same revisions. After changing the pack list, restart Nvim so the lockfile can refresh. Upgrades: **`:lua vim.pack.update()`** (`:help vim.pack.update()`).

## LSP (Mason)

**`lua/config/plugins/lsp.lua`** — `mason-lspconfig` installs:

`lua_ls`, `ts_ls`, `eslint`, `svelte`, `tailwindcss`, `gopls`, `pyright`, `dockerls`, `docker_compose_language_service`, `ansiblels`, `rust_analyzer`, `vue_ls`, `bashls`, `taplo`, `html`, `jsonls`, `cssls`, `graphql`, `marksman`, `yamlls`.

**Nix / `.nix`:** **`nil_ls`** runs only if a **`nil`** binary is on **`PATH`** (e.g. AUR **`nil-git`**). Mason’s **`nil`** package is not used (it requires the Nix package manager to build).

**YAML:** **`yamlls`** (schemas) + **`yamlfmt`** via Conform + **`yamllint`** / **`ansible_lint`** via nvim-lint on save. **`<leader>cf`** format, **`<leader>cl`** lint.

**Markdown:** **render-markdown.nvim**; **`<leader>mp`** Glow preview (split term); **`<leader>mt`** / **`<leader>mv`** toggle / preview rendering.

**CSV/TSV:** **csvview.nvim** (auto under ~12k lines); **`<leader>cv`** toggles.

Use filetypes **`yaml.ansible`** and **`yaml.docker-compose`** where relevant (see **`lang-samples/`** modelines).

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
