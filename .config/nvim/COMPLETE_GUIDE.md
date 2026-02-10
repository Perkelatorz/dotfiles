# Complete Neovim Configuration Guide

Comprehensive documentation for your fully-optimized Neovim setup.

---

## Table of Contents

1. [Overview](#overview)
2. [Recent Improvements](#recent-improvements)
3. [Color Theme](#color-theme)
4. [Terminal Management](#terminal-management)
5. [AI Tool Integration](#ai-tool-integration)
6. [Keybindings Reference](#keybindings-reference)
7. [Features & Enhancements](#features--enhancements)
8. [Svelte Development](#svelte-development)
9. [Troubleshooting](#troubleshooting)

---

## Overview

Your Neovim configuration is a fully-featured development environment with:
- **0 new plugins added** (uses existing plugins + native features)
- **100+ quality-of-life improvements**
- **Custom Purpleator color theme** (purple undertones)
- **Smart terminal management**
- **Comprehensive LSP support via Mason**
- **Modern treesitter syntax highlighting**

---

## Recent Improvements

### Fixed Issues
- ✅ Svelte syntax highlighting (updated to treesitter v1.0+ API)
- ✅ Mason LSP configuration (removed deprecated `tsserver`)
- ✅ Which-key icons (consistent and meaningful)

### High-Impact Features (16)
- Persistent undo across sessions
- Highlight on yank (visual feedback)
- Remember cursor position
- Auto-trim trailing whitespace
- Better scrolling (cursor centered)
- 16x faster completion (250ms vs 4000ms)
- Treesitter-based code folding
- Smart line numbers (relative in normal, absolute in insert)

### Medium-Impact Features (15)
- Ripgrep integration (10-100x faster search)
- Mouse support
- Better diff mode (patience algorithm)
- Quickfix/location list navigation
- Diagnostic navigation shortcuts
- Terminal mode improvements
- Better command-line completion

### Final Polish (50+)
- Smart terminal toggle (`<leader>zt`)
- Spell checking enhancements
- Tab management (11 keymaps)
- File optimization (large files, binary, readonly)
- Performance monitoring tools
- Whitespace visualization
- Case conversion helpers
- Config quick edit shortcuts

### Visual Enhancements
- Custom tabline (shows tabs at top)
- Box-drawing window separators
- Rounded LSP borders
- Purple-themed which-key popup
- Custom fold display
- Better fillchars

### AI Tool Integration
- Auto-reload files when external tools edit them
- Checkpoint system for rapid AI iteration
- Smart diff (shows only meaningful changes)
- One-key undo of all AI changes
- Session checkpoints for multi-file edits

---

## Color Theme

### Purpleator Philosophy

**Base color for readability:**
- Variables, properties, identifiers: `#d8d8d8` (soft gray)
- Operators: `#8fa0b0` (subtle blue-gray)
- Parameters: `#c0c0c0` (light gray)
- Punctuation/brackets: `#a8a8a8` (dimmed gray)

**Bright colors for important syntax:**
- Keywords (`if`, `for`, `def`): `#9982d1` (purple)
- Functions: `#FFD343` (yellow)
- Strings: `#9acf9a` (green)
- Numbers: `#dd6a18` (orange)
- Types/Classes: `#5a9a8a` (evergreen)
- Comments: `#6eb03b` (bright green)
- Booleans: `#d067d0` (magenta)
- Builtins: `#77c8c8` (cyan)

**Backgrounds:**
- Main: `#1a1420` (deep purple-black)
- Lighter: `#251d2e`, `#30283c`, `#3d344a`

### Toggle Colorscheme
```
<leader>ct    Toggle between Purpleator and Nightfox
```

---

## Terminal Management

### Quick Toggle
```
<leader>zt    Toggle terminal at bottom (main one!)
<leader>zv    Vertical terminal (right side)
<leader>zf    Floating terminal (centered)
<leader>zx    Shutdown all terminals
```

### Features
- Persistent terminals (survive hide/show)
- Auto-enter insert mode
- Independent terminals (each type separate)
- Perfect for running servers

### Example Workflow
```
<leader>zt
uvicorn main:app --reload
<leader>zt              # Hide (server keeps running!)
# Code while server runs...
<leader>zt              # Check logs
<leader>zt              # Hide again
```

### Inside Terminal
```
<Esc><Esc>    Exit to normal mode
<C-h/j/k/l>   Navigate to other windows
<leader>zt    Hide terminal
```

---

## Keybindings Reference

See QUICK_REFERENCE.md for fast lookup.

### Leader Groups (`<leader>` = space)

| Key | Group | Description |
|-----|-------|-------------|
| `a` | 󰚩 AI | OpenCode, Codeium, AI tools |
| `b` | 󰓩 Buffer | Buffer management |
| `c` | 󰨞 Code | Code actions, CSV |
| `d` | 󰒕 Diff | Diff operations |
| `e` | 󰉋 Explorer | nvim-tree, file explorer |
| `f` | 󰱼 Find | Telescope fuzzy finding |
| `g` | 󰬴 Case | Case conversion |
| `h` | 󰊢 Git Hunk | Git operations |
| `H` | 󰖟 HTTP | HTTP client (Kulala) |
| `l` | 󰒲 Lazy | Plugin manager |
| `m` | 󰍍 Markdown | Markdown preview, formatting |
| `n` | 󰐊 Clear/Number | Clear search, number format |
| `o` | 󰏖 Oil | Oil file manager |
| `r` | 󰑄 Rename/Restart | LSP rename, restart |
| `s` | 󰜁 Svelte | Svelte templates |
| `t` | 󰔃 Toggle/Tab | Toggles, tabs, terminal |
| `u` | 󰔡 UI Toggle | Inlay hints, virtual text |
| `w` | 󰁯 Window/Session | Save, window, session |
| `x` | 󰔫 Trouble | Trouble diagnostics |

### Navigation Pattern (Vim Convention)

All use `[` for previous, `]` for next:

```
[b / ]b    Buffers
[q / ]q    Quickfix (also [Q / ]Q for first/last)
[l / ]l    Location list (also [L / ]L)
[d / ]d    Diagnostics (also [D / ]D for errors only)
[h / ]h    Git hunks
[t / ]t    Todo comments
[s / ]s    Spell checking
```

---

## Features & Enhancements

### Persistent Undo
- Keep undo history across sessions
- Location: `~/.local/share/nvim/undo/`
- 10,000 undo levels

### Auto-Behaviors
- **Highlight on yank** - Flash when copying
- **Remember cursor position** - Jump back where you were
- **Auto-trim whitespace** - On save
- **Auto-reload files** - When changed externally
- **Auto-resize splits** - When window resized
- **Auto-create directories** - When saving new files
- **Auto-disable paste mode** - When leaving insert

### File Optimizations
- **Large files (>1MB)** - Disables folding, undo, syntax for performance
- **Binary files** - Optimized display
- **Read-only files** - Press `q` to close

### Better Scrolling
- Keep 8 lines above/below cursor
- Centered scrolling: `<C-d>`, `<C-u>`, `n`, `N`

### Visual Mode Enhancements
- `<` / `>` - Indent and stay in visual mode
- `J` / `K` - Move lines up/down
- `p` - Paste without yanking replaced text

### Treesitter Folding
```
za    Toggle fold under cursor
zR    Open all folds
zM    Close all folds
zc    Close fold
zo    Open fold
```

---

## Svelte Development

### Syntax Highlighting
- **Status:** ✅ Working with modern treesitter v1.0+ API
- **Parsers installed:** svelte, html, javascript, typescript, css, scss
- **Features:** Full syntax highlighting for embedded languages

### Commands
```
:TSCheckSvelte       Check parser status
:TSInstallSvelte     Install all Svelte parsers
```

### Templates
```
<leader>sc    New Svelte component
<leader>sp    New SvelteKit page
<leader>sl    New SvelteKit layout
```

### LSP
- **Svelte Language Server** - Installed via Mason
- **Emmet** - HTML expansion in Svelte files
- **TailwindCSS** - Auto-completion for Tailwind classes

---

## Performance Monitoring

### Commands
```
:StartupTime     Show startup time in float window
:MemoryUsage     Show current memory usage
:PluginStats     Show plugin count (total/loaded)
:ProfileStart    Start profiling
:ProfileStop     Stop profiling (output: /tmp/nvim-profile.log)
```

---

## Spell Checking

### Auto-Enabled For
- Markdown files
- Git commit messages
- Plain text files

### Navigation
```
]s / [s       Next/Previous misspelled word
z=            Show spelling suggestions
zg            Add word to dictionary
zw            Mark word as misspelled
zug           Remove word from dictionary
```

### Custom Dictionary
Location: `~/.config/nvim/spell/en.utf-8.add`

---

## Whitespace Visualization

### Toggle
```
<leader>tl    Toggle whitespace visibility
```

### Characters Shown
- `→ ` - Tabs
- `·` - Trailing spaces
- `␣` - Non-breaking spaces
- `↴` - End of line
- `›` / `‹` - Text beyond screen

---

## Utility Keybindings

### Copy File Paths
```
<leader>yp    Yank full path
<leader>yr    Yank relative path
<leader>yn    Yank filename
<leader>fr    Recent files (Telescope)
```

### Case Conversion
```
<leader>gu    Uppercase word/selection
<leader>gl    Lowercase word/selection
<leader>g~    Toggle case word/selection
```

### Number Format
```
<leader>nx    Convert to hex view
<leader>nr    Revert from hex view
```

### Diff Shortcuts
```
<leader>dt    Diff this buffer
<leader>do    Turn off diff
<leader>du    Update diff
```

### Config Quick Edit
```
<leader>ev    Edit init.lua
<leader>sv    Source init.lua (reload config)
```

### Window Management
```
<leader>w=    Equalize windows
<leader>w|    Maximize width
<leader>w_    Maximize height
```

---

## LSP Configuration

### Language Servers (via Mason)

**Web Development:**
- ts_ls (TypeScript/JavaScript)
- svelte, html, cssls, cssmodules_ls
- emmet_ls, tailwindcss
- eslint

**Python:**
- pyright (type checking)
- pylsp (documentation)
- ruff (linting)

**Other Languages:**
- lua_ls, gopls, bashls, powershell_es
- omnisharp (C#), dockerls, terraformls
- jsonls, yamlls, lemminx (XML)
- ansiblels, marksman (Markdown)
- typos_lsp, docker_compose_language_service

### Formatters & Linters (via Mason Tool Installer)
- prettier, stylua, isort, ruff, mypy
- golangci-lint, gofumpt, goimports
- ansible-lint, hadolint, markdownlint
- yamllint, csharpier, shfmt, tflint

---

## Treesitter Configuration

### Installed Parsers
Web: html, css, scss, javascript, typescript, tsx, svelte
Config: json, yaml, xml, dockerfile, terraform, hcl
Languages: lua, vim, python, go, c, c_sharp, bash, powershell
Docs: markdown, markdown_inline, vimdoc
Other: gitignore, query

### Features
- Syntax highlighting (auto-enabled)
- Code folding (treesitter-based)
- Smart indentation
- Auto-tag closing (Svelte, HTML, JSX)

---

## Plugin Overview

### Core Plugins
- **lazy.nvim** - Plugin manager
- **mason.nvim** - LSP/tool installer
- **nvim-treesitter** - Syntax highlighting
- **nvim-lspconfig** - LSP configuration
- **nvim-cmp** - Completion engine

### File Management
- **nvim-tree** - File explorer
- **oil.nvim** - Buffer-based file editing
- **telescope.nvim** - Fuzzy finder

### Git Integration
- **gitsigns.nvim** - Git signs in gutter
- **lazygit.nvim** - LazyGit integration

### UI Enhancements
- **which-key.nvim** - Keybinding popup
- **lualine.nvim** - Statusline
- **alpha.nvim** - Dashboard
- **nightfox.nvim** - Alternative colorscheme
- **indent-blankline** - Indent guides
- **nvim-notify** - Notifications

### Code Tools
- **nvim-ts-autotag** - Auto-close tags
- **nvim-autopairs** - Auto-close brackets
- **comment.nvim** - Smart commenting
- **nvim-surround** - Surround text objects
- **flash.nvim** - Jump navigation
- **trouble.nvim** - Diagnostics list
- **todo-comments.nvim** - Highlight TODOs

### Development Tools
- **markdown-preview.nvim** - Markdown preview
- **kulala.nvim** - HTTP client
- **live-server.nvim** - Live server
- **opencode.nvim** - AI assistant
- **codeium.nvim** - AI completion

### Svelte-Specific
- **nvim-svelte-snippets** - Svelte snippets
- **svelte-templates** - Quick templates

---

## Custom Modules

Located in `~/.config/nvim/lua/nvim/core/`:

### options.lua
- All Neovim settings
- Spell checking config
- Whitespace visualization
- Mouse support
- Better diff mode
- Command-line improvements
- Ripgrep integration

### keymaps.lua
- 100+ custom keybindings
- Terminal management
- Quick actions
- Navigation shortcuts
- Visual mode enhancements
- Spell checking
- Tab management
- Case conversion
- And more!

### autocmds.lua
- Highlight on yank
- Remember cursor position
- Auto-trim whitespace
- Auto-reload files
- Auto-resize splits
- Close with 'q' for special buffers
- Terminal auto-settings
- Smart line numbers
- Auto-create directories
- Disable auto-comments
- Auto-disable paste mode
- Large file optimization
- Binary file detection
- Read-only file handling
- Auto-enable spell for text files

### colorscheme.lua
- Custom Purpleator theme
- Complete color definitions
- Toggle with Nightfox
- Purple undertones
- Purposeful color hierarchy

### terminal.lua
- Toggle terminal functions
- Persistent terminal state
- Multiple terminal types
- Smart window management

### performance.lua
- Startup time measurement
- Memory usage tracking
- Plugin statistics
- Profiling helpers

### visual.lua
- Custom tabline rendering
- Box-drawing separators
- Rounded borders
- Custom fold text
- Better fillchars

### tabline.lua
- Visual tab bar
- Shows tab numbers
- Filenames
- Modified indicators
- Clickable tabs

### filetype-settings.lua
- Per-filetype indentation
- Tabstop settings
- Line length guides

---

## Configuration Structure

```
~/.config/nvim/
├── init.lua                    # Entry point
├── lua/nvim/
│   ├── core/
│   │   ├── init.lua           # Load all core modules
│   │   ├── options.lua        # Neovim settings
│   │   ├── keymaps.lua        # Keybindings
│   │   ├── autocmds.lua       # Auto-commands
│   │   ├── colorscheme.lua    # Purpleator theme
│   │   ├── terminal.lua       # Terminal management
│   │   ├── performance.lua    # Performance tools
│   │   ├── visual.lua         # Visual enhancements
│   │   ├── tabline.lua        # Tab bar
│   │   └── filetype-settings.lua
│   ├── plugins/
│   │   ├── init.lua           # Plugin list
│   │   ├── treesitter.lua     # Syntax highlighting
│   │   ├── which-key.lua      # Keybinding popup
│   │   ├── telescope.lua      # Fuzzy finder
│   │   ├── lualine.lua        # Statusline
│   │   └── lsp/
│   │       ├── mason.lua      # LSP installer
│   │       └── lspconfig.lua  # LSP config
│   └── lazy.lua               # Plugin manager setup
└── spell/
    └── en.utf-8.add           # Custom dictionary
```

---

## Troubleshooting

### Svelte Highlighting Not Working
```vim
:TSCheckSvelte              # Check parser status
:TSInstall svelte           # Reinstall parser
:TSUpdate                   # Update all parsers
:checkhealth nvim-treesitter
```

### LSP Not Working
```vim
:LspInfo                    # Check LSP status
:Mason                      # Check installed servers
:LspRestart                 # Restart LSP
```

### Terminal Not Opening
```vim
:TermToggle                 # Try command version
:messages                   # Check for errors
```

### Which-Key Not Showing
```vim
:Lazy reload which-key      # Reload plugin
:checkhealth which-key
```

### Performance Issues
```vim
:StartupTime                # Check startup time
:MemoryUsage                # Check memory
:PluginStats                # See loaded plugins
:Lazy                       # Check plugin status
```

### Colors Look Wrong
```vim
:ColorschemeToggle          # Toggle theme
:lua require('nvim.core.colorscheme').setup()  # Reload theme
```

---

## Advanced Features

### Persistent Undo
- Directory: `~/.local/share/nvim/undo/`
- Undo even after closing files
- 10,000 undo levels

### Ripgrep Search
```vim
:grep pattern               # Search in all files
:grep pattern *.js          # Search in JS files
:grep "exact phrase"        # Search phrase
]q                          # Next result
[q                          # Previous result
```

### Treesitter Folding
Enabled for: JS, TS, Svelte, Python, Go, Lua, Rust, C, C++

### Macro Recording Feedback
- Shows notification when recording starts
- Shows notification when recording stops

### Better Undo Breakpoints
Automatically adds breakpoints at: `,` `.` `!` `?` `;`
- More granular undo in insert mode

### Auto-Behaviors
- Check for file changes on focus
- Resize splits on window resize
- Disable auto-commenting
- Smart line number switching

---

## Customization

### Change Colors
Edit: `lua/nvim/core/colorscheme.lua`

Find the color you want to change:
```lua
vim.api.nvim_set_hl(0, "@keyword", { fg = colors.color4, bold = true })
                                         ^^^^^^^^^^^^
                                         Change this!
```

### Add Keybinding
Edit: `lua/nvim/core/keymaps.lua`

```lua
keymap.set("n", "<leader>x", ":command<CR>", { desc = "Description" })
```

Then add to which-key in `lua/nvim/plugins/which-key.lua`:
```lua
{ "<leader>x", desc = "󰋼 Description" },
```

### Add Language Server
Edit: `lua/nvim/plugins/lsp/mason.lua`

Add to `ensure_installed`:
```lua
"your_language_server",
```

### Add Treesitter Parser
Edit: `lua/nvim/plugins/treesitter.lua`

Add to `ensure_installed`:
```lua
"your_language",
```

---

## File Locations

### Config Files
- Main: `~/.config/nvim/init.lua`
- Core: `~/.config/nvim/lua/nvim/core/`
- Plugins: `~/.config/nvim/lua/nvim/plugins/`

### Data Files
- Plugins: `~/.local/share/nvim/lazy/`
- Parsers: `~/.local/share/nvim/site/parser/`
- Undo: `~/.local/share/nvim/undo/`
- Sessions: `~/.local/share/nvim/sessions/`

### Spell Files
- Dictionary: `~/.config/nvim/spell/en.utf-8.add`

---

## Tips & Tricks

1. **Discover keybindings** - Press `<leader>` and wait
2. **Navigate errors fast** - Use `]D` / `[D` for errors only
3. **Quick terminal** - `<leader>zt` is your best friend
4. **Search project** - `:grep pattern` with ripgrep is super fast
5. **Persistent terminal** - Terminal survives when hidden
6. **Visual mode** - Use `<` / `>` multiple times while selected
7. **Centered search** - `n` and `N` keep cursor centered
8. **Quick save** - `<leader>w` faster than `:w<Enter>`
9. **Fold code** - `zc` to close, `zo` to open
10. **Check health** - `:checkhealth` to diagnose issues

---

## Keybinding Philosophy

1. **Standard Vim keys unchanged** - All default Vim keys work
2. **Enhanced keys are better, not different** - `n` still searches, just centers too
3. **Leader keys for custom actions** - All custom shortcuts use `<leader>`
4. **Bracket keys for navigation** - `[` and `]` for prev/next (Vim convention)
5. **Consistent patterns** - Same icons, same logic across all groups

---

## What Makes This Config Special

✅ **Comprehensive** - 100+ improvements without bloat  
✅ **Fast** - Optimized for performance  
✅ **Beautiful** - Purple theme, consistent icons  
✅ **Well-documented** - Every keymap in which-key  
✅ **Vim-compatible** - Respects Vim conventions  
✅ **Production-ready** - Tested and polished  
✅ **Smart terminal** - Quick access to shell  
✅ **Color hierarchy** - Purposeful syntax colors  
✅ **Zero bloat** - Native features where possible  

---

## Quick Health Check

```vim
:checkhealth
:StartupTime
:MemoryUsage
:PluginStats
:TSCheckSvelte
:LspInfo
:Mason
```

---

## Getting Help

- Press `<leader>` - See all commands
- Press `[` or `]` - See navigation
- `:help <topic>` - Neovim help
- `:WhichKey` - See all keybindings
- Check this guide!

---

**Version:** Neovim 0.11.5  
**Theme:** Purpleator (custom)  
**Plugin Manager:** lazy.nvim  
**LSP Manager:** Mason  
**Status:** Fully optimized and production-ready! 🚀

---

## AI Tool Integration

### Auto-Reload Files

Files automatically reload when changed by external tools (Cursor, OpenCode, etc.):
- **Triggers:** Focus gained, buffer enter, cursor idle (250ms)
- **No manual intervention** - Just switch back to Neovim
- **Visual notification** - Shows which file reloaded
- **Focus preserved** - Stays on your window

### Checkpoint System

**For rapid AI iteration without polluting git history.**

#### Single File Checkpoints
```
<leader>vc    Create checkpoint
<leader>vr    Restore checkpoint (undo all AI changes!)
<leader>vd    Diff with checkpoint (smart - shows only real changes)
<leader>vx    Delete checkpoint
```

#### Session Checkpoints (Multi-File)
```
<leader>vC    Checkpoint all open files
<leader>vR    Restore all files at once
<leader>vS    Show all changes across all files
```

#### Features
- **Auto-checkpoint** - Creates checkpoint on first external change
- **Smart diff** - Ignores line shifts, only shows content changes
- **One-key undo** - `<leader>vr` undoes 20+ AI changes at once
- **Multi-file support** - Handle agentic AI editing 10+ files
- **Visual diff** - Easy-to-read before/after format

#### Workflow: Agentic AI
```
<leader>vC              # Checkpoint all files FIRST
# Let agentic AI edit 10+ files
<leader>vS              # See all meaningful changes
<leader>vR              # Restore all if needed (or keep with :wa)
```

#### Git vs Checkpoint

**Use Git for:**
- Permanent checkpoints you want to keep
- Sharing with team
- Branch-based workflows

**Use Checkpoint for:**
- Rapid AI iteration (try approach 1, 2, 3)
- Lightweight undo without git commits
- In-session experimentation

**Best practice:** Use both
```
git commit -m "Working state"
<leader>vC
# Try AI experiments
<leader>vR / <leader>vR / <leader>vR
# Find the right approach
git commit -m "Final version"
```

