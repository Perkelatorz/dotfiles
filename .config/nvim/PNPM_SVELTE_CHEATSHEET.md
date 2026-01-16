# pnpm + Svelte Development Cheatsheet

## 🚀 Quick Start

```bash
# Create new SvelteKit project
pnpm create svelte@latest my-app

# Navigate and install
cd my-app
pnpm install

# Start development server
pnpm dev
```

---

## 📦 Common pnpm Commands

### Installation

```bash
pnpm install              # Install all dependencies from package.json
pnpm i                    # Short form

pnpm add <package>        # Add dependency
pnpm add -D <package>     # Add dev dependency
pnpm add -g <package>     # Add global package

# Examples:
pnpm add @picocss/pico    # Add PicoCSS
pnpm add -D tailwindcss   # Add Tailwind (dev dependency)
```

### Running Scripts

```bash
pnpm dev                  # Start development server
pnpm build                # Build for production
pnpm preview              # Preview production build
pnpm check                # Run svelte-check (type checking)
pnpm lint                 # Run ESLint
pnpm format               # Run Prettier
```

### Updating

```bash
pnpm update               # Update all dependencies
pnpm update <package>     # Update specific package
pnpm outdated             # Check for outdated packages
```

### Removing

```bash
pnpm remove <package>     # Remove dependency
pnpm rm <package>         # Short form
```

### Utilities

```bash
pnpm dlx <command>        # Execute package without installing (like npx)
pnpm why <package>        # Show why package is installed
pnpm list                 # List installed packages
pnpm store prune          # Clean unused packages from store
```

---

## 🎨 Framework Installation

### PicoCSS Setup

```bash
# 1. Install PicoCSS
pnpm add @picocss/pico

# 2. Import in src/routes/+layout.svelte
# <script>
#   import '@picocss/pico';
# </script>
```

### Tailwind CSS Setup

```bash
# 1. Install Tailwind and dependencies
pnpm add -D tailwindcss postcss autoprefixer

# 2. Initialize config (creates tailwind.config.js)
pnpm dlx tailwindcss init -p

# 3. Configure tailwind.config.js:
# content: ['./src/**/*.{html,js,svelte,ts}']

# 4. Create src/app.css:
# @tailwind base;
# @tailwind components;
# @tailwind utilities;

# 5. Import in src/routes/+layout.svelte:
# <script>
#   import '../app.css';
# </script>
```

### Both Frameworks Together

```bash
# Install both
pnpm add @picocss/pico
pnpm add -D tailwindcss postcss autoprefixer

# Configure as shown above
# Use PicoCSS for quick prototyping
# Use Tailwind for custom components
```

---

## 🔧 Common Development Packages

```bash
# UI Components
pnpm add svelte-forms-lib           # Form handling
pnpm add yup                        # Validation
pnpm add svelte-french-toast        # Toast notifications

# State Management
pnpm add svelte/store               # Built-in (already included)
pnpm add zustand                    # Alternative state management

# Data Fetching
pnpm add @tanstack/svelte-query     # Query management
pnpm add axios                      # HTTP client

# Icons
pnpm add lucide-svelte              # Lucide icons
pnpm add svelte-icons               # Icon pack

# Animation
pnpm add svelte/motion              # Built-in (Svelte 5)
pnpm add svelte-motion              # Motion library

# Date/Time
pnpm add date-fns                   # Date utilities
pnpm add dayjs                      # Lightweight date library

# Utilities
pnpm add clsx                       # Conditional classes
pnpm add nanoid                     # ID generation
```

---

## 🛠️ Development Tools

```bash
# Testing
pnpm add -D @playwright/test        # E2E testing (optional during setup)
pnpm add -D vitest                  # Unit testing (optional during setup)

# Type Checking
pnpm add -D typescript              # Already included in setup
pnpm add -D @sveltejs/vite-plugin-svelte

# Linting & Formatting
pnpm add -D eslint                  # Already included in setup
pnpm add -D prettier                # Already included in setup
pnpm add -D prettier-plugin-svelte

# Svelte Tools
pnpm add -D svelte-check            # Type checking for Svelte
pnpm add -D @sveltejs/adapter-auto  # SvelteKit adapter (default)
pnpm add -D @sveltejs/adapter-node  # For Node.js deployment
pnpm add -D @sveltejs/adapter-vercel # For Vercel deployment
```

---

## 📝 Complete Project Setup Example

```bash
# 1. Create project
pnpm create svelte@latest my-app
cd my-app

# 2. Install dependencies
pnpm install

# 3. Add PicoCSS for quick development
pnpm add @picocss/pico

# 4. Add Tailwind for custom styling
pnpm add -D tailwindcss postcss autoprefixer
pnpm dlx tailwindcss init -p

# 5. Add useful utilities
pnpm add clsx nanoid

# 6. Add icons
pnpm add lucide-svelte

# 7. Configure and start
# Edit tailwind.config.js and create app.css
# Import in +layout.svelte
pnpm dev
```

---

## 🚀 Workflow with Neovim

```bash
# 1. Create and setup project
pnpm create svelte@latest my-app && cd my-app && pnpm install

# 2. Open in Neovim
nvim .

# 3. In Neovim, create component
:SvelteComponent Card

# 4. Use snippets
sprop<Tab>              # Add props
sreact<Tab>             # Reactive statements

# 5. Use Emmet for HTML
article.card>h2+p       # Type this
<C-y>,                  # Press this to expand

# 6. Add Tailwind classes with autocomplete
class="bg-              # Start typing, see color previews!

# 7. Run dev server in terminal
pnpm dev
```

---

## 🎯 pnpm vs npm vs yarn

| Task | pnpm | npm | yarn |
|------|------|-----|------|
| Install deps | `pnpm install` | `npm install` | `yarn install` |
| Add package | `pnpm add pkg` | `npm install pkg` | `yarn add pkg` |
| Add dev dep | `pnpm add -D pkg` | `npm install -D pkg` | `yarn add -D pkg` |
| Remove package | `pnpm remove pkg` | `npm uninstall pkg` | `yarn remove pkg` |
| Run script | `pnpm dev` | `npm run dev` | `yarn dev` |
| Execute binary | `pnpm dlx cmd` | `npx cmd` | `yarn dlx cmd` |
| Global install | `pnpm add -g pkg` | `npm install -g pkg` | `yarn global add pkg` |

---

## 💡 pnpm Benefits

✅ **Faster** - Parallel installation, reuses packages
✅ **Efficient** - Saves disk space with shared store
✅ **Strict** - Better dependency resolution
✅ **Compatible** - Works with all npm packages

---

## 🔍 Troubleshooting

### Clear Cache

```bash
pnpm store prune        # Remove unused packages
rm -rf node_modules     # Delete node_modules
rm pnpm-lock.yaml       # Delete lock file
pnpm install            # Fresh install
```

### Verify Installation

```bash
pnpm --version          # Check pnpm version
pnpm list               # List installed packages
pnpm why <package>      # Check dependency tree
```

### Common Issues

**Package not found?**
```bash
pnpm install            # Ensure all deps installed
pnpm store prune        # Clean store
pnpm install --force    # Force reinstall
```

**Peer dependency warnings?**
```bash
# Usually safe to ignore in SvelteKit
# Or install the peer dependency:
pnpm add <peer-dep>
```

---

## 📚 Resources

- **pnpm Docs:** https://pnpm.io/
- **SvelteKit Docs:** https://kit.svelte.dev/
- **Svelte Docs:** https://svelte.dev/
- **PicoCSS:** https://picocss.com/
- **Tailwind CSS:** https://tailwindcss.com/

---

## 🎉 Quick Reference

```bash
# Start new project
pnpm create svelte@latest my-app && cd my-app && pnpm install

# Add frameworks
pnpm add @picocss/pico                              # PicoCSS
pnpm add -D tailwindcss postcss autoprefixer        # Tailwind

# Run development
pnpm dev                # Start dev server (http://localhost:5173)
pnpm build              # Build for production
pnpm preview            # Preview production build

# Manage packages
pnpm add <package>      # Install package
pnpm remove <package>   # Remove package
pnpm update             # Update all packages

# Neovim workflow
nvim .                  # Open project
:SvelteComponent Name   # Create component
sprop<Tab>              # Add prop snippet
<C-y>,                  # Expand Emmet
```

**Happy developing with pnpm + Svelte + Neovim! 🚀**
