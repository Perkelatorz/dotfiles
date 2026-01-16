# Svelte/SvelteKit Snippets & Tooling Reference

## Quick Reference

This config provides comprehensive Svelte/SvelteKit development support with:
- **LSP Support:** Svelte, Emmet, Tailwind CSS language servers
- **Snippets:** Pre-built patterns for Svelte and SvelteKit
- **Templates:** Commands to scaffold new files
- **Auto-completion:** Intelligent suggestions with previews

---

## File Templates (Commands)

### Creating New Files

| Command | Usage | Description |
|---------|-------|-------------|
| `:SvelteComponent Card` | Creates `Card.svelte` | New Svelte component |
| `:SveltePage` | Creates `+page.svelte` | New SvelteKit page in current dir |
| `:SvelteLayout` | Creates `+layout.svelte` | New SvelteKit layout |
| `:SvelteServer` | Creates `+page.server.ts` | Server-side load function |
| `:SvelteLoad` | Creates `+page.ts` | Client-side load function |
| `:SvelteActions` | Creates `+page.server.ts` with actions | Form actions |

### Keybindings for Templates

| Key | Action |
|-----|--------|
| `<leader>sc` | New Svelte component (prompts for name) |
| `<leader>sp` | New SvelteKit page |
| `<leader>sl` | New SvelteKit layout |

---

## Svelte Snippets (via nvim-svelte-snippets)

Type these prefixes and press `<Tab>` to expand:

### Component Structure

| Snippet | Expands To | Description |
|---------|------------|-------------|
| `scomp` | Full component template | Script, markup, style sections |
| `sscript` | `<script>...</script>` | Script block |
| `sscriptts` | `<script lang="ts">...</script>` | TypeScript script block |
| `sstyle` | `<style>...</style>` | Style block |
| `sstylescoped` | `<style scoped>...</style>` | Scoped style block |

### Props & Exports

| Snippet | Expands To | Description |
|---------|------------|-------------|
| `sprop` | `export let prop = '';` | Component prop |
| `sproptype` | `export let prop: Type;` | Typed prop (TS) |
| `sconst` | `export const name = value;` | Exported constant |

### Reactive Declarations

| Snippet | Expands To | Description |
|---------|------------|-------------|
| `sreact` | `$: reactive = value;` | Reactive statement |
| `sreactive` | `$: { /* reactive block */ }` | Reactive block |
| `seffect` | `$effect(() => { ... });` | Svelte 5 effect |

### Control Flow

| Snippet | Expands To | Description |
|---------|------------|-------------|
| `sif` | `{#if condition}...{/if}` | If block |
| `sife` | `{#if}...{:else}...{/if}` | If-else block |
| `seach` | `{#each items as item}...{/each}` | Each loop |
| `seachk` | `{#each items as item (key)}...{/each}` | Keyed each loop |
| `sawait` | `{#await promise}...{/await}` | Await block |

### Events & Bindings

| Snippet | Expands To | Description |
|---------|------------|-------------|
| `son` | `on:event={handler}` | Event handler |
| `sbind` | `bind:property={variable}` | Two-way binding |
| `sclass` | `class:name={condition}` | Conditional class |
| `sstyle` | `style:property={value}` | Inline style binding |

### Stores

| Snippet | Expands To | Description |
|---------|------------|-------------|
| `sstore` | Writable store setup | `import { writable } from 'svelte/store'` |
| `sreadable` | Readable store setup | `import { readable } from 'svelte/store'` |
| `sderived` | Derived store setup | `import { derived } from 'svelte/store'` |
| `sget` | `$store` | Store auto-subscription |

### Component Features

| Snippet | Expands To | Description |
|---------|------------|-------------|
| `sslot` | `<slot />` | Default slot |
| `sslotname` | `<slot name="name" />` | Named slot |
| `scontext` | Context API setup | `setContext/getContext` |
| `sdispatch` | Event dispatcher | `createEventDispatcher` |

---

## SvelteKit Snippets

Type `kit-` prefix for SvelteKit-specific snippets:

### Load Functions

| Snippet | Expands To | Description |
|---------|------------|-------------|
| `kit-load` | Page load function | `export const load: PageLoad = ...` |
| `kit-serverload` | Server load function | `export const load: PageServerLoad = ...` |
| `kit-layoutload` | Layout load function | `export const load: LayoutLoad = ...` |

### Form Actions

| Snippet | Expands To | Description |
|---------|------------|-------------|
| `kit-action` | Form action | `export const actions: Actions = ...` |
| `kit-actiondefault` | Default action | `default: async ({ request }) => ...` |
| `kit-actionnamed` | Named action | `actionName: async ({ request }) => ...` |

### SvelteKit Utilities

| Snippet | Expands To | Description |
|---------|------------|-------------|
| `kit-params` | Route params type | `import type { Params } from './$types'` |
| `kit-fail` | Form failure | `import { fail } from '@sveltejs/kit'` |
| `kit-redirect` | Redirect | `import { redirect } from '@sveltejs/kit'` |
| `kit-error` | Error handling | `import { error } from '@sveltejs/kit'` |

---

## Emmet Abbreviations

Emmet works in Svelte files for fast HTML writing. Press the expansion key after typing:

### Basic Examples

```
Type: div.container>ul>li*3
Expands to:
<div class="container">
  <ul>
    <li></li>
    <li></li>
    <li></li>
  </ul>
</div>
```

### Common Patterns

| Abbreviation | Result |
|--------------|--------|
| `div.card` | `<div class="card"></div>` |
| `article>header+p` | `<article><header></header><p></p></article>` |
| `ul>li.item*3` | `<ul> with 3 <li class="item">` |
| `div#id.class1.class2` | `<div id="id" class="class1 class2">` |
| `a[href=#]` | `<a href="#"></a>` |
| `h2{Title}` | `<h2>Title</h2>` |

### PicoCSS Semantic HTML

Emmet is perfect for PicoCSS's semantic approach:

```
article.card>header>h3{Card Title}^p{Content}^footer>button{Action}
```

Expands to semantic HTML structure PicoCSS styles automatically!

### Tailwind Workflow

1. Type Emmet abbreviation for structure
2. Add Tailwind classes with autocomplete
3. See color/spacing previews as you type

```
div.flex>div.bg-{autocomplete shows all bg- classes with previews}
```

---

## Tailwind CSS Autocomplete

### Features

When typing Tailwind classes in Svelte files:

1. **Autocomplete with Previews**
   - Type `bg-` → see all background colors with color squares
   - Type `text-` → see all text colors with previews
   - Type `p-` → see padding options with values

2. **Hover Information**
   - Hover over any Tailwind class to see actual CSS

3. **Linting**
   - Warns about invalid/deprecated classes
   - Suggests alternatives

4. **Class Detection**
   - Works in `class=""` attributes
   - Works with Svelte's `class:` directives

### Example Workflow

```svelte
<div class="
  flex          ← Autocomplete suggests flex utilities
  items-center  ← Autocomplete shows alignment options  
  gap-4         ← See spacing values
  bg-blue-      ← Shows all blue variants with color previews!
  ">
  Content
</div>
```

---

## LSP Features

### Svelte Language Server

- **Autocomplete:** Component props, Svelte syntax, TypeScript
- **Go to Definition:** Jump to component/function definitions
- **Hover Documentation:** See prop types and documentation
- **Error Detection:** Real-time syntax/type errors
- **Refactoring:** Rename symbols across files

### How to Use

- `gd` - Go to definition
- `K` - Show hover documentation
- `<leader>ca` - Code actions
- `<leader>rn` - Rename symbol
- `[d` / `]d` - Navigate diagnostics

---

## Project Detection

### Tailwind

Tailwind LSP only activates when it detects:
- `tailwind.config.js/ts/cjs/mjs` in project root
- OR `tailwindcss` in `package.json` dependencies

This means:
- **PicoCSS-only projects:** No Tailwind LSP interference ✅
- **Tailwind projects:** Full autocomplete and linting ✅
- **Mixed projects:** Tailwind LSP helps with Tailwind classes ✅

### SvelteKit

SvelteKit snippets (kit-*) auto-detect `svelte.config.js`:
- **SvelteKit projects:** All kit-* snippets available
- **Standalone Svelte:** Regular Svelte snippets only

---

## Tips & Best Practices

### Learning Workflow

1. **Start with snippets** - Use `scomp`, `sprop`, etc. to learn syntax
2. **Graduate to Emmet** - Speed up HTML with abbreviations
3. **Let LSP help** - Rely on autocomplete for Svelte-specific syntax
4. **Use Tailwind autocomplete** - Stop memorizing class names

### PicoCSS Development

```svelte
<!-- Use semantic HTML + Emmet -->
Type: article.card>header>h3{Title}^p{Description}^footer>button{Action}

<!-- PicoCSS styles automatically! -->
<!-- Focus on structure, not styling -->
```

### Tailwind Development

```svelte
<!-- Use Emmet for structure -->
Type: div.container>div.grid

<!-- Then add Tailwind with autocomplete -->
<div class="container">
  <div class="grid grid-cols-3 gap-4 p-6">
    <!-- See previews as you type! -->
  </div>
</div>
```

### Component Creation

```bash
# Quick component with boilerplate
:SvelteComponent Button

# Edit the generated file
# Use sprop<Tab> for props
# Use son<Tab> for events
# Use Emmet for markup
```

### SvelteKit Routing

```bash
# Create page
:SveltePage

# Add server load if needed
:SvelteServer

# Add actions for forms
:SvelteActions

# Use kit-load<Tab>, kit-action<Tab> for boilerplate
```

---

## Default Keybindings

Emmet uses default Vim keybinding: `<C-y>,` (Ctrl-Y then comma)

Example:
```
1. Type: div.container>ul>li*3
2. Press: Ctrl-Y, (comma)
3. Result: Expanded HTML
```

In insert mode, with cursor after abbreviation.

---

## Troubleshooting

### Snippets not working?

1. Make sure you're in a `.svelte` file
2. Type the snippet prefix and press `<Tab>`
3. Check `:Lazy` to ensure `nvim-svelte-snippets` is loaded

### Tailwind autocomplete not showing?

1. Ensure `tailwind.config.js` exists in project root
2. Or check `tailwindcss` is in `package.json`
3. Restart LSP: `<leader>rs`

### Emmet not expanding?

1. Make sure you're in a Svelte template section (not `<script>`)
2. Use `<C-y>,` (Ctrl-Y comma) to expand
3. Check `:LspInfo` to see if Emmet LSP is attached

---

## More Information

- **Svelte Snippets:** https://github.com/nvim-svelte/nvim-svelte-snippets
- **Emmet Docs:** https://docs.emmet.io/
- **Tailwind Docs:** https://tailwindcss.com/docs
- **SvelteKit Docs:** https://kit.svelte.dev/docs
