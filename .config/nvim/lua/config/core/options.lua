vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Allow hiding terminals without discarding buffers (|toggleterm.nvim|).
vim.opt.hidden = true

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

opt.cursorline = true
opt.cursorlineopt = "number,line"

opt.termguicolors = true
opt.background = "dark"
opt.signcolumn = "yes"

opt.showtabline = 1

opt.backspace = "indent,eol,start"

-- Defer to avoid startup stall when no clipboard provider is ready yet (Wayland w/o wl-clipboard).
vim.schedule(function()
	opt.clipboard:append("unnamedplus")
end)

opt.splitright = true
opt.splitbelow = true

opt.swapfile = false

-- Reload buffers when the file changed on disk (CLI/AI outside Neovim) without extra prompts when safe.
opt.autoread = true

opt.undofile = true
opt.undodir = vim.fn.stdpath("data") .. "/undo"
opt.undolevels = 10000

opt.scrolloff = 4
opt.sidescrolloff = 4

opt.hlsearch = true
opt.incsearch = true

opt.updatetime = 400
opt.timeoutlen = 500

opt.mouse = "a"

opt.wildmode = "longest:full,full"

opt.inccommand = "split"
opt.confirm = true
opt.smoothscroll = true
opt.shortmess:append("I")
opt.fillchars = { eob = " " }
opt.completeopt = "menu,menuone,noselect"
opt.virtualedit = "block"
opt.jumpoptions = "stack,view"

if vim.fn.executable("rg") == 1 then
	opt.grepprg = "rg --vimgrep --no-heading --smart-case"
	opt.grepformat = "%f:%l:%c:%m"
end

-- Visible whitespace (Nerd Font terminal recommended for full glyph coverage)
opt.list = true
opt.listchars = { tab = "▸ ", trail = "·", nbsp = "␣", precedes = "⟨", extends = "⟩" }

vim.diagnostic.config({
	virtual_text = { prefix = "●", spacing = 2 },
	signs = {
		text = {
			[vim.diagnostic.severity.ERROR] = "󰅙",
			[vim.diagnostic.severity.WARN] = "󰀪",
			[vim.diagnostic.severity.INFO] = "󰋽",
			[vim.diagnostic.severity.HINT] = "󰌶",
		},
	},
	float = { border = "rounded" },
	severity_sort = true,
})
