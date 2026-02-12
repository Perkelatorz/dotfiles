# Emmet Cheatsheet

Works in HTML, CSS, Svelte, Vue, JSX. Type abbreviation → trigger completion (`C-Space` or `C-@`) → Enter.

## Selectors

```
div.container        → <div class="container"></div>
#main                → <div id="main"></div>
div.container.main   → <div class="container main"></div>
a[href="#"]          → <a href="#"></a>
input[type="text"]   → <input type="text" />
```

## Nesting

```
div>p               → <div><p></p></div>
ul>li*5             → <ul><li></li>...</li></ul>
div+p               → <div></div><p></p>
div>(header+main)   → <div><header></header><main></main></div>
```

## Multiplication & Numbering

```
li*5                → 5 <li></li>
.item$*3            → class="item1", "item2", "item3"
.item$$*3           → item01, item02 (zero-pad)
.item$@3*3          → start at 3: item3, item4, item5
```

## Text

```
p{Hello}            → <p>Hello</p>
a{Click}+span{!}    → <a href="">Click</a><span>!</span>
```

## Common

```
div>header>nav+main+footer
ul>li.item$*5
form>input[type="text"]+input[type="submit"]
```
