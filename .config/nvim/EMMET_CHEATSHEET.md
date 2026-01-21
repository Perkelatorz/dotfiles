# Emmet Cheatsheet

Quick reference for Emmet abbreviations in Neovim. Emmet works in HTML, CSS, Svelte, Vue, JSX, and other web filetypes.

## 🚀 How to Use Emmet in Neovim

1. **Type an Emmet abbreviation** (e.g., `div.container`)
2. **Trigger completion**:
   - Automatic: Completions appear as you type
   - Manual: Press `<C-Space>`, `<C-@>`, or `<leader>,` (Space + comma)
3. **Select the `[LSP]` suggestion** and press `<Enter>`
4. **Result**: Abbreviation expands to full HTML

---

## 📝 HTML Elements

### Basic Elements
```
div          → <div></div>
p            → <p></p>
span         → <span></span>
a            → <a href=""></a>
img          → <img src="" alt="" />
input        → <input type="text" />
button       → <button></button>
```

### Self-Closing Tags
```
br           → <br />
hr           → <hr />
meta         → <meta />
link         → <link rel="stylesheet" href="" />
```

---

## 🎯 CSS Selectors

### Classes
```
div.container        → <div class="container"></div>
p.text              → <p class="text"></p>
.header             → <div class="header"></div>
```

### IDs
```
div#main            → <div id="main"></div>
#sidebar            → <div id="sidebar"></div>
p#intro             → <p id="intro"></p>
```

### Multiple Classes/IDs
```
div.container.main  → <div class="container main"></div>
div#header.nav      → <div id="header" class="nav"></div>
p.text.lead#intro   → <p class="text lead" id="intro"></p>
```

### Attributes
```
a[href="#"]         → <a href="#"></a>
input[type="text"]   → <input type="text" />
img[src="logo.png"] → <img src="logo.png" alt="" />
div[data-id="1"]    → <div data-id="1"></div>
```

---

## 🌳 Nesting & Hierarchy

### Child Elements (>)
```
div>p               → <div><p></p></div>
ul>li               → <ul><li></li></ul>
nav>ul>li           → <nav><ul><li></li></ul></nav>
div>p>span          → <div><p><span></span></p></div>
```

### Siblings (+)
```
div+p               → <div></div><p></p>
h1+p+span           → <h1></h1><p></p><span></span>
li+li+li            → <li></li><li></li><li></li>
```

### Climb Up (^)
```
div>p>span^a       → <div><p><span></span></p><a href=""></a></div>
div>p>span^div      → <div><p><span></span></p><div></div></div>
```

### Grouping (())
```
div>(header>nav)+main+footer
→ <div>
    <header><nav></nav></header>
    <main></main>
    <footer></footer>
  </div>

(div>p)+(div>span)
→ <div><p></p></div>
  <div><span></span></div>
```

---

## 🔢 Multiplication (*)

### Multiple Elements
```
ul>li*5             → <ul>
                        <li></li>
                        <li></li>
                        <li></li>
                        <li></li>
                        <li></li>
                      </ul>

div*3               → <div></div><div></div><div></div>
```

### With Classes
```
.item*4             → <div class="item"></div>
                      <div class="item"></div>
                      <div class="item"></div>
                      <div class="item"></div>
```

---

## 📋 Numbering ($)

### Sequential Numbers
```
.item$*3            → <div class="item1"></div>
                      <div class="item2"></div>
                      <div class="item3"></div>

li.item$*5          → <li class="item1"></li>
                      <li class="item2"></li>
                      <li class="item3"></li>
                      <li class="item4"></li>
                      <li class="item5"></li>
```

### In Attributes
```
.item$#item$*3      → <div class="item1" id="item1"></div>
                      <div class="item2" id="item2"></div>
                      <div class="item3" id="item3"></div>

img[src="photo$.jpg"]*3
→ <img src="photo1.jpg" alt="" />
  <img src="photo2.jpg" alt="" />
  <img src="photo3.jpg" alt="" />
```

### Zero-Padding ($$)
```
.item$$*3           → <div class="item01"></div>
                      <div class="item02"></div>
                      <div class="item03"></div>
```

### Reverse Order ($$@-)
```
.item$@-*3          → <div class="item3"></div>
                      <div class="item2"></div>
                      <div class="item1"></div>
```

### Custom Start ($$@3)
```
.item$@3*3          → <div class="item3"></div>
                      <div class="item4"></div>
                      <div class="item5"></div>
```

---

## 📝 Text Content ({text})

### Adding Text
```
p{Hello World}      → <p>Hello World</p>
a{Click me}         → <a href="">Click me</a>
button{Submit}      → <button>Submit</button>
```

### With Multiple Elements
```
p{Text}+span{More}  → <p>Text</p><span>More</span>
div>p{First}+p{Second}
→ <div>
    <p>First</p>
    <p>Second</p>
  </div>
```

### With Numbering
```
.item${Item $}*3    → <div class="item1">Item 1</div>
                      <div class="item2">Item 2</div>
                      <div class="item3">Item 3</div>
```

---

## 🎨 Common HTML Structures

### Navigation
```
nav>ul>li*3>a{Link $}
→ <nav>
    <ul>
      <li><a href="">Link 1</a></li>
      <li><a href="">Link 2</a></li>
      <li><a href="">Link 3</a></li>
    </ul>
  </nav>
```

### Form
```
form>input[type="text"]+input[type="email"]+button{Submit}
→ <form>
    <input type="text" />
    <input type="email" />
    <button>Submit</button>
  </form>
```

### Card Layout
```
.card>img+h3{Title}+p{Description}+button{Action}
→ <div class="card">
    <img src="" alt="" />
    <h3>Title</h3>
    <p>Description</p>
    <button>Action</button>
  </div>
```

### Table
```
table>thead>tr>th*3{Header $}+tbody>tr>td*3{Data $}
→ <table>
    <thead>
      <tr>
        <th>Header 1</th>
        <th>Header 2</th>
        <th>Header 3</th>
      </tr>
    </thead>
    <tbody>
      <tr>
        <td>Data 1</td>
        <td>Data 2</td>
        <td>Data 3</td>
      </tr>
    </tbody>
  </table>
```

### Bootstrap Grid
```
.container>.row>.col-md-6*2
→ <div class="container">
    <div class="row">
      <div class="col-md-6"></div>
      <div class="col-md-6"></div>
    </div>
  </div>
```

---

## 🎯 CSS Abbreviations

### Properties
```
m10               → margin: 10px;
p20               → padding: 20px;
w100              → width: 100px;
h50               → height: 50px;
m10-20            → margin: 10px 20px;
p10-20-30-40      → padding: 10px 20px 30px 40px;
```

### Units
```
m10p              → margin: 10%;
w50r              → width: 50rem;
h100vh            → height: 100vh;
m1e               → margin: 1em;
```

### Colors
```
c#f00             → color: #ff0000;
bg#fff            → background: #ffffff;
bd#000            → border: #000000;
```

### Fonts
```
fz16              → font-size: 16px;
fw700             → font-weight: 700;
ffArial           → font-family: Arial;
```

### Positioning
```
posr              → position: relative;
posa              → position: absolute;
posf              → position: fixed;
t10               → top: 10px;
l20               → left: 20px;
```

### Flexbox
```
d:f               → display: flex;
fxw               → flex-wrap: wrap;
jcc               → justify-content: center;
aic               → align-items: center;
```

### Grid
```
d:g               → display: grid;
gtc:r              → grid-template-columns: repeat();
gtr:r              → grid-template-rows: repeat();
```

---

## 🔥 Advanced Examples

### Complete Page Structure
```
html:5
→ <!DOCTYPE html>
  <html lang="en">
  <head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Document</title>
  </head>
  <body>
    
  </body>
  </html>
```

### Svelte Component Structure
```
.svelte>script+main>h1{Title}+p{Content}
→ <div class="svelte">
    <script></script>
    <main>
      <h1>Title</h1>
      <p>Content</p>
    </main>
  </div>
```

### Complex Navigation
```
nav.navbar>div.container>a.logo{Logo}+ul.menu>(li>a{Home})+(li>a{About})+(li>a{Contact})
→ <nav class="navbar">
    <div class="container">
      <a href="" class="logo">Logo</a>
      <ul class="menu">
        <li><a href="">Home</a></li>
        <li><a href="">About</a></li>
        <li><a href="">Contact</a></li>
      </ul>
    </div>
  </nav>
```

### Product Grid
```
.grid>.card*6>img[src="product$.jpg"]+h3{Product $}+p{Description $}+button{Add to Cart}
→ <div class="grid">
    <div class="card">
      <img src="product1.jpg" alt="" />
      <h3>Product 1</h3>
      <p>Description 1</p>
      <button>Add to Cart</button>
    </div>
    <!-- ... 5 more cards ... -->
  </div>
```

---

## 🎨 Pico CSS Framework

Pico CSS is a minimal CSS framework. Here are Emmet abbreviations for common Pico components:

### Layout & Structure
```
.container          → <div class="container"></div>
.container-fluid    → <div class="container-fluid"></div>
.grid               → <div class="grid"></div>
```

### Semantic HTML (Pico uses semantic tags)
```
header              → <header></header>
main                → <main></main>
footer              → <footer></footer>
nav                 → <nav></nav>
aside               → <aside></aside>
article             → <article></article>
section             → <section></section>
```

### Cards & Articles
```
article.card        → <article class="card"></article>
article>header+h3{Title}+p{Content}+footer
→ <article>
    <header></header>
    <h3>Title</h3>
    <p>Content</p>
    <footer></footer>
  </article>
```

### Navigation
```
nav>ul>li*3>a[href="#"]{Link $}
→ <nav>
    <ul>
      <li><a href="#">Link 1</a></li>
      <li><a href="#">Link 2</a></li>
      <li><a href="#">Link 3</a></li>
    </ul>
  </nav>
```

### Buttons
```
button              → <button></button>
button.primary      → <button class="primary"></button>
button.secondary    → <button class="secondary"></button>
button.contrast     → <button class="contrast"></button>
button.outline       → <button class="outline"></button>
a[role="button"]    → <a href="" role="button"></a>
```

### Forms
```
form>label+input[type="text"]+small+button{Submit}
→ <form>
    <label></label>
    <input type="text" />
    <small></small>
    <button>Submit</button>
  </form>

input[type="text"][placeholder="Name"]
→ <input type="text" placeholder="Name" />

input[type="email"][placeholder="Email"]
→ <input type="email" placeholder="Email" />

input[type="password"][placeholder="Password"]
→ <input type="password" placeholder="Password" />

input[type="checkbox"]+label
→ <input type="checkbox" /><label></label>

input[type="radio"]+label
→ <input type="radio" /><label></label>

select>option*3{Option $}
→ <select>
    <option>Option 1</option>
    <option>Option 2</option>
    <option>Option 3</option>
  </select>

textarea[placeholder="Message"]
→ <textarea placeholder="Message"></textarea>
```

### Grid System
```
.grid>div*3         → <div class="grid">
                        <div></div>
                        <div></div>
                        <div></div>
                      </div>

.grid>article*4     → <div class="grid">
                        <article></article>
                        <article></article>
                        <article></article>
                        <article></article>
                      </div>
```

### Typography
```
h1                  → <h1></h1>
h2                  → <h2></h2>
h3                  → <h3></h3>
h4                  → <h4></h4>
h5                  → <h5></h5>
h6                  → <h6></h6>
p                   → <p></p>
small               → <small></small>
mark                → <mark></mark>
kbd                 → <kbd></kbd>
code                → <code></code>
pre>code            → <pre><code></code></pre>
```

### Tables
```
table>thead>tr>th*3{Header $}+tbody>tr>td*3{Data $}
→ <table>
    <thead>
      <tr>
        <th>Header 1</th>
        <th>Header 2</th>
        <th>Header 3</th>
      </tr>
    </thead>
    <tbody>
      <tr>
        <td>Data 1</td>
        <td>Data 2</td>
        <td>Data 3</td>
      </tr>
    </tbody>
  </table>
```

### Details & Accordion
```
details>summary{Title}+p{Content}
→ <details>
    <summary>Title</summary>
    <p>Content</p>
  </details>
```

### Progress & Meters
```
progress[value="50"][max="100"]
→ <progress value="50" max="100"></progress>

meter[value="75"][min="0"][max="100"]
→ <meter value="75" min="0" max="100"></meter>
```

### Complete Pico Page Structure
```
html:5>head>meta[charset="UTF-8"]+meta[name="viewport"][content="width=device-width, initial-scale=1.0"]+title{Page Title}+link[rel="stylesheet"][href="https://cdn.jsdelivr.net/npm/@picocss/pico@1/css/pico.min.css"]+body>header.container>nav>ul>li*3>a[href="#"]{Link $}^main.container>article>h1{Title}+p{Content}+footer.container>p{Footer}
→ <!DOCTYPE html>
  <html lang="en">
  <head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Page Title</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/@picocss/pico@1/css/pico.min.css">
  </head>
  <body>
    <header class="container">
      <nav>
        <ul>
          <li><a href="#">Link 1</a></li>
          <li><a href="#">Link 2</a></li>
          <li><a href="#">Link 3</a></li>
        </ul>
      </nav>
    </header>
    <main class="container">
      <article>
        <h1>Title</h1>
        <p>Content</p>
      </article>
    </main>
    <footer class="container">
      <p>Footer</p>
    </footer>
  </body>
  </html>
```

### Pico Card Grid
```
.grid>article.card*6>header>h3{Card $}+p{Description $}+footer>button{Action}
→ <div class="grid">
    <article class="card">
      <header>
        <h3>Card 1</h3>
        <p>Description 1</p>
      </header>
      <footer>
        <button>Action</button>
      </footer>
    </article>
    <!-- ... 5 more cards ... -->
  </div>
```

### Pico Form Example
```
form>fieldset>legend{Form Title}+label[for="name"]{Name}+input[type="text"][id="name"][name="name"][required]+label[for="email"]{Email}+input[type="email"][id="email"][name="email"][required]+label[for="message"]{Message}+textarea[id="message"][name="message"][required]+button[type="submit"]{Submit}
→ <form>
    <fieldset>
      <legend>Form Title</legend>
      <label for="name">Name</label>
      <input type="text" id="name" name="name" required />
      <label for="email">Email</label>
      <input type="email" id="email" name="email" required />
      <label for="message">Message</label>
      <textarea id="message" name="message" required></textarea>
      <button type="submit">Submit</button>
    </fieldset>
  </form>
```

### Pico Modal/Dialog
```
dialog#modal>article>header>h2{Modal Title}+a[href="#close"][aria-label="Close"]{×}^p{Modal content}+footer>button{Close}
→ <dialog id="modal">
    <article>
      <header>
        <h2>Modal Title</h2>
        <a href="#close" aria-label="Close">×</a>
      </header>
      <p>Modal content</p>
      <footer>
        <button>Close</button>
      </footer>
    </article>
  </dialog>
```

### Pico Navigation Bar
```
header.container>nav>ul>li>strong{Logo}+li*4>a[href="#"]{Link $}
→ <header class="container">
    <nav>
      <ul>
        <li><strong>Logo</strong></li>
        <li><a href="#">Link 1</a></li>
        <li><a href="#">Link 2</a></li>
        <li><a href="#">Link 3</a></li>
        <li><a href="#">Link 4</a></li>
      </ul>
    </nav>
  </header>
```

### Pico Article with Header/Footer
```
article>header>h1{Article Title}+p{By Author}^main>p>lorem^footer>small{Published on 2024}
→ <article>
    <header>
      <h1>Article Title</h1>
      <p>By Author</p>
    </header>
    <main>
      <p>Lorem ipsum dolor sit amet...</p>
    </main>
    <footer>
      <small>Published on 2024</small>
    </footer>
  </article>
```

### Pico Button Group
```
div>button.primary{Primary}+button.secondary{Secondary}+button.contrast{Contrast}
→ <div>
    <button class="primary">Primary</button>
    <button class="secondary">Secondary</button>
    <button class="contrast">Contrast</button>
  </div>
```

### Pico Input Group
```
div>label[for="search"]{Search}+input[type="search"][id="search"][name="search"]+button[type="submit"]{Go}
→ <div>
    <label for="search">Search</label>
    <input type="search" id="search" name="search" />
    <button type="submit">Go</button>
  </div>
```

---

## 💡 Tips & Tricks

1. **Default Elements**: If you omit the tag name, `div` is assumed
   - `.container` → `<div class="container"></div>`
   - `#main` → `<div id="main"></div>`

2. **Lorem Ipsum**: Use `lorem` or `lipsum` for placeholder text
   - `p>lorem` → `<p>Lorem ipsum dolor sit amet...</p>`
   - `p>lorem10` → `<p>Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod.</p>`

3. **Wrap with Abbreviation**: Select text and wrap it
   - Select text → Type abbreviation → Expand

4. **Update Tag**: Change element type
   - `div` → Type new tag → Expand

5. **Balance Tag**: Navigate between opening/closing tags
   - Useful for nested structures

---

## 🎯 Quick Reference

| Symbol | Meaning |
|--------|---------|
| `>` | Child |
| `+` | Sibling |
| `^` | Climb up |
| `*` | Multiply |
| `$` | Number |
| `()` | Group |
| `[]` | Attributes |
| `{}` | Text |
| `#` | ID |
| `.` | Class |

---

## 📚 Supported Filetypes

Emmet works in these filetypes in your Neovim config:
- ✅ HTML
- ✅ CSS, SCSS, SASS, LESS
- ✅ Svelte
- ✅ Vue
- ✅ JavaScript React (JSX)
- ✅ TypeScript React (TSX)

---

## 🔧 Troubleshooting

**Completions not showing?**
1. Check LSP is running: `:LspInfo`
2. Verify filetype: `:set filetype?`
3. Try manual trigger: `<leader>,` (Space + comma)
4. Check Emmet LSP is installed: `:Mason`

**Expansion not working?**
1. Make sure you're in insert mode
2. Select the `[LSP]` suggestion from Emmet
3. Press `<Enter>` to confirm

---

*Happy coding with Emmet! 🚀*
