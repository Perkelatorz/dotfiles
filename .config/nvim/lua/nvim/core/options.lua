-- Disable netrw (using nvim-tree and oil instead)
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

local opt = vim.opt -- for conciseness

-- line numbers
opt.relativenumber = true -- show relative line numbers
opt.number = true -- shows absolute line number on cursor line (when relative number is on)

-- tabs & indentation
opt.tabstop = 2 -- 2 spaces for tabs (prettier default)
opt.shiftwidth = 2 -- 2 spaces for indent width
opt.expandtab = true -- expand tab to spaces
opt.autoindent = true -- copy indent from current line when starting new one

-- line wrapping
opt.wrap = false -- disable line wrapping

-- search settings
opt.ignorecase = true -- ignore case when searching
opt.smartcase = true -- if you include mixed case in your search, assumes you want case-sensitive
opt.showmatch = true -- highlight matching brackets
opt.matchtime = 1 -- time to show matching bracket (in tenths of a second)

-- cursor line
opt.cursorline = true -- highlight the current cursor line
opt.cursorlineopt = "number,line" -- Only highlight line number and line, not entire screen

-- appearance

-- turn on termguicolors for colorscheme to work
-- (have to use iterm2 or any other true color terminal)
opt.termguicolors = true
opt.background = "dark" -- Purpleator theme
opt.signcolumn = "yes" -- show sign column so that text doesn't shift

-- Tabline (show tab bar at top)
opt.showtabline = 2 -- always show tabline
opt.tabline = "%!v:lua.require'nvim.core.tabline'.render()" -- custom tabline

-- backspace
opt.backspace = "indent,eol,start" -- allow backspace on indent, end of line or insert mode start position

-- clipboard
opt.clipboard:append("unnamedplus") -- use system clipboard as default register

-- split windows
opt.splitright = true -- split vertical window to the right
opt.splitbelow = true -- split horizontal window to the bottom

-- turn off swapfile
opt.swapfile = false

-- Persistent undo (keep undo history across sessions)
opt.undofile = true
opt.undodir = vim.fn.stdpath("data") .. "/undo"
opt.undolevels = 10000
opt.undoreload = 10000

-- Better scrolling
opt.scrolloff = 8 -- keep 8 lines above/below cursor
opt.sidescrolloff = 8 -- keep 8 columns left/right of cursor

-- Better search
opt.hlsearch = true -- highlight all search matches
opt.incsearch = true -- show match as you type
opt.inccommand = "split" -- show live preview of substitutions

-- Better completion
opt.completeopt = "menu,menuone,noselect"
opt.pumheight = 10 -- maximum number of items in popup menu
opt.pumblend = 12 -- popup menu transparency (completion, cmdline)
opt.winblend = 8 -- floating windows blend with background (diagnostics, LSP, etc.)

-- Faster completion and better experience
opt.updatetime = 250 -- faster completion (default is 4000ms)
opt.timeoutlen = 300 -- time to wait for mapped sequence

-- Mouse support
opt.mouse = "a" -- enable mouse support in all modes
opt.mousemoveevent = true -- enable mouse move events (for hover, etc.)

-- Better diff mode
opt.diffopt:append("vertical") -- vertical diff splits by default
opt.diffopt:append("algorithm:patience") -- better diff algorithm
opt.diffopt:append("indent-heuristic") -- use indentation for diff
opt.diffopt:append("linematch:60") -- enable second-stage diff on individual hunks (Neovim 0.9+)

-- Command line
opt.wildmode = "longest:full,full" -- command line completion mode
opt.wildoptions = "pum" -- show completion in popup menu
opt.wildignore:append({
	"*.pyc",
	"*_build/*",
	"**/coverage/*",
	"**/node_modules/*",
	"**/android/*",
	"**/ios/*",
	"**/.git/*",
	"**/dist/*",
	"**/build/*",
})

-- Use ripgrep for :grep if available
if vim.fn.executable("rg") == 1 then
	opt.grepprg = "rg --vimgrep --no-heading --smart-case"
	opt.grepformat = "%f:%l:%c:%m"
end

-- Smooth scrolling (Neovim 0.10+)
if vim.fn.has("nvim-0.10") == 1 then
	opt.smoothscroll = true
end

-- Spell checking
opt.spelllang = { "en_us" }
opt.spellfile = vim.fn.stdpath("config") .. "/spell/en.utf-8.add" -- Custom dictionary location
opt.spelloptions = "camel" -- Recognize camelCase words as separate words

-- Whitespace visualization (toggled with <leader>tl)
opt.listchars = {
	tab = "→ ",
	trail = "·",
	extends = "›",
	precedes = "‹",
	nbsp = "␣",
	eol = "↴",
}
opt.list = false -- Disabled by default, toggle with <leader>tl

-- Better fillchars (for folds, diffs, etc.)
opt.fillchars = {
	fold = "·",
	diff = "╱",
	eob = " ", -- Empty lines at end of buffer
}

-- session options (required for auto-session to work correctly)
opt.sessionoptions = "blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions"

-- Auto-reload files when changed on disk (e.g. Cursor IDE, external editors)
opt.autoread = true

-- Filetype detection (must be set up early, before plugins load)
vim.filetype.add({
	extension = {
		svelte = "svelte",
		hl = "hyprlang",
		sh = "bash",
	},
	pattern = {
		["hypr*.conf"] = "hyprlang",
		["hypr/.*%.conf"] = "hyprlang",
		[".*bashrc"] = "bash",
		[".*bash_profile"] = "bash",
		[".*bash_aliases"] = "bash",
	},
})
