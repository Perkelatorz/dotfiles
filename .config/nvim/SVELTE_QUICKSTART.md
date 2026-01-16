# Svelte Quick Start Cheatsheet

## 🎯 Workflow At-a-Glance

```
pnpm create svelte → Open in Neovim → Create Component → Use Snippets + Emmet + LSP → Build Fast!
```

---

## 1️⃣ Create New Component

```vim
<leader>sc          " Opens prompt
Type: MyComponent   " Creates MyComponent.svelte with boilerplate
```

---

## 2️⃣ Add Props (Snippets)

**In `<script>` section, type:**

```
sprop<Tab>          →  export let prop = '';
sreact<Tab>         →  $: reactive = value;
sif<Tab>            →  {#if condition}...{/if}
seach<Tab>          →  {#each items as item}...{/each}
sstore<Tab>         →  Writable store setup
```

---

## 3️⃣ Build HTML (Emmet)

**Type abbreviation, then press `<C-y>,`**

### PicoCSS Examples (Semantic HTML):

```
article.card>header>h2{Title}^p{Content}^footer>button{Action}
→ Full semantic structure, PicoCSS styles automatically!

form>fieldset>legend{Form}+label>input*3^button{Submit}
→ Form with 3 inputs, styled by PicoCSS

nav>ul>li*4>a[href=#]{Link}
→ Navigation menu
```

### Tailwind Examples:

```
div.container>div.grid
→ Structure first, then add Tailwind classes with autocomplete

div.flex>div.card*3
→ Flex container with 3 cards
```

---

## 4️⃣ Style with Tailwind (Autocomplete)

**Start typing class names:**

```svelte
<div class="
  bg-        ← Shows all colors with color square previews!
  text-      ← Text colors with previews
  p-         ← Padding options with actual values
  rounded-   ← Border radius options
  hover:     ← Hover states
">
```

**Hover over any class** → See actual CSS values

---

## 5️⃣ SvelteKit Files

```vim
:SveltePage         " Creates +page.svelte
:SvelteLayout       " Creates +layout.svelte
:SvelteServer       " Creates +page.server.ts (server load)
:SvelteLoad         " Creates +page.ts (client load)
:SvelteActions      " Creates form actions

" Or use keybindings:
<leader>sp          " New page
<leader>sl          " New layout
```

**In TypeScript files, use snippets:**

```
kit-load<Tab>       →  Page load function
kit-serverload<Tab> →  Server load function
kit-action<Tab>     →  Form action
```

---

## 6️⃣ LSP Navigation

```vim
K              " Hover (see types, documentation)
gd             " Go to definition
gD             " Go to declaration
<leader>ca     " Code actions (fix imports, etc.)
<leader>rn     " Rename symbol
[d / ]d        " Previous/next diagnostic
```

---

## 🎨 PicoCSS vs Tailwind

### PicoCSS Workflow:
1. Type semantic HTML with Emmet
2. Let PicoCSS style it automatically
3. Focus on structure, not classes

```svelte
<!-- Emmet: article>header>h2+p^footer>button -->
<article>
  <header>
    <h2>Title</h2>
    <p>Subtitle</p>
  </header>
  <footer>
    <button>Action</button>
  </footer>
</article>
<!-- Already beautiful! -->
```

### Tailwind Workflow:
1. Type structure with Emmet
2. Add Tailwind classes with autocomplete + previews
3. Custom design control

```svelte
<!-- Emmet: div.card>h2+p+button -->
<div class="
  bg-white 
  shadow-lg 
  rounded-lg 
  p-6
  hover:shadow-xl     ← See effects with autocomplete!
">
  <h2 class="text-2xl font-bold text-gray-800">Title</h2>
  <p class="text-gray-600 mt-2">Content</p>
  <button class="mt-4 px-4 py-2 bg-blue-500 text-white rounded">
    Action
  </button>
</div>
```

---

## 📝 Common Snippets

### Component Structure
```
scomp           Full component boilerplate
sscript         <script> block
sscriptts       <script lang="ts"> block
sstyle          <style> block
```

### Props & State
```
sprop           export let prop = '';
sproptype       export let prop: Type;
sconst          export const name = value;
```

### Reactivity
```
sreact          $: reactive = value;
sreactive       $: { /* block */ }
seffect         $effect(() => { ... });
```

### Control Flow
```
sif             {#if}...{/if}
sife            {#if}...{:else}...{/if}
seach           {#each items as item}...{/each}
seachk          {#each items as item (key)}...{/each}
sawait          {#await promise}...{/await}
```

### Events & Bindings
```
son             on:event={handler}
sbind           bind:property={variable}
sclass          class:name={condition}
```

### SvelteKit
```
kit-load        Page load function
kit-serverload  Server load function
kit-action      Form action
kit-fail        Form failure handling
kit-redirect    Redirect helper
```

---

## 🚀 Speed Combos

### Create Card Component (30 seconds):
```vim
1. <leader>sc → "Card"
2. sprop<Tab> → "export let title = '';"
3. sprop<Tab> → "export let content = '';"
4. article.card>header>h3^p
5. <C-y>,
6. Replace with {title} and {content}
Done!
```

### Create Form Page (1 minute):
```vim
1. <leader>sp → Creates +page.svelte
2. form>fieldset>legend+label*3>input^button
3. <C-y>,
4. :SvelteActions → Creates actions file
5. kit-action<Tab> → Form action boilerplate
Done!
```

### Style with Tailwind (10 seconds):
```vim
1. Type: <div class="bg-
2. Autocomplete shows colors with previews
3. Pick one, see instant feedback
4. Continue: flex items-center gap-4
5. Each class autocompletes with previews
Done!
```

---

## 🛠️ Troubleshooting

### Snippets not working?
- Make sure you're in a `.svelte` file
- Type prefix + `<Tab>` (not Enter)

### Tailwind not showing colors?
- Check `tailwind.config.js` exists
- Restart LSP: `<leader>rs`

### Emmet not expanding?
- Make sure cursor is after abbreviation
- Use `<C-y>,` (Ctrl-Y comma)
- Must be in template section (not `<script>`)

### LSP not attaching?
- Check: `:LspInfo`
- Should see: svelte, emmet_language_server, tailwindcss
- Restart Neovim if needed

---

## 💡 Pro Tips

1. **Let autocomplete teach you**
   - Start typing, see what's available
   - Hover (`K`) to learn more
   - Less docs, more building

2. **Mix PicoCSS + Tailwind**
   - PicoCSS for base layout
   - Tailwind for specific tweaks
   - Best of both worlds

3. **Use templates liberally**
   - Component templates save time
   - Consistent structure
   - Focus on logic, not boilerplate

4. **Learn Emmet patterns**
   - `>` child
   - `+` sibling
   - `^` climb up
   - `*3` multiply
   - `{}` text content
   - `[]` attributes

5. **Trust the LSP**
   - Red squiggles = errors
   - Hover for info
   - `<leader>ca` often fixes things
   - `gd` to explore code

---

## 📚 Full Documentation

- **Complete guide:** [`SVELTE_WORKFLOW.md`](./SVELTE_WORKFLOW.md)
- **All snippets:** [`SVELTE_SNIPPETS_REFERENCE.md`](./SVELTE_SNIPPETS_REFERENCE.md)
- **Config docs:** [`NVIM_CONFIG_DOCS.md`](./NVIM_CONFIG_DOCS.md)

---

**Remember:** Focus on **building**, not **memorizing**! 🚀
