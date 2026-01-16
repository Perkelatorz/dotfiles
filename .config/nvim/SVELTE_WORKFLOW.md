# Svelte/SvelteKit Project Workflow in Neovim

> **Note:** This guide uses `pnpm` (fast, efficient package manager). You can also use `npm` or `yarn` by replacing `pnpm` commands.

## 📋 Starting a New Project

### Step 1: Create SvelteKit Project

```bash
# Create new SvelteKit project with pnpm
pnpm create svelte@latest my-app

# Options you'll choose:
# - TypeScript? Yes (recommended)
# - ESLint? Yes
# - Prettier? Yes
# - Playwright? Optional (for E2E tests)
# - Vitest? Optional (for unit tests)

cd my-app
pnpm install
```

### Step 2: Add CSS Framework (Choose One or Both)

#### Option A: PicoCSS (Quick Development)

```bash
pnpm add @picocss/pico
```

Then in `src/routes/+layout.svelte`:
```svelte
<script>
  import '@picocss/pico';
</script>

<slot />
```

#### Option B: Tailwind CSS (Custom Styling)

```bash
# Install Tailwind
pnpm add -D tailwindcss postcss autoprefixer
pnpm dlx tailwindcss init -p

# This creates tailwind.config.js (Neovim will auto-detect it!)
```

Configure `tailwind.config.js`:
```js
/** @type {import('tailwindcss').Config} */
export default {
  content: ['./src/**/*.{html,js,svelte,ts}'],
  theme: {
    extend: {},
  },
  plugins: [],
}
```

Create `src/app.css`:
```css
@tailwind base;
@tailwind components;
@tailwind utilities;
```

Import in `src/routes/+layout.svelte`:
```svelte
<script>
  import '../app.css';
</script>

<slot />
```

#### Option C: Both Frameworks

You can use both! Tailwind LSP won't interfere with PicoCSS.
- Use PicoCSS for quick semantic HTML
- Use Tailwind for custom components

### Step 3: Start Development Server

```bash
pnpm dev
```

Keep this running in a terminal while you code!

---

## 💻 Development Workflow in Neovim

### Opening Your Project

```bash
cd my-app
nvim .
```

**Your LSPs will auto-activate when you open files:**
- ✅ Svelte LSP (all `.svelte` files)
- ✅ Emmet LSP (all `.svelte` files)
- ✅ Tailwind LSP (if `tailwind.config.js` detected)
- ✅ TypeScript LSP (`.ts` files)

---

## 🏗️ Building Your First Component

### Scenario: Creating a Card Component

#### 1. Create the Component

In Neovim:
```vim
" Quick way - uses keybinding
<leader>sc
" Prompts: "Component name:"
" Type: Card

" OR use command directly
:SvelteComponent Card
```

This creates `Card.svelte` with boilerplate:
```svelte
<script lang="ts">
	// Component: Card
</script>

<div>
	<!-- Component content -->
</div>

<style>
	/* Component styles */
</style>
```

#### 2. Add Props (Using Snippets)

Place cursor in `<script>` section and type:
```
sprop<Tab>
```

Expands to:
```svelte
export let prop = '';
```

Modify for your needs:
```svelte
<script lang="ts">
	export let title = '';
	export let description = '';
	export let link = '';
</script>
```

**💡 Tip:** LSP will autocomplete `export`, `let`, and show TypeScript types!

#### 3. Build HTML Structure

**With PicoCSS (Semantic HTML):**

In the template section, type Emmet abbreviation:
```
article.card>header>h3{Card Title}^p{Description}^footer>a[href=#]{Learn More}
```

Press `<C-y>,` (Ctrl-Y comma) to expand:
```svelte
<article class="card">
	<header>
		<h3>Card Title</h3>
	</header>
	<p>Description</p>
	<footer>
		<a href="#">Learn More</a>
	</footer>
</article>
```

Replace placeholder text with props:
```svelte
<article class="card">
	<header>
		<h3>{title}</h3>
	</header>
	<p>{description}</p>
	<footer>
		<a href={link}>Learn More</a>
	</footer>
</article>
```

**With Tailwind CSS:**

Type Emmet for structure:
```
div.card>div.card-header>h3^div.card-body>p^div.card-footer>a
<C-y>,
```

Then add Tailwind classes with autocomplete:
```svelte
<div class="
  rounded-lg        ← Start typing 'rounded-' see all options
  shadow-lg         ← Type 'shadow-' see shadow variants
  p-6               ← Type 'p-' see padding with values
  bg-white          ← Type 'bg-' see colors with previews!
  hover:shadow-xl   ← Hover states autocomplete too
">
  <div class="mb-4">
    <h3 class="text-2xl font-bold text-gray-800">{title}</h3>
  </div>
  <div class="mb-4">
    <p class="text-gray-600">{description}</p>
  </div>
  <div>
    <a href={link} class="
      px-4 py-2 
      bg-blue-      ← Autocomplete shows ALL blue variants with color squares!
      text-white 
      rounded 
      hover:bg-blue-700
    ">
      Learn More
    </a>
  </div>
</div>
```

**💡 As you type Tailwind classes:**
- Autocomplete menu shows suggestions
- Color squares appear next to color classes
- Hover over any class to see actual CSS values

#### 4. Add Reactive Logic (Using Snippets)

Need reactive variables? Type in `<script>`:
```
sreact<Tab>
```

Expands to:
```svelte
$: reactive = value;
```

Example:
```svelte
<script lang="ts">
	export let title = '';
	export let description = '';
	export let link = '';
	
	// Reactive computation
	$: truncated = description.slice(0, 100) + '...';
</script>

<article class="card">
	<p>{truncated}</p>
</article>
```

---

## 📄 Building a Page

### Creating a New Route

```bash
# In Neovim, from project root
:SveltePage

# This creates: +page.svelte in current directory
```

**Or create in specific route:**
```bash
# Navigate to where you want the page
# For example: src/routes/about/
# Then:
:SveltePage
```

This creates `+page.svelte`:
```svelte
<script lang="ts">
	import type { PageData } from './$types';
	
	export let data: PageData;
</script>

<div>
	<h1>Welcome</h1>
</div>

<style>
	/* Page styles */
</style>
```

### Adding Page Layout (PicoCSS Example)

Use Emmet for quick structure:
```
div.container>header>h1{About Us}^main>article*3>h2{Section}+p{Content}
<C-y>,
```

PicoCSS automatically styles `<article>`, `<header>`, etc.!

### Adding Components to Page

```svelte
<script lang="ts">
	import Card from '$lib/components/Card.svelte';
	import type { PageData } from './$types';
	
	export let data: PageData;
</script>

<div class="container">
	<h1>Our Services</h1>
	
	<div class="grid">
		<Card 
			title="Service 1" 
			description="Description here"
			link="/service-1"
		/>
		<Card 
			title="Service 2" 
			description="Description here"
			link="/service-2"
		/>
	</div>
</div>
```

**💡 LSP Features:**
- Type `Card ` and autocomplete shows available props
- Hover over `Card` to see component documentation
- `gd` on `Card` jumps to component definition

---

## 🔄 Data Loading

### Client-Side Load Function

```vim
:SvelteLoad
```

Creates `+page.ts`:
```typescript
import type { PageLoad } from './$types';

export const load: PageLoad = async ({ params, fetch }) => {
	return {
		// Your data here
	};
};
```

Use snippet for faster typing:
```
kit-load<Tab>
```

Example:
```typescript
import type { PageLoad } from './$types';

export const load: PageLoad = async ({ fetch }) => {
	const response = await fetch('/api/posts');
	const posts = await response.json();
	
	return {
		posts
	};
};
```

### Server-Side Load Function

```vim
:SvelteServer
```

Creates `+page.server.ts`:
```typescript
import type { PageServerLoad } from './$types';

export const load: PageServerLoad = async ({ params, locals }) => {
	return {
		// Your data here
	};
};
```

---

## 📝 Forms & Actions

### Creating Form Actions

```vim
:SvelteActions
```

Creates `+page.server.ts` with actions:
```typescript
import type { Actions, PageServerLoad } from './$types';
import { fail } from '@sveltejs/kit';

export const load: PageServerLoad = async () => {
	return {};
};

export const actions: Actions = {
	default: async ({ request }) => {
		const data = await request.formData();
		
		// Process form data
		
		return { success: true };
	}
};
```

Use snippet for quick actions:
```
kit-action<Tab>
```

### Building the Form (Page)

In `+page.svelte`:
```svelte
<script lang="ts">
	import type { ActionData } from './$types';
	
	export let form: ActionData;
</script>

<form method="POST">
	<label>
		Name:
		<input type="text" name="name" required />
	</label>
	
	<label>
		Email:
		<input type="email" name="email" required />
	</label>
	
	<button type="submit">Submit</button>
</form>

{#if form?.success}
	<p>Thanks for submitting!</p>
{/if}
```

Use snippets:
- `sif<Tab>` for if blocks
- `son<Tab>` for event handlers
- `sbind<Tab>` for bindings

---

## 🎨 Styling Workflow

### PicoCSS Approach (Minimal Classes)

```svelte
<!-- Type semantic HTML with Emmet -->
form>fieldset>label>input^label>input^button

<!-- PicoCSS styles it beautifully with zero custom CSS! -->
<form>
	<fieldset>
		<label>
			Name
			<input type="text" placeholder="Your name" />
		</label>
		<label>
			Email
			<input type="email" placeholder="your@email.com" />
		</label>
	</fieldset>
	<button type="submit">Submit</button>
</form>
```

### Tailwind Approach (Custom Design)

```svelte
<!-- Start with Emmet structure -->
form.form-container>div.form-group*2>label+input^button
<C-y>,

<!-- Then add Tailwind classes with autocomplete -->
<form class="max-w-md mx-auto p-6 bg-white rounded-lg shadow-md">
	<div class="mb-4">
		<label class="block text-gray-700 font-bold mb-2">
			Name
		</label>
		<input 
			type="text" 
			class="
				w-full 
				px-3 py-2 
				border border-gray-300 
				rounded-lg 
				focus:outline-none 
				focus:ring-2 
				focus:ring-blue-500    ← See blue-500 color preview!
			"
		/>
	</div>
	<button class="
		w-full 
		bg-blue-600         ← Color preview
		hover:bg-blue-700   ← Hover preview
		text-white 
		font-bold 
		py-2 px-4 
		rounded-lg
	">
		Submit
	</button>
</form>
```

**💡 Pro Tip:** Mix both!
```svelte
<!-- Use PicoCSS for base styling -->
<form>
	<!-- Add Tailwind for specific adjustments -->
	<label class="flex items-center gap-2">
		Name
		<input type="text" />
	</label>
</form>
```

---

## 🔍 Common Development Tasks

### Finding Files

```vim
<leader>ff    " Fuzzy find files (Telescope)
<leader>fr    " Recent files
<leader>fs    " Search in files (grep)
```

### LSP Navigation

```vim
K             " Hover documentation (see prop types, function docs)
gd            " Go to definition (jump to component/function)
gD            " Go to declaration
<leader>ca    " Code actions (import missing, fix errors)
<leader>rn    " Rename (refactor component/variable name)
[d / ]d       " Navigate diagnostics (errors/warnings)
```

### Component Development

```vim
<leader>sc    " Create new component
sprop<Tab>    " Add prop
sreact<Tab>   " Add reactive statement
sif<Tab>      " Add if block
seach<Tab>    " Add each loop
```

### Working with Multiple Files

```vim
" Split windows for component + page
:vsplit src/lib/components/Card.svelte
<C-w>w        " Switch between windows
<C-w>=        " Equal window sizes
```

---

## 🐛 Debugging & Checking

### Check LSP Status

```vim
:LspInfo
" Shows attached language servers (should see svelte, emmet, tailwindcss)
```

### Format Code

```vim
<leader>mp    " Format file with Prettier
```

### Git Integration

```vim
<leader>lg    " Open LazyGit
<leader>hs    " Stage hunk
<leader>hp    " Preview hunk
```

---

## 📦 Project Structure Example

```
my-app/
├── src/
│   ├── lib/
│   │   └── components/
│   │       ├── Card.svelte        (created with :SvelteComponent)
│   │       ├── Button.svelte
│   │       └── Nav.svelte
│   ├── routes/
│   │   ├── +layout.svelte         (created with :SvelteLayout)
│   │   ├── +page.svelte           (created with :SveltePage)
│   │   ├── about/
│   │   │   └── +page.svelte
│   │   └── blog/
│   │       ├── +page.svelte
│   │       ├── +page.server.ts    (created with :SvelteServer)
│   │       └── [slug]/
│   │           └── +page.svelte
│   └── app.css                    (if using Tailwind)
├── tailwind.config.js             (auto-detected by Tailwind LSP)
└── svelte.config.js               (auto-detected by Svelte LSP)
```

---

## ⚡ Speed Tips

### 1. Use Snippets Extensively

Instead of typing:
```svelte
export let title = '';
```

Type: `sprop<Tab>` then modify.

### 2. Emmet for HTML

Instead of typing:
```html
<div class="container">
  <header>
    <h1>Title</h1>
  </header>
  <main>
    <p>Content</p>
  </main>
</div>
```

Type: `div.container>header>h1{Title}^main>p{Content}`
Then: `<C-y>,`

### 3. Let Autocomplete Guide You

- Start typing and wait for suggestions
- LSP shows you available props, functions
- Tailwind shows you available classes
- Less memorization, more building!

### 4. Use Templates

- `<leader>sc` for components
- `<leader>sp` for pages
- `<leader>sl` for layouts

### 5. Leverage LSP

- `K` to learn about functions/components
- `gd` to explore implementations
- `<leader>ca` to fix imports automatically

---

## 🎯 Full Example: Building a Blog Card

```vim
" 1. Create component
<leader>sc
" Enter: BlogCard

" 2. Add props
sprop<Tab>
" Modify to:
export let title: string;
export let excerpt: string;
export let date: string;
export let slug: string;

" 3. Use Emmet for PicoCSS structure
article.card>header>h2>a[href=#]{Title}+small{Date}^p{Excerpt}^footer>a[href=#]{Read More}
<C-y>,

" 4. Replace with props
" 5. Add reactive logic if needed
sreact<Tab>
$: formattedDate = new Date(date).toLocaleDateString();

" Done! PicoCSS styled, semantic HTML, reactive!
```

**For Tailwind version:** Same flow, but add classes with autocomplete!

---

## 🚀 Productivity Gains

**Before this setup:**
- Look up Svelte syntax
- Check Tailwind docs for classes
- Manually type HTML structure
- Remember component boilerplate

**With this setup:**
- Snippets provide syntax
- Autocomplete shows Tailwind classes with previews
- Emmet generates HTML instantly
- Templates create boilerplate

**Result:** Focus on **what** you're building, not **how** to write it!

---

## 📚 Quick Reference

**File Creation:**
- `:SvelteComponent Name` - Component
- `:SveltePage` - Page
- `:SvelteServer` - Server load
- `:SvelteActions` - Form actions

**Snippets:**
- `scomp` - Component boilerplate
- `sprop` - Export prop
- `sreact` - Reactive statement
- `kit-load` - Load function
- `kit-action` - Form action

**Emmet:**
- Type abbreviation, press `<C-y>,`
- Example: `div.card>h2+p`

**LSP:**
- `K` - Hover docs
- `gd` - Go to definition
- `<leader>ca` - Code actions
- `<leader>rn` - Rename

**Tailwind:**
- Type `bg-` → See colors with previews
- Type `text-` → See text colors
- Hover → See actual CSS

---

Happy building! 🎉
