# Svelte Development

**Syntax:** Treesitter v1.0+ (auto-enabled) · **LSP:** Svelte Language Server (Mason)

## Keys

| Key | Action |
|-----|--------|
| `<leader>sc` | New component |
| `<leader>sp` | New SvelteKit page (+page.svelte) |
| `<leader>sl` | New SvelteKit layout (+layout.svelte) |

## Snippets (Tab to expand)

**Structure:** `sbase` full component · `sscript` script tag · `sstyle` style tag

**Reactivity:** `sreactive` `$:` · `sstore` store · `sderived` derived store

**Bindings:** `sbind` bind:value · `sclass` class: · `son` on:click

**Logic:** `sif` {#if} · `seach` {#each} · `sawait` {#await}

**SvelteKit:** `spage` +page.svelte · `slayout` +layout.svelte · `sserver` +page.server.ts · `sload` load · `sactions` form actions

## Workflow

1. `<leader>zt` → `pnpm dev` → `<leader>zt` (hide; server runs)
2. `<leader>sc` → enter name → component created in `src/lib/components/`
3. Format on save, auto-import via LSP
4. `]d` / `<leader>dd` / `<leader>ca` for diagnostics

## Troubleshooting

```
:TSCheckSvelte    Check parser    :LspInfo    LSP status
:TSInstall svelte Reinstall      :LspRestart Restart LSP
```

TS in .svelte: use `lang="ts"`, have `tsconfig.json`, `pnpm add -D typescript`.
