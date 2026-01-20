# Svelte Development Guide

Complete reference for Svelte development in Neovim.

---

## Quick Start

### Syntax Highlighting ✅
- **Status:** Working with treesitter v1.0+
- **Auto-enabled** for `.svelte` files
- Highlights: JavaScript, TypeScript, CSS, HTML, Svelte directives

### LSP Support ✅
- **Svelte Language Server** - Auto-installed via Mason
- **Features:** Autocomplete, diagnostics, hover, formatting
- **Check status:** `:LspInfo` in a `.svelte` file

### Templates

Create new Svelte components quickly:
```
<leader>sc    New component
<leader>sp    New SvelteKit page (+page.svelte)
<leader>sl    New SvelteKit layout (+layout.svelte)
```

---

## Common Snippets

Type these and press Tab:

### Component Structure
```
sbase<Tab>       Full component with script, style, and markup
sscript<Tab>     <script> tag
sstyle<Tab>      <style> tag
```

### Reactivity
```
sreactive<Tab>   $: reactive statement
sstore<Tab>      Writable store
sderived<Tab>    Derived store
```

### Bindings
```
sbind<Tab>       bind:value
sclass<Tab>      class: directive
son<Tab>         on:click handler
```

### Logic Blocks
```
sif<Tab>         {#if condition}
seach<Tab>       {#each items as item}
sawait<Tab>      {#await promise}
```

### SvelteKit
```
spage<Tab>       +page.svelte template
slayout<Tab>     +layout.svelte template
sserver<Tab>     +page.server.ts template
sload<Tab>       load function
sactions<Tab>    form actions
```

---

## Development Workflow

### 1. Start Dev Server
```
<leader>tt              # Open terminal
pnpm dev                # Or npm run dev
<leader>tt              # Hide terminal (server runs in background)
```

### 2. Create Component
```
<leader>sc              # New component
# Enter name: Button
# Creates: src/lib/components/Button.svelte
```

### 3. Edit & Save
- Auto-formatting on save (Prettier via LSP)
- Auto-import suggestions
- Emmet abbreviations in HTML

### 4. Check Errors
```
]d                      # Next diagnostic
<leader>d               # Show diagnostic details
<leader>ca              # Code actions
```

---

## LSP Features

### Available Commands
- **Hover:** `K` - Show documentation
- **Go to definition:** `gd`
- **Find references:** `gr`
- **Rename:** `<leader>rn`
- **Code actions:** `<leader>ca`
- **Format:** `<leader>mp`

### Auto-Import
Type component name, accept autocomplete, import added automatically!

### Diagnostics
- Red underlines for errors
- Yellow for warnings
- Navigate with `]d` / `[d`

---

## Common Issues & Solutions

### Syntax highlighting not working
```
:TSCheckSvelte          # Check parser status
:TSInstall svelte       # Reinstall if needed
:TSUpdate               # Update all parsers
```

### LSP not working
```
:LspInfo                # Check LSP status
:Mason                  # Verify svelte-language-server installed
:LspRestart             # Restart LSP
```

### Auto-import not working
```
:LspInfo                # Check if LSP is attached
# Make sure you have package.json in project root
```

### TypeScript errors in .svelte
Make sure you have:
- `lang="ts"` in `<script>` tag
- `tsconfig.json` in project root
- TypeScript installed: `pnpm add -D typescript`

---

## pnpm Commands

### Project Setup
```
pnpm create svelte@latest my-app
cd my-app
pnpm install
```

### Development
```
pnpm dev                # Start dev server
pnpm build              # Build for production
pnpm preview            # Preview production build
```

### Dependencies
```
pnpm add <package>      # Add dependency
pnpm add -D <package>   # Add dev dependency
pnpm remove <package>   # Remove dependency
pnpm update             # Update all dependencies
```

### Common Packages
```
pnpm add -D tailwindcss postcss autoprefixer
pnpm add -D @sveltejs/adapter-auto
pnpm add -D vite
```

---

## SvelteKit Structure

```
src/
├── lib/
│   ├── components/     # Reusable components
│   ├── stores/         # Svelte stores
│   └── utils/          # Utility functions
├── routes/
│   ├── +page.svelte    # Home page
│   ├── +layout.svelte  # Root layout
│   ├── about/
│   │   └── +page.svelte
│   └── api/
│       └── +server.ts  # API endpoint
└── app.html            # HTML template
```

---

## Useful Keybindings

### Svelte-Specific
```
<leader>sc    New component
<leader>sp    New page
<leader>sl    New layout
```

### Code Navigation
```
gd            Go to component definition
gr            Find component usage
<leader>ff    Find files (components)
<leader>fs    Search in project
```

### Refactoring
```
<leader>rn    Rename component/variable
<leader>ca    Extract to component (if available)
```

---

## Tips & Tricks

1. **Use Emmet** - Type `div.container>p.text` and expand
2. **Auto-close tags** - Type `<Button` and `>` auto-closes
3. **Template literals** - Use backticks for multi-line
4. **Reactive statements** - `$:` for computed values
5. **Component props** - Export variables: `export let name`

---

## Configuration

Your Neovim is already configured for Svelte with:
- ✅ Treesitter syntax highlighting
- ✅ Svelte LSP (via Mason)
- ✅ Auto-tag closing
- ✅ Emmet support
- ✅ TailwindCSS IntelliSense
- ✅ Prettier formatting
- ✅ TypeScript support

---

## Troubleshooting Commands

```
:TSCheckSvelte          # Check treesitter parsers
:LspInfo                # Check LSP status
:Mason                  # Check installed servers
:checkhealth            # Full health check
```

---

**Everything you need for Svelte development in one place!**
