# Neovim Configuration Documentation

> **Last Updated:** 2025  
> **Neovim Version:** 0.9+

---

## Table of Contents

1. [Overview](#overview)
2. [Installation](#installation)
3. [Core Configuration](#core-configuration)
4. [Plugin Manager](#plugin-manager)
5. [Language Support](#language-support)
6. [Plugin Documentation](#plugin-documentation)
7. [Keybindings Reference](#keybindings-reference)
8. [Troubleshooting](#troubleshooting)

---

## Overview

This Neovim configuration is optimized for multi-language development with a focus on:

- **Languages:** Python, Go, C#, JavaScript/TypeScript, Bash, PowerShell
- **DevOps:** Docker, Ansible, Kubernetes (Helm), Terraform
- **Features:** LSP, Testing, Debugging, AI assistance, Git integration
- **Philosophy:** Minimal, fast, and keyboard-driven workflow

---

## Installation

### Prerequisites

```bash
# Neovim 0.9+
nvim --version

# Required tools
git --version
node --version  # For many LSP servers
python3 --version  # For Python support
go version  # For Go support
```

### Setup

```bash
# Backup existing config
mv ~/.config/nvim ~/.config/nvim.backup

# Clone or copy this configuration
cp -r /path/to/this/config ~/.config/nvim
# Or if using git:
# git clone <your-repo> ~/.config/nvim

# Launch Neovim (plugins will auto-install)
nvim
```

### Post-Installation

1. **Mason will auto-install:** LSP servers, linters, formatters
2. **Treesitter will install:** Language parsers
3. **Run health check:** `:checkhealth`

---

## Core Configuration

### File Structure

```
~/.config/nvim/
├── init.lua                    # Entry point
├── lazy-lock.json             # Plugin version lock
└── lua/nvim/
    ├── core/
    │   ├── init.lua           # Core module loader
    │   ├── options.lua        # Vim options
    │   ├── keymaps.lua        # Core keymaps
    │   ├── filetype-settings.lua  # Language-specific settings
    │   ├── colorscheme.lua    # Custom colorscheme
    │   ├── docs.lua           # Documentation search module
    │   ├── docs-config.lua    # Documentation configuration
    │   └── utils.lua          # Utility functions
    └── plugins/
        ├── lazy.lua           # Plugin loader (lazy.nvim)
        ├── lsp/               # LSP configuration
        │   ├── lspconfig.lua
        │   └── mason.lua
        └── *.lua              # Individual plugin configs
```

### Core Options (`options.lua`)

Key settings configured:

- Line numbers (relative + absolute)
- Indentation (2 spaces default, language-specific overrides)
- Search (incremental, ignore case with smart case)
- Clipboard integration with system
- Split behavior (right/below)
- Backup/swap file management

### Filetype Settings (`filetype-settings.lua`)

Language-specific configurations:

| Language | Indent   | Line Width | Special Settings       |
| -------- | -------- | ---------- | ---------------------- |
| Python   | 4 spaces | 88 chars   | PEP 8 compliant        |
| Go       | Tabs (4) | 120 chars  | gofmt compatible       |
| C#       | 4 spaces | 120 chars  | .NET conventions       |
| JS/TS    | 2 spaces | 100 chars  | Prettier compatible    |
| Bash/PS  | 2 spaces | 100 chars  | Shell script standards |
| YAML     | 2 spaces | 80 chars   | Ansible/K8s friendly   |

---

## Plugin Manager

### Lazy.nvim

**Purpose:** Fast, modern plugin manager with lazy-loading

**Features:**

- Automatic plugin installation
- Lazy loading by filetype, command, or event
- Lock file for reproducible environments
- Built-in profiling (`:Lazy profile`)

**Commands:**

- `:Lazy` - Open plugin manager UI
- `:Lazy sync` - Update all plugins
- `:Lazy clean` - Remove unused plugins
- `:Lazy profile` - View startup performance

---

## Language Support

### LSP Servers (via Mason)

| Language              | LSP Server        | Features                    |
| --------------------- | ----------------- | --------------------------- |
| Python                | `pyright`         | Type checking, IntelliSense |
| Go                    | `gopls`           | Full Go language support    |
| C#                    | `omnisharp`       | .NET development            |
| JavaScript/TypeScript | `ts_ls`, `eslint` | Modern JS/TS support        |
| Bash                  | `bashls`          | Shell script analysis       |
| PowerShell            | `powershell_es`   | PowerShell scripting        |
| Docker                | `dockerls`        | Dockerfile support          |
| Ansible               | `ansiblels`       | Playbook validation         |
| Terraform             | `terraformls`     | IaC support                 |
| JSON                  | `jsonls`          | Schema validation           |
| YAML                  | `yamlls`          | Schema validation           |
| XML                   | `lemminx`         | XML support                 |
| Markdown              | `marksman`        | Markdown LSP                |

### Linters & Formatters

| Tool            | Purpose          | Languages          |
| --------------- | ---------------- | ------------------ |
| `black`         | Formatter        | Python             |
| `ruff`          | Linter/Formatter | Python             |
| `isort`         | Import sorter    | Python             |
| `mypy`          | Type checker     | Python             |
| `gofumpt`       | Formatter        | Go                 |
| `goimports`     | Import manager   | Go                 |
| `golangci-lint` | Linter           | Go                 |
| `csharpier`     | Formatter        | C#                 |
| `prettier`      | Formatter        | JS/TS/JSON/YAML/MD |
| `stylua`        | Formatter        | Lua                |
| `shfmt`         | Formatter        | Bash/Shell         |
| `ansible-lint`  | Linter           | Ansible            |
| `hadolint`      | Linter           | Dockerfile         |
| `yamllint`      | Linter           | YAML               |
| `markdownlint`  | Linter           | Markdown           |
| `tflint`        | Linter           | Terraform          |

### Treesitter Parsers

Syntax highlighting for:

- Python, Go, C#, JavaScript, TypeScript, TSX
- Bash, PowerShell, Lua, Vim
- JSON, YAML, XML, TOML, Markdown
- Dockerfile, HCL (Terraform), Helm
- HTML, CSS, GraphQL
- Git (commit, rebase, diff, config)

---

## Plugin Documentation

### 🎨 UI & Appearance

#### **alpha.nvim**

- **Purpose:** Startup dashboard
- **Features:** Quick access to recent files, sessions, and commands
- **Keybindings:** Automatic on startup

#### **lualine.nvim**

- **Purpose:** Statusline
- **Features:** Git branch, diagnostics, file info, LSP status
- **Sections:** Mode, branch, diff, diagnostics, filename, filetype, location
- **Styling:** Uses theme colors from `_G.alabaster_colors` for consistent theming

#### **indent-blankline.nvim**

- **Purpose:** Indentation guides
- **Features:** Visual indent levels, scope highlighting

#### **which-key.nvim**

- **Purpose:** Keybinding helper and menu
- **Features:** Shows available keybindings when pressing `<leader>`
- **Styling:** Uses theme colors (`fg1` for text, colored icons/groups)
- **Trigger:** Automatically shows when pressing `<leader>`

#### **dressing.nvim**

- **Purpose:** Better UI for `vim.ui.select` and `vim.ui.input`
- **Features:** Improved prompts and selection menus

#### **colorscheme.lua**

- **Purpose:** Fully custom colorscheme with complete control
- **Theme:** Dark Alabaster-inspired with bright, high-contrast colors
- **Color System:**
  - **Base colors:** `bg0-3` (backgrounds), `fg0-3` (foregrounds)
  - **Syntax colors:** `color0-color12` (numeric names for easy changes)
  - **UI colors:** `ui0-ui3` (gray scale)
- **Features:**
  - All colors defined in one place
  - Numeric color names allow changing values without updating variable names
  - Colors exported globally via `_G.alabaster_colors` for plugin integration
  - Automatic theme application to all UI elements (Telescope, lualine, which-key, etc.)
- **Color Palette:**
  - `color0`: Errors (red)
  - `color1`: Comments, hints (bright green)
  - `color2`: Strings (light green)
  - `color3`: Classes, types (night evergreen)
  - `color4`: Keywords, constants (purple)
  - `color5`: Numbers, warnings (orange)
  - `color6`: Functions (Python yellow)
  - `color7`: Function definitions (brighter yellow)
  - `color8`: Operators (lime-yellow green)
  - `color9`: Symbols (magenta)
  - `color10`: Variables, builtins (cyan)
  - `color11`: Brackets (blue)
  - `color12`: Punctuation (bright cyan)

---

### 📁 File Management

#### **nvim-tree.lua**

- **Purpose:** File explorer
- **Features:** Tree view, git integration, file operations
- **Keybindings:**
  - `<leader>ee` - Toggle file explorer
  - `<leader>ef` - Toggle on current file
  - `<leader>ec` - Collapse all folders
  - `<leader>er` - Refresh explorer
- **Tree Keybindings:**
  - `a` - Create file/folder
  - `d` - Delete
  - `r` - Rename
  - `x` - Cut
  - `c` - Copy
  - `p` - Paste
  - `y` - Copy name
  - `Y` - Copy relative path
  - `gy` - Copy absolute path
  - `<CR>` - Open file
  - `o` - Open file (no window picker)
  - `<Tab>` - Preview file
  - `I` - Toggle hidden files
  - `H` - Toggle dotfiles
  - `R` - Refresh

#### **oil.nvim**

- **Purpose:** Edit filesystem like a buffer
- **Features:** Direct file manipulation, buffer-style editing
- **Keybindings:**
  - `<leader>..` - Open parent directory in oil
  - `<leader>.f` - Open oil in floating window

#### **telescope.nvim**

- **Purpose:** Fuzzy finder
- **Features:** File search, grep, buffers, git integration
- **Styling:** Uses theme colors from colorscheme.lua
- **Keybindings:**
  - `<leader>ff` - Find files in cwd
  - `<leader>fr` - Recent files
  - `<leader>fs` - Live grep (search string)
  - `<leader>fc` - Grep word under cursor
  - `<leader>ft` - Find todos
  - `<leader>fb` - Browse buffers
- **Telescope Keybindings:**
  - `<C-k>/<C-j>` - Navigate up/down
  - `<C-q>` - Send to quickfix
  - `<CR>` - Select
  - `<C-x>` - Open in horizontal split
  - `<C-v>` - Open in vertical split
  - `<C-t>` - Open in new tab

#### **arrow.nvim**

- **Purpose:** File bookmarks
- **Keybindings:**
  - `;` - Open bookmarks
  - `m` - Buffer bookmarks

#### **docs.lua** (Documentation Search)

- **Purpose:** Smart documentation search with context detection
- **Features:**
  - Automatic docset detection based on filetype and imports
  - Support for Zeal and DevDocs
  - Official documentation search with DuckDuckGo bangs
  - Web search fallback
  - Telescope-based picker with icons
- **Keybindings:**
  - `<leader>zd` - Zeal documentation search
  - `<leader>zv` - DevDocs documentation search
  - `<leader>zp` - Python pydoc (terminal split)
  - `<leader>zs` - Web search (editable query)
- **Configuration:** `docs-config.lua` - Array-based configuration for filetypes and docsets
- **Supported Languages:** Python, JavaScript/TypeScript, Go, C#, Lua, Bash, and more

---

### 🔧 LSP & Completion

#### **mason.nvim**

- **Purpose:** LSP server, linter, formatter installer
- **Command:** `:Mason`
- **Features:** Auto-install configured tools
- **Installed Tools:** See [Language Support](#language-support)

#### **nvim-lspconfig**

- **Purpose:** LSP client configuration
- **Features:** Language server setup, keybindings, diagnostics, inlay hints
- **Keybindings:**
  - `<leader>gd` - Go to definition
  - `gD` - Go to declaration
  - `gi` - Go to implementation
  - `gt` - Go to type definition
  - `gR` - Show references
  - `<leader>k` - Hover documentation
  - `<leader>ca` - Code actions
  - `<leader>rn` - Rename symbol
  - `<leader>rs` - Restart LSP
  - `<leader>D` - Show buffer diagnostics
  - `[d` - Previous diagnostic
  - `]d` - Next diagnostic
  - `<leader>uh` - Toggle inlay hints (on by default)
  - `<leader>uv` - Toggle virtual text diagnostics (off by default)

#### **nvim-cmp**

- **Purpose:** Autocompletion engine
- **Sources:** LSP, buffer, path, snippets
- **Keybindings:**
  - `<C-k>` - Previous suggestion
  - `<C-j>` - Next suggestion
  - `<C-b>` - Scroll docs up
  - `<C-f>` - Scroll docs down
  - `<C-Space>` - Show completion
  - `<C-e>` - Close completion
  - `<CR>` - Confirm selection
  - `<Tab>` - Next item or expand snippet
  - `<S-Tab>` - Previous item

#### **conform.nvim** (`formatting.lua`)

- **Purpose:** Code formatting
- **Features:** Format on save, multiple formatters per filetype
- **Keybinding:** `<leader>mp` - Format file or range
- **Formatters by Language:** See [Linters & Formatters](#linters--formatters)

#### **schemastore.nvim**

- **Purpose:** JSON/YAML schema validation
- **Features:** Auto-completion for config files (package.json, docker-compose.yml, etc.)
- **Supported Schemas:** 600+ schemas including:
  - `package.json`, `tsconfig.json`
  - `docker-compose.yml`
  - `.ansible-lint`, `ansible-playbook`
  - `.prettierrc`, `.eslintrc`
  - GitHub Actions, GitLab CI

---

### 🧪 Testing

#### **neotest.nvim**

- **Purpose:** Test runner framework
- **Adapters:**
  - `neotest-python` - pytest
  - `neotest-go` - Go tests
  - `neotest-jest` - Jest (JavaScript)
  - `neotest-vitest` - Vitest (JavaScript)
- **Keybindings:**
  - `<leader>tr` - Run nearest test
  - `<leader>tf` - Run current test file
  - `<leader>td` - Debug nearest test
  - `<leader>ts` - Stop test
  - `<leader>ta` - Attach to test
  - `<leader>tw` - Toggle watch mode
  - `<leader>tS` - Toggle test summary
  - `<leader>to` - Show test output
  - `<leader>tO` - Toggle output panel
  - `[T` - Previous failed test
  - `]T` - Next failed test

---

### 🐛 Debugging

#### **nvim-dap**

- **Purpose:** Debug Adapter Protocol client
- **Features:** Breakpoints, step debugging, REPL, variable inspection
- **Keybindings:**
  - `<leader>db` - Toggle breakpoint
  - `<leader>dB` - Conditional breakpoint
  - `<leader>dc` - Continue/Start
  - `<leader>di` - Step into
  - `<leader>do` - Step over
  - `<leader>dO` - Step out
  - `<leader>dr` - Open REPL
  - `<leader>dl` - Run last session
  - `<leader>dt` - Terminate
  - `<leader>du` - Toggle UI
  - `<leader>dh` - Hover
  - `<leader>dp` - Preview
  - `<leader>df` - Show frames
  - `<leader>ds` - Show scopes

#### **nvim-dap-ui**

- **Purpose:** UI for nvim-dap
- **Features:** Scopes, breakpoints, stacks, watches, console
- **Auto-opens:** On debug start

#### **nvim-dap-virtual-text**

- **Purpose:** Show variable values inline
- **Features:** Virtual text during debugging

#### **dap-python**

- **Purpose:** Python debugging
- **Debugger:** debugpy
- **Keybindings:**
  - `<leader>dpt` - Debug test method
  - `<leader>dpc` - Debug test class
  - `<leader>dps` - Debug selection (visual mode)

#### **dap-go**

- **Purpose:** Go debugging
- **Debugger:** delve
- **Keybindings:**
  - `<leader>dgt` - Debug Go test
  - `<leader>dgl` - Debug last Go test

---

### 🤖 AI & Assistance

#### **codecompanion.nvim**

- **Purpose:** AI coding assistant
- **Features:** Chat, inline prompts, code actions
- **Keybindings:**
  - `<leader>aa` - CodeCompanion actions
  - `<leader>ac` - Toggle chat
  - `<leader>ai` - Add selection to chat (visual)
  - `<leader>at` - Open chat
  - `<leader>ap` - Inline prompt

---

### 🌐 HTTP Client

#### **kulala.nvim**

- **Purpose:** HTTP client (like Postman/REST Client)
- **Features:** Send HTTP requests from `.http` files
- **Keybindings:**
  - `<leader>kr` - Run request
  - `<leader>kt` - Toggle view
  - `<leader>kp` - Previous request
  - `<leader>kn` - Next request
  - `<leader>ki` - Inspect request
  - `<leader>kc` - Copy as cURL
  - `<leader>ks` - Open scratchpad
  - `<leader>kq` - Close view
- **File Format:** `.http` files
- **Example:**

  ```http
  ### Get users
  GET https://api.example.com/users
  Content-Type: application/json

  ### Create user
  POST https://api.example.com/users
  Content-Type: application/json

  {
    "name": "John Doe",
    "email": "john@example.com"
  }
  ```

---

### 📝 Markdown

#### **markdown-preview.nvim**

- **Purpose:** Live markdown preview in browser
- **Features:** Real-time rendering, dark theme, math support
- **Keybindings:**
  - `<leader>mv` - Toggle preview
  - `<leader>ms` - Stop preview
- **Supported:** GitHub Flavored Markdown, KaTeX math, Mermaid diagrams

---

### 🔀 Git Integration

#### **gitsigns.nvim**

- **Purpose:** Git decorations and hunk operations
- **Features:** Line blame, diff view, hunk staging
- **Keybindings:**
  - `<leader>hs` - Stage hunk
  - `<leader>hr` - Reset hunk
  - `<leader>hS` - Stage buffer
  - `<leader>hR` - Reset buffer
  - `<leader>hu` - Undo stage hunk
  - `<leader>hp` - Preview hunk
  - `<leader>hb` - Blame line
  - `<leader>hB` - Toggle line blame
  - `<leader>hd` - Diff this
  - `<leader>hD` - Diff this ~
  - `[h` - Previous hunk
  - `]h` - Next hunk

#### **lazygit.nvim**

- **Purpose:** LazyGit integration
- **Keybinding:** `<leader>lg` - Open LazyGit
- **Requires:** `lazygit` installed

---

### 🛠️ Editing Enhancements

#### **nvim-autopairs**

- **Purpose:** Auto-close brackets, quotes, etc.
- **Features:** Smart pairing, integration with nvim-cmp

#### **nvim-surround**

- **Purpose:** Surround text with brackets, quotes, tags
- **Keybindings:**
  - `ys{motion}{char}` - Add surrounding
  - `ds{char}` - Delete surrounding
  - `cs{old}{new}` - Change surrounding
- **Examples:**
  - `ysiw"` - Surround word with quotes
  - `ds"` - Delete surrounding quotes
  - `cs"'` - Change " to '

#### **substitute.nvim**

- **Purpose:** Enhanced substitute/replace
- **Keybindings:**
  - `gs` - Substitute with motion/visual
  - `gss` - Substitute line
  - `gsS` - Substitute to end of line
  - `<leader>s` - Substitute range operator
  - `<leader>ss` - Substitute word

#### **Comment.nvim**

- **Purpose:** Smart commenting
- **Keybindings:**
  - `gcc` - Toggle line comment
  - `gbc` - Toggle block comment
  - `gc{motion}` - Comment motion
  - `gb{motion}` - Block comment motion
- **Visual Mode:**
  - `gc` - Comment selection
  - `gb` - Block comment selection

---

### 🔍 Navigation & Search

#### **nvim-spectre**

- **Purpose:** Project-wide search and replace
- **Features:** Find and replace across multiple files
- **Keybindings:**
  - `<leader>sr` - Replace in files (Spectre)
  - `<leader>sw` - Search current word (Spectre)
  - `<leader>sf` - Search in current file (Spectre)

#### **trouble.nvim**

- **Purpose:** Pretty diagnostics, references, quickfix list
- **Keybindings:**
  - `<leader>xw` - Workspace diagnostics
  - `<leader>xd` - Document diagnostics
  - `<leader>xq` - Quickfix list
  - `<leader>xl` - Location list
  - `<leader>xt` - Todos

#### **todo-comments.nvim**

- **Purpose:** Highlight and search TODO comments
- **Keywords:** `TODO`, `HACK`, `WARN`, `PERF`, `NOTE`, `FIX`
- **Keybindings:**
  - `[t` - Previous todo
  - `]t` - Next todo
  - `<leader>ft` - Search todos (Telescope)

#### **nvim-treesitter**

- **Purpose:** Advanced syntax highlighting and text objects
- **Features:** Incremental selection, indentation, folding, text objects
- **Keybindings:**
  - `<C-space>` - Init/increment selection
  - `<C-backspace>` - Decrement selection
  - `af/if` - Around/inside function
  - `ac/ic` - Around/inside class
  - `aa/ia` - Around/inside argument
  - `]m/[m` - Next/previous method
  - `]]/[[` - Next/previous class

#### **flash.nvim**

- **Purpose:** Enhanced navigation with labels
- **Features:** Jump to any visible location with labels
- **Keybindings:**
  - `<leader>j` - Flash jump
  - `<leader>S` - Flash Treesitter

#### **mini.ai**

- **Purpose:** Extended text objects
- **Features:** Additional text objects for better editing
- **Keybindings:**
  - `ao/io` - Around/inside block/conditional/loop

---

### 🐳 DevOps Tools

#### **vim-helm**

- **Purpose:** Kubernetes Helm chart support
- **Features:** Syntax highlighting for Helm templates
- **File Detection:** `*/templates/*.yaml`, `*.gotmpl`

#### **powershell.vim** (`powershell.lua`)

- **Purpose:** PowerShell syntax and support
- **Features:** Syntax highlighting, indentation

#### **csvview.nvim**

- **Purpose:** CSV file viewer
- **Keybinding:** `<leader>cs` - Toggle CSV view
- **Features:** Column alignment, header highlighting

---

### 💾 Session Management

#### **auto-session**

- **Purpose:** Automatic session management
- **Features:** Save/restore sessions per directory
- **Keybindings:**
  - `<leader>wr` - Restore session
  - `<leader>ws` - Save session
- **Auto-save:** On exit

---

## Keybindings Reference

### Leader Key

**Leader:** `<Space>`

### Quick Reference by Category

#### Core Navigation

| Key          | Action                  |
| ------------ | ----------------------- |
| `<leader>nh` | Clear search highlights |
| `<leader>+`  | Increment number        |
| `<leader>=`  | Decrement number        |
| `<leader>sc` | Toggle spell check      |

#### AI (CodeCompanion)

| Key          | Action                |
| ------------ | --------------------- |
| `<leader>aa` | CodeCompanion actions |
| `<leader>ac` | Toggle chat           |
| `<leader>ai` | Add to chat (visual)  |
| `<leader>at` | Open chat             |
| `<leader>ap` | Inline prompt         |

#### File Explorer

| Key          | Action                 |
| ------------ | ---------------------- |
| `<leader>ee` | Toggle nvim-tree       |
| `<leader>ef` | Toggle on current file |
| `<leader>ec` | Collapse tree          |
| `<leader>er` | Refresh tree           |
| `<leader>..` | Open parent (oil)      |
| `<leader>.f` | Oil floating window    |

#### Find (Telescope)

| Key          | Action           |
| ------------ | ---------------- |
| `<leader>ff` | Find files       |
| `<leader>fr` | Recent files     |
| `<leader>fs` | Live grep        |
| `<leader>fc` | Grep cursor word |
| `<leader>ft` | Find todos       |
| `<leader>fb` | Browse buffers   |

#### Search & Replace

| Key          | Action                    |
| ------------ | ------------------------- |
| `<leader>sr` | Replace in files (Spectre)|
| `<leader>sw` | Search current word       |
| `<leader>sf` | Search in current file    |

#### Navigation

| Key          | Action           |
| ------------ | ---------------- |
| `<leader>j`  | Flash jump       |
| `<leader>S`  | Flash Treesitter |

#### Format & Markdown

| Key          | Action                  |
| ------------ | ----------------------- |
| `<leader>mp` | Format file/range       |
| `<leader>mv` | Toggle markdown preview |
| `<leader>ms` | Stop markdown preview   |

#### Testing

| Key          | Action               |
| ------------ | -------------------- |
| `<leader>tr` | Run nearest test     |
| `<leader>tf` | Run test file        |
| `<leader>td` | Debug test           |
| `<leader>ts` | Stop test            |
| `<leader>ta` | Attach to test       |
| `<leader>tw` | Toggle watch         |
| `<leader>tS` | Toggle summary       |
| `<leader>to` | Show output          |
| `<leader>tO` | Toggle output panel  |
| `[T`         | Previous failed test |
| `]T`         | Next failed test     |

#### Debugging

| Key           | Action                 |
| ------------- | ---------------------- |
| `<leader>db`  | Toggle breakpoint      |
| `<leader>dB`  | Conditional breakpoint |
| `<leader>dc`  | Continue/Start         |
| `<leader>di`  | Step into              |
| `<leader>do`  | Step over              |
| `<leader>dO`  | Step out               |
| `<leader>dr`  | Open REPL              |
| `<leader>dl`  | Run last               |
| `<leader>dt`  | Terminate              |
| `<leader>du`  | Toggle UI              |
| `<leader>dh`  | Hover                  |
| `<leader>dp`  | Preview                |
| `<leader>df`  | Show frames            |
| `<leader>ds`  | Show scopes            |
| `<leader>dpt` | Debug Python test      |
| `<leader>dpc` | Debug Python class     |
| `<leader>dps` | Debug Python selection |
| `<leader>dgt` | Debug Go test          |
| `<leader>dgl` | Debug last Go test     |

#### HTTP Client

| Key          | Action           |
| ------------ | ---------------- |
| `<leader>kr` | Run request      |
| `<leader>kt` | Toggle view      |
| `<leader>kp` | Previous request |
| `<leader>kn` | Next request     |
| `<leader>ki` | Inspect          |
| `<leader>kc` | Copy as cURL     |
| `<leader>ks` | Open scratchpad  |
| `<leader>kq` | Close view       |

#### Git Hunks

| Key          | Action        |
| ------------ | ------------- |
| `<leader>hs` | Stage hunk    |
| `<leader>hr` | Reset hunk    |
| `<leader>hS` | Stage buffer  |
| `<leader>hR` | Reset buffer  |
| `<leader>hu` | Undo stage    |
| `<leader>hp` | Preview hunk  |
| `<leader>hb` | Blame line    |
| `<leader>hB` | Toggle blame  |
| `<leader>hd` | Diff this     |
| `<leader>hD` | Diff this ~   |
| `[h`         | Previous hunk |
| `]h`         | Next hunk     |

#### LSP

| Key          | Action                      |
| ------------ | --------------------------- |
| `<leader>gd` | Go to definition            |
| `gD`         | Go to declaration           |
| `gi`         | Go to implementation        |
| `gt`         | Go to type definition       |
| `gR`         | Show references             |
| `<leader>k`  | Hover documentation         |
| `<leader>ca` | Code actions                |
| `<leader>rn` | Rename                      |
| `<leader>rs` | Restart LSP                 |
| `<leader>D`  | Buffer diagnostics          |
| `[d`         | Previous diagnostic         |
| `]d`         | Next diagnostic             |
| `<leader>uh` | Toggle inlay hints          |
| `<leader>uv` | Toggle virtual text diags   |

#### Trouble

| Key          | Action                |
| ------------ | --------------------- |
| `<leader>xw` | Workspace diagnostics |
| `<leader>xd` | Document diagnostics  |
| `<leader>xq` | Quickfix              |
| `<leader>xl` | Location list         |
| `<leader>xt` | Todos                 |

#### Session

| Key          | Action          |
| ------------ | --------------- |
| `<leader>wr` | Restore session |
| `<leader>ws` | Save session    |

#### Documentation Search

| Key          | Action                    |
| ------------ | ------------------------- |
| `<leader>zd` | Zeal documentation search |
| `<leader>zv` | DevDocs documentation     |
| `<leader>zp` | Python pydoc              |
| `<leader>zs` | Web search (editable)     |

#### Misc

| Key          | Action           |
| ------------ | ---------------- |
| `<leader>lg` | Open LazyGit     |
| `<leader>cs` | Toggle CSV view  |
| `;`          | Arrow bookmarks  |
| `m`          | Buffer bookmarks |
| `[t`         | Previous todo    |
| `]t`         | Next todo        |

---

## Troubleshooting

### Common Issues

#### LSP Not Working

```vim
:LspInfo          " Check LSP status
:Mason            " Verify servers installed
:checkhealth lsp  " Run health check
```

#### Treesitter Errors

```vim
:TSUpdate         " Update parsers
:TSInstallInfo    " Check installed parsers
:checkhealth nvim-treesitter
```

#### Plugins Not Loading

```vim
:Lazy             " Check plugin status
:Lazy sync        " Sync plugins
:Lazy clean       " Remove unused
:Lazy restore     " Restore from lockfile
```

#### Formatting Not Working

```vim
:ConformInfo      " Check formatter status
:Mason            " Verify formatters installed
```

#### Debugger Issues

```vim
:DapInstall       " Install debug adapters
:checkhealth dap  " Check DAP health
```

### Performance Issues

```vim
:Lazy profile     " Profile startup time
:checkhealth      " General health check
```

**Tips:**

- Disable unused plugins
- Use lazy loading (filetype, command, event)
- Reduce Treesitter parsers if not needed
- Check for conflicting plugins

### Getting Help

1. **Check health:** `:checkhealth`
2. **Plugin docs:** `:help <plugin-name>`
3. **LSP logs:** `~/.local/state/nvim/lsp.log`
4. **Neovim logs:** `~/.local/state/nvim/log`

---

## Additional Resources

### Documentation

- [Neovim Docs](https://neovim.io/doc/)
- [Lazy.nvim](https://github.com/folke/lazy.nvim)
- [Mason.nvim](https://github.com/williamboman/mason.nvim)
- [nvim-lspconfig](https://github.com/neovim/nvim-lspconfig)

### Learning

- `:Tutor` - Neovim tutorial
- `:help` - Built-in help
- `:help <topic>` - Specific help

### Community

- [r/neovim](https://reddit.com/r/neovim)
- [Neovim Discourse](https://neovim.discourse.group/)

---

**Last Updated:** 2025  
**Configuration Version:** 2.0  
**Maintained by:** You

---

## Recent Updates

### Version 2.0 Changes

- **Custom Colorscheme:** Fully custom colorscheme with numeric color names (`color0-color12`) for easy customization
- **Documentation Search:** New `docs.lua` module with smart context detection and Telescope integration
- **Keybinding Updates:**
  - LSP: `<leader>gd` and `<leader>k` (no longer override defaults)
  - Oil: `<leader>..` and `<leader>.f`
  - Substitute: `gs`, `gss`, `gsS`
- **UI Improvements:**
  - All plugins use theme colors automatically
  - Icons and colors throughout UI elements
  - Inlay hints enabled by default (toggle with `<leader>uh`)
  - Virtual text diagnostics disabled by default (toggle with `<leader>uv`)
- **Color System:**
  - Base colors: `bg0-3`, `fg0-3` (kept original names)
  - Syntax colors: `color0-color12` (numeric for easy changes)
  - UI colors: `ui0-ui3` (following bg/fg pattern)
