# Neovim config — dependencies

Everything this setup expects on the machine, in one place.

## Arch Linux + yadm

**OS packages** for this Neovim setup live in **`~/.config/yadm/packages/core.pkgs`** (section *Neovim: vim.pack…*): `git`, `curl`, `tar`, `gcc`, `make`, `tree-sitter`, plus `neovim`, `go`, `npm`, etc. Install them with your usual **`yadm bootstrap`** (or `pacman` from that list).

After bootstrap, **`warm_neovim_plugins`** in **`~/.config/yadm/bootstrap`** runs **`nvim --headless … +qa`** once so **vim.pack** clones plugins. **Mason** (LSP + formatters) still completes on first interactive session (**`:Mason`**).

**Claude Code CLI** — **`bootstrap`** runs **`install_claude_code_cli`**: downloads **`https://claude.ai/install.sh`** and runs it with **`bash`** (equivalent to the official one-liner). Skip with **`CLAUDE_CODE_SKIP=1 yadm bootstrap`**. Ensure **`~/.local/bin`** is on **`PATH`** if the installer places **`claude`** there.

To wipe only Neovim *data* (plugins under `~/.local/share/nvim/site`, Mason, cache) and reinstall on next Nvim start, use **`~/.config/nvim/scripts/reset-nvim-data.sh`** (see script header).

## Host / OS

| Requirement | Why |
|-------------|-----|
| **Neovim 0.12+** | `vim.pack`, Lua config, built-in LSP. |
| **Git** | `vim.pack` clones plugins; Mason clones/releases. |
| **C compiler + make** (`gcc`, `clang`, …) | Tree-sitter grammars compile to `.so` parsers. |
| **`curl`**, **`tar`** | nvim-treesitter / Mason downloads. |
| **`tree-sitter` CLI ≥ 0.26.1** (optional but recommended) | nvim-treesitter README; some installs still work without it depending on grammar. |

## Optional host tools (not installed by Mason)

| Tool | Why |
|------|-----|
| **Go** (`go`, **`gofmt`** on `PATH`) | Conform runs `gofmt` after `goimports`; Mason only supplies `goimports`. |
| **Node.js** (project-local or global) | Some ESLint/Tailwind setups expect `node_modules`; Mason ships many LSP binaries standalone. |
| **`nil`** (oxalica, on `PATH`) | Optional **Nix** language server for `.nix` / flakes. Install a **prebuilt** `nil` (e.g. AUR **`nil-git`**) if you want LSP features. This config does **not** install Mason’s **`nil`** package (that build expects the **Nix package manager**). Without `nil`, you still get Tree-sitter highlighting for `nix`. |
| **Zeal** (optional) | Offline docs (`docs.lua`). |
| **Spell** | Neovim may download `spelllang` dictionaries once (`:help spell`). |

## Plugins (`lua/config/pack.lua` → `vim.pack`)

Installed under `$XDG_DATA_HOME/nvim/site/pack/core/opt/` (default: `~/.local/share/nvim/site/pack/core/opt/`).

| Repository |
|------------|
| folke/which-key.nvim |
| nvim-lualine/lualine.nvim |
| folke/flash.nvim |
| nvim-tree/nvim-web-devicons |
| williamboman/mason.nvim |
| WhoIsSethDaniel/mason-tool-installer.nvim |
| williamboman/mason-lspconfig.nvim |
| neovim/nvim-lspconfig |
| nvim-treesitter/nvim-treesitter |
| stevearc/conform.nvim |
| mfussenegger/nvim-lint |
| hat0uma/csvview.nvim |
| MeanderingProgrammer/render-markdown.nvim |
| hrsh7th/nvim-cmp |
| hrsh7th/cmp-nvim-lsp |
| hrsh7th/cmp-buffer |
| f3fora/cmp-spell |
| Exafunction/windsurf.nvim |
| nvim-lua/plenary.nvim |
| lewis6991/gitsigns.nvim |
| sindrets/diffview.nvim |
| j-hui/fidget.nvim |
| MunifTanjim/nui.nvim |
| nvim-telescope/telescope.nvim |
| nvim-telescope/telescope-fzf-native.nvim |
| folke/trouble.nvim |
| rcarriga/nvim-notify |
| stevearc/dressing.nvim |
| lukas-reineke/indent-blankline.nvim |
| otavioschwanck/arrow.nvim |
| s1n7ax/nvim-window-picker |
| akinsho/toggleterm.nvim **(pin `v2.13.1`)** |
| nvim-neo-tree/neo-tree.nvim **(pin semver 3.x)** |

Revisions are pinned in **`nvim-pack-lock.json`** (commit that file for reproducible machines).

**`telescope-fzf-native.nvim`** is built with **`make`** on install/update via **`PackChanged`** in **`lua/config/pack_hooks.lua`** (registered from **`init.lua`** before **`vim.pack.add`**).

## Mason — LSP packages (`mason-lspconfig` / `lsp.lua`)

Installed under `$XDG_DATA_HOME/nvim/mason/packages/` (default: `~/.local/share/nvim/mason/packages/`).

lua_ls, ts_ls, eslint, svelte, tailwindcss, gopls, pyright, dockerls, docker_compose_language_service, ansiblels, rust_analyzer, vue_ls, bashls, taplo, html, jsonls, cssls, graphql, marksman, yamlls

**Nix files (`.nix`, flakes):** **`nil_ls`** is enabled only when a **`nil`** executable is already on **`PATH`** (see `lsp.lua`). It is **not** installed via Mason here.

## Mason — CLI tools (`mason-tool-installer` / `mason.lua`)

prettier, ruff, stylua, shfmt, shellcheck, hadolint, ansible-lint, goimports, golangci-lint, actionlint, yamlfmt, yamllint, glow

## Tree-sitter grammars (`treesitter.lua`)

Parsers are installed under `$XDG_DATA_HOME/nvim/site/parser/` (and queries alongside under `site/`). List in config:

lua, vim, vimdoc, bash, javascript, typescript, tsx, svelte, html, css, scss, json, yaml, toml, dockerfile, markdown, markdown_inline, python, vue, rust, go, regex, nix, graphql, sql, csv, tsv

## Conform formatters (see `format.lua`)

Prettier (web, JSON, markdown, etc.), **yamlfmt** (plain + Docker Compose YAML), Ruff (Python), goimports + gofmt (Go), Stylua (Lua), shfmt (shell), Taplo (TOML). Ansible YAML skips Prettier (|ansiblels| + |ansible_lint|); **yamlls** validates schemas with formatting delegated to **yamlfmt** where configured.

## Reset and redeploy

From the config directory:

```bash
chmod +x scripts/reset-nvim-data.sh
./scripts/reset-nvim-data.sh --yes          # wipe mason + site + cache; keep lockfile
./scripts/reset-nvim-data.sh --yes --reset-lock   # also remove nvim-pack-lock.json
nvim +qa   # or just open nvim — installs run on startup
```

Then open **`:Mason`** and wait for **`mason-tool-installer`** to finish if anything is still pending.
