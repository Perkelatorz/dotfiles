# Language samples (Neovim smoke tests)

Small files under **`~/.config/nvim/lang-samples/`** so you can verify **Tree-sitter**, **LSP**, **Conform** (format on save), and **Mason** binaries without opening a real project.

## How to test

1. Run **`:Mason`** once and let **`mason-tool-installer`** finish (or install missing packages manually).
2. Open a file from this tree (paths below are relative to `lang-samples/`).
3. Check **`:LspInfo`** — expect the language server(s) listed in the parent Neovim **`README.md`** for that stack.
4. Edit a line and **`:w`** — formatters should run where configured (Prettier, **yamlfmt**, Ruff, Stylua, shfmt, Taplo, goimports+gofmt, …). YAML also runs **yamllint** after write; Dockerfiles **hadolint**.
5. **`:checkhealth`** — catch missing host tools (e.g. **`gofmt`** needs Go on `PATH`).

## Layout

| Path | Intent |
|------|--------|
| `sample.lua` | `lua_ls`, Stylua |
| `sample.py` | `pyright`, Ruff format |
| `sample.go` | `gopls`, goimports + gofmt |
| `Dockerfile` | `dockerls` |
| `docker-compose.yml` | modeline → `yaml.docker-compose` + `docker_compose_language_service` |
| `playbook.yml` | modeline → `yaml.ansible` + `ansiblels` |
| `sample.csv` | **csvview** tabular view + Tree-sitter `csv` |
| `sample.yaml` | plain YAML → **`yamlls`**, **`yamlfmt`** on save, **`yamllint`** after write |
| `sample.sh` | `bashls`, shfmt |
| `sample.toml` | `taplo` |
| `sample.js` | `eslint`, Prettier (plain JS) |
| `sample.json` / `sample.css` / `sample.scss` / `sample.html` | `jsonls`, `cssls`, Prettier, `html` |
| `sample.graphql` | `graphql` |
| `sample.sql` | Tree-sitter only unless you add `sqlls` / etc. |
| `sample.md` | Prettier + **marksman** (links, headings) |
| `rust/` | minimal **Cargo** project → `rust_analyzer` |
| `nix/` | `flake.nix` — Tree-sitter `nix`; **`nil_ls`** only if **`nil`** is on `PATH` (not via Mason) |
| `web/` | `package.json`, `pnpm-lock.yaml`, `tsconfig.json`, `eslint.config.mjs`, `tailwind.config.js`, `svelte.config.js`, `sample.{ts,svelte,vue}`, `index.html` → **svelte**, **eslint**, **ts_ls**, **tailwindcss**, **vue_ls** |
| `.github/workflows/ci.yml` | optional **actionlint** on real GitHub Actions YAML |

## Notes

- **Ansible** / **Compose** filetypes often need the **modeline** at the top of the sample file unless a filetype plugin sets them.
- **Nix** samples: evaluating a flake still needs the **`nix`** tool if you run **`nix build`** etc. from a shell; Neovim does not install the Nix package manager. For LSP in-editor, install a **`nil`** binary (e.g. AUR **`nil-git`**) or edit without `nil_ls` (Tree-sitter highlighting remains).
- **Rust** analyzer wants a **`Cargo.toml`** at the crate root (`rust/`).
