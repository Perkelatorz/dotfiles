vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

local opt = vim.opt

opt.relativenumber = true
opt.number = true

opt.tabstop = 2
opt.shiftwidth = 2
opt.expandtab = true
opt.autoindent = true

opt.wrap = false

opt.ignorecase = true
opt.smartcase = true
opt.showmatch = true
opt.matchtime = 1

opt.cursorline = true
opt.cursorlineopt = "number,line"

opt.termguicolors = true
opt.background = "dark"
opt.signcolumn = "yes"

opt.showtabline = 2
opt.tabline = "%!v:lua.require'nvim.core.tabline'.render()"

opt.backspace = "indent,eol,start"

opt.clipboard:append("unnamedplus")

opt.splitright = true
opt.splitbelow = true

opt.swapfile = false

opt.undofile = true
opt.undodir = vim.fn.stdpath("data") .. "/undo"
opt.undolevels = 10000
opt.undoreload = 10000

opt.scrolloff = 8
opt.sidescrolloff = 8
opt.linespace = 2

opt.hlsearch = true
opt.incsearch = true
opt.inccommand = "split"

opt.completeopt = "menu,menuone,noselect"
opt.pumheight = 10
opt.pumblend = 12
opt.winblend = 8

opt.updatetime = 250
opt.timeoutlen = 300

opt.mouse = "a"
opt.mousemoveevent = true

opt.diffopt:append("vertical")
opt.diffopt:append("algorithm:patience")
opt.diffopt:append("indent-heuristic")
opt.diffopt:append("linematch:60")

opt.wildmode = "longest:full,full"
opt.wildoptions = "pum"
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

if vim.fn.executable("rg") == 1 then
	opt.grepprg = "rg --vimgrep --no-heading --smart-case"
	opt.grepformat = "%f:%l:%c:%m"
end

if vim.fn.has("nvim-0.10") == 1 then
	opt.smoothscroll = true
end

opt.spelllang = { "en_us" }
opt.spellfile = vim.fn.stdpath("config") .. "/spell/en.utf-8.add"
opt.spelloptions = "camel"

opt.listchars = {
	tab = "→ ",
	trail = "·",
	extends = "›",
	precedes = "‹",
	nbsp = "␣",
	eol = "↴",
}
opt.list = false

opt.fillchars = {
	fold = "·",
	diff = "╱",
	eob = " ",
}

opt.sessionoptions = "blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions"

opt.autoread = true

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
