# Neovim Quick Reference

Fast lookup for common keybindings and commands.

---

## Essential Keybindings

### Terminal (leader>z)
```
<leader>zt    Toggle terminal (bottom)
<leader>zv    Vertical terminal (right)
<leader>zf    Floating terminal (centered)
<leader>zx    Shutdown all terminals
```

### AI Checkpoint System (For Agentic AI!)
```
<leader>vc    Create checkpoint (single file)
<leader>vr    Restore checkpoint (undo all AI changes!)
<leader>vd    Diff with checkpoint (see what changed)

<leader>vC    Checkpoint all files (before AI agent works)
<leader>vR    Restore all files (undo everything!)
<leader>vS    Show all changes (across all files)
```

### Quick Actions
```
<leader>w     Save file
<leader>W     Save all files
<leader>q     Quit window
<leader>Q     Force quit (discard changes)
<leader>sr    Search and replace word under cursor
```

### File Navigation & Path
```
<leader>ff    Fuzzy find files
<leader>fr    Recent files
<leader>fs    Find string in project
<leader>fc    Find string under cursor
<leader>ft    Find todos
<leader>yp    Yank full path to clipboard
<leader>yr    Yank relative path
<leader>yn    Yank filename
```

### Buffer Management
```
[b / ]b       Previous/Next buffer
<leader>bd    Delete buffer
<leader>bD    Force delete buffer
```

### Tab Management
```
<leader>tn    New tab
<leader>tc    Close tab
<leader>t1-5  Jump to tab 1-5
gt / gT       Next/Previous tab (Vim default)
```

### Code Navigation
```
[d / ]d       Previous/Next diagnostic
[D / ]D       Previous/Next error only
[q / ]q       Previous/Next quickfix
[h / ]h       Previous/Next git hunk
gd            Go to definition (LSP)
gD            Go to declaration (LSP)
gr            Go to references (LSP)
K             Hover documentation (LSP)
```

### Code Actions
```
<leader>ca    Code action
<leader>rn    Rename symbol
<leader>d     Show line diagnostic
<leader>D     Show all diagnostics
<leader>rs    Restart LSP
```

### Git Operations
```
<leader>lg    Open LazyGit
<leader>hs    Stage hunk
<leader>hr    Reset hunk
<leader>hp    Preview hunk
<leader>hb    Blame line
```

### Visual Mode
```
<           Indent left (stays in visual)
>           Indent right (stays in visual)
J           Move lines down
K           Move lines up
p           Paste without yanking
```

### Toggles
```
<leader>ts    Toggle spell check
<leader>tr    Toggle relative numbers
<leader>tw    Toggle line wrap
<leader>tl    Toggle whitespace visibility
<leader>ct    Toggle colorscheme
```

### Spell Checking
```
]s / [s       Next/Previous misspelled word
z=            Spelling suggestions
zg            Add word to dictionary
```

### Explorer
```
<leader>ee    Toggle nvim-tree
<leader>-     Open Oil (floating)
```

---

## Useful Commands

### Performance
```
:StartupTime      Show startup time
:MemoryUsage      Show memory usage
:PluginStats      Show plugin statistics
:checkhealth      Check Neovim health
```

### Treesitter
```
:TSUpdate         Update all parsers
:TSInstall <lang> Install parser
:TSCheckSvelte    Check Svelte parsers
:Inspect          Show highlight group under cursor
:InspectTree      Show syntax tree
```

### LSP
```
:Mason            Open Mason UI
:LspInfo          Show LSP status
:LspRestart       Restart LSP
```

### Terminal
```
:TermToggle       Toggle horizontal terminal
:TermFloat        Toggle floating terminal
```

---

## Which-Key Groups

Press `<leader>` to see:
```
a  󰚩 AI              - AI tools (OpenCode, Codeium)
b  󰓩 Buffer          - Buffer operations
c  󰨞 Code            - Code actions, CSV
d  󰒕 Diff            - Diff operations
e  󰉋 Explorer        - File explorer
f  󰱼 Find            - Fuzzy finding
g  󰬴 Case            - Case conversion
h  󰊢 Git Hunk        - Git operations
l  󰒲 Lazy            - Plugin manager
m  󰍍 Markdown        - Markdown preview
s  󰜁 Svelte          - Svelte templates
t  󰔃 Toggle/Tab      - Toggles & tabs
u  󰔡 UI Toggle       - UI toggles
w  󰁯 Window/Session  - Window & session
x  󰔫 Trouble         - Diagnostics
```

---

## Common Workflows

### Run a Server Quickly
```
<leader>zt              # Open terminal
uvicorn main:app --reload
<leader>zt              # Hide (server keeps running)
<leader>zt              # Check logs
<C-c>                   # Stop server
```

### Search and Replace
```
# Cursor on word
<leader>sr              # Setup replace
new_word<Enter>         # Replace all occurrences
```

### Navigate Errors
```
]d                      # Next diagnostic
]D                      # Next error only
<leader>d               # Show diagnostic details
<leader>ca              # See code actions
```

### Git Workflow
```
<leader>lg              # Open LazyGit
# Or use hunks:
<leader>hs              # Stage hunk
<leader>hp              # Preview changes
<leader>hr              # Reset hunk
```

---

## Tips

- Press `<leader>` and wait - which-key shows all options
- Press `[` or `]` - see all navigation commands
- In terminal: `<Esc><Esc>` to exit insert mode
- Use `:Inspect` to see what color a highlight is
- Tab bar shows at top with file names
- Operators now have subtle blue tint

---

See COMPLETE_GUIDE.md for detailed documentation.
