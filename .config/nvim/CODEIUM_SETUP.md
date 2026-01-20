# Codeium (Windsurf) AI Setup Guide

## 🤖 What is Codeium?

Codeium is a **free AI-powered code completion** tool (similar to GitHub Copilot but free!). It provides:
- **Ghost text completions** - Inline suggestions as you type
- **Multi-line suggestions** - Complete functions/components
- **Context-aware** - Understands your entire codebase
- **100% Free** - No credit card required

**Also known as:** Windsurf (Codeium's Neovim integration)

---

## ⚙️ Current Configuration

Your config already has Codeium installed and configured! Here's what's enabled:

✅ **Virtual Text (Ghost Completions)** - Enabled
✅ **Auto-trigger** - Suggestions appear automatically (75ms delay)
✅ **nvim-cmp Integration** - Works with your completion menu
✅ **Chat Feature** - Browser-based AI chat
✅ **All File Types** - Works in Svelte, Python, Go, TypeScript, etc.

---

## 🚀 Setup Steps (First Time Only)

### Step 1: Start Neovim

```bash
nvim
```

### Step 2: Authenticate with Codeium

In Neovim, run:
```vim
:Codeium Auth
```

**OR use the keybinding:**
```vim
<leader>aA
```

### Step 3: Follow the Authentication Flow

When you run the command, Codeium will:

1. **Open your browser** automatically
2. Show a **token/code** in Neovim
3. Ask you to **sign in** (create free account or login)
4. **Paste the token** from Neovim into the browser
5. **Confirm authentication**

**Sign up options:**
- GitHub account (easiest)
- Google account
- Email

### Step 4: Verify It's Working

Back in Neovim:
1. Open any code file (or create test.js)
2. Start typing: `function hello`
3. You should see **gray ghost text** appearing with suggestions!

Example:
```javascript
function hello|  ← cursor here
              ↓ 
function hello(name) {    ← gray ghost text suggestion!
  return `Hello, ${name}`;
}
```

Press `<Tab>` to accept the suggestion!

---

## ⌨️ Keybindings (Already Configured)

### In Insert Mode (While Typing)

| Key | Action |
|-----|--------|
| `<Tab>` | Accept full suggestion |
| `<M-w>` (Alt-W) | Accept next word only |
| `<M-l>` (Alt-L) | Accept next line only |
| `<C-]>` (Ctrl-]) | Clear/dismiss suggestion |
| `<M-]>` (Alt-]) | Next suggestion (if multiple) |
| `<M-[>` (Alt-[) | Previous suggestion |

### In Normal Mode (Management)

| Key | Action |
|-----|--------|
| `<leader>aw` | Toggle Codeium on/off |
| `<leader>aC` | Open Codeium Chat (browser) |
| `<leader>aA` | Authenticate Codeium |
| `<leader>aS` | Show Codeium status |

---

## 🎯 How to Use

### Basic Workflow

1. **Just type normally** - Suggestions appear automatically after 75ms
2. **See gray ghost text** - That's Codeium's suggestion
3. **Press `<Tab>`** to accept
4. **Press `<C-]>`** to dismiss
5. **Keep typing** to ignore and it disappears

### Example: Writing a Svelte Component

```svelte
<script lang="ts">
  export let title|     ← Start typing
                  ↓
  export let title = '';    ← Ghost text appears
  export let content = '';  ← Often suggests related props!
</script>

<div|     ← Start typing HTML
    ↓
<div class="card">              ← Suggests structure
  <h2>{title}</h2>              ← Context-aware!
  <p>{content}</p>
</div>
```

### Example: Writing Functions

```typescript
// Type: function fetch
function fetch|
              ↓
function fetchPosts() {           ← Suggests function name
  return fetch('/api/posts')      ← Suggests implementation
    .then(res => res.json());
}
```

### Multi-line Completions

Codeium often suggests **entire blocks**:

```javascript
// Type: if (user
if (user|
        ↓
if (user.isAuthenticated) {       ← Suggests complete if block
  // Allow access
  return true;
} else {
  // Redirect to login
  return false;
}
```

Press `<Tab>` to accept the whole block!

---

## 🎨 Works Great With Your New Svelte Setup

### Combined Workflow

**1. Use Snippets for Structure:**
```
sprop<Tab> → export let title = '';
```

**2. Use Codeium for Logic:**
```typescript
// Type: $: formatted
$: formatted|
            ↓
$: formattedTitle = title.toUpperCase().trim();  ← AI suggestion!
```

**3. Use Emmet for HTML:**
```
div.card>h2  → <C-y>,
```

**4. Use Codeium for Props:**
```svelte
<Card 
  title=|
        ↓
  title={post.title}        ← Suggests based on context
  content={post.excerpt}    ← Suggests related props
  link={`/blog/${post.slug}`}
/>
```

**Result:** Super fast development!

---

## 🔧 Advanced Features

### Codeium Chat (Browser)

```vim
<leader>aC
```

Opens browser-based chat where you can:
- Ask questions about your code
- Request refactoring suggestions
- Get explanations
- Generate boilerplate

### Toggle On/Off

```vim
<leader>aw
```

Temporarily disable if:
- You want to type without suggestions
- Working on sensitive code
- Practicing without AI

### Check Status

```vim
<leader>aS
```

Shows:
- If Codeium is active
- Current suggestion count
- Connection status

---

## 🎯 Best Practices

### When to Use Codeium

✅ **Use for:**
- Repetitive code patterns
- Boilerplate (imports, types, etc.)
- Common algorithms
- Test cases
- Documentation comments
- Converting between formats

❌ **Don't blindly accept:**
- Security-sensitive code (auth, passwords)
- Complex business logic (review carefully)
- Code you don't understand
- Suggestions with obvious errors

### Tips for Better Suggestions

1. **Write clear variable names** - Better context = better suggestions
2. **Add comments** - Describe what you want, get better completions
3. **Type function signatures first** - Get better function bodies
4. **Accept partially** - Use `<M-w>` for word-by-word if unsure

### Example: Using Comments

```typescript
// Fetch all blog posts sorted by date, newest first
export const load|
              ↓
// Codeium generates the entire load function based on your comment!
export const load: PageServerLoad = async () => {
  const posts = await db.posts.findMany({
    orderBy: { createdAt: 'desc' }
  });
  return { posts };
};
```

---

## 🐛 Troubleshooting

### Not Seeing Suggestions?

**Check 1: Is Codeium authenticated?**
```vim
:Codeium Auth
<leader>aA
```

**Check 2: Is it enabled?**
```vim
<leader>aS    " Check status
<leader>aw    " Toggle on if off
```

**Check 3: Are you in Insert mode?**
- Suggestions only appear in Insert mode
- Try typing a few characters

**Check 4: Check Codeium status in statusline**
- Should see Codeium indicator in lualine
- Look for connection status

### Suggestions Too Aggressive?

**Increase delay:**
Edit `lua/nvim/plugins/codeium.lua` and change:
```lua
idle_delay = 75,    -- Change to 200 or 300 for slower
```

**Or toggle off when focused:**
```vim
<leader>aw    " Toggle off
" Do focused work
<leader>aw    " Toggle back on
```

### Not Working for Svelte Files?

Should work automatically, but verify:
```vim
:LspInfo        " Check LSP status
:Lazy           " Check plugin is loaded
```

If issues, restart Neovim:
```vim
:qa
nvim .
```

---

## 📊 What to Expect

### Ghost Text Appearance

**Idle state:**
```svelte
<script>
  export let title = '';
  |  ← cursor, no suggestion yet
</script>
```

**After typing:**
```svelte
<script>
  export let title = '';
  export let con|  ← cursor
                ↓
  export let content = '';  ← Gray ghost text appears!
  export let author = '';   ← May suggest multiple lines
</script>
```

**Colors:**
- Ghost text appears in **gray/dim color**
- Your actual code is **normal color**
- Easy to distinguish

### Acceptance Flow

```
Type → See suggestion → Press <Tab> → Accepted and becomes real code
                     → OR press <C-]> → Dismissed
                     → OR keep typing → Suggestion updates
```

---

## 🎓 Learning Curve

**First Hour:**
- Get used to ghost text appearing
- Practice accepting with `<Tab>`
- Learn to ignore bad suggestions

**First Day:**
- Start trusting good suggestions
- Use `<M-w>` for partial acceptance
- Combine with snippets

**First Week:**
- Natural workflow integration
- Faster coding
- Less context switching to docs

---

## 🚀 Quick Start Checklist

1. ✅ Plugin installed (already done)
2. ⬜ Authenticate: `<leader>aA` or `:Codeium Auth`
3. ⬜ Open browser and sign up (free)
4. ⬜ Paste token and confirm
5. ⬜ Test in a code file
6. ⬜ Start coding!

---

## 💡 Pro Tips

### Combine All Your Tools

**Perfect Svelte Component Creation:**
```vim
1. :SvelteComponent Card      ← Template
2. sprop<Tab>                  ← Snippet for first prop
3. export let con|             ← Codeium suggests rest!
   ↓ <Tab>
   export let content = '';
   export let author = '';     ← Suggests related props
4. Type: $: formatted          ← Codeium suggests logic
5. article.card>h2<C-y>,       ← Emmet for structure
6. class="bg-                  ← Tailwind autocomplete
```

**Each tool does what it's best at:**
- Templates → File structure
- Snippets → Common patterns
- Codeium → Logic & boilerplate
- Emmet → HTML structure
- Tailwind LSP → CSS classes
- LSP → Type checking

### Context Matters

Codeium gets better suggestions from:
- Good variable names
- Clear comments
- Existing code patterns in your project
- Imported types/components

---

## 📚 Additional Resources

- **Codeium Docs:** https://codeium.com/
- **Neovim Plugin:** https://github.com/Exafunction/codeium.nvim
- **Your Config:** `~/.config/nvim/lua/nvim/plugins/codeium.lua`

---

## 🎉 Summary

**You already have Codeium configured!** Just need to:

1. Authenticate once: `<leader>aA`
2. Sign up (free, no credit card)
3. Start coding and see ghost text!

**That's it!** The plugin is already installed and configured with sensible defaults.

**Keybindings to remember:**
- `<Tab>` - Accept suggestion (in insert mode)
- `<leader>aw` - Toggle on/off
- `<leader>aA` - Authenticate

**Combined with:**
- Svelte snippets (`sprop<Tab>`)
- Emmet (`<C-y>,`)
- Tailwind autocomplete (`bg-`)
- LSP features (`K`, `gd`)

**You're ready to build blazing fast! 🚀**
