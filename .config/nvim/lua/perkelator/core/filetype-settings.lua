local opt = vim.opt

opt.tabstop = 2
opt.shiftwidth = 2
opt.expandtab = true

local augroup = vim.api.nvim_create_augroup("FileTypeSettings", { clear = true })

vim.api.nvim_create_autocmd("FileType", {
	group = augroup,
	pattern = "python",
	callback = function()
		opt.tabstop = 4
		opt.shiftwidth = 4
		opt.expandtab = true
		opt.textwidth = 88
		opt.colorcolumn = "88"
	end,
})

vim.api.nvim_create_autocmd("FileType", {
	group = augroup,
	pattern = "go",
	callback = function()
		opt.tabstop = 4
		opt.shiftwidth = 4
		opt.expandtab = false
		opt.textwidth = 120
		opt.colorcolumn = "120"
	end,
})

vim.api.nvim_create_autocmd("FileType", {
	group = augroup,
	pattern = "cs",
	callback = function()
		opt.tabstop = 4
		opt.shiftwidth = 4
		opt.expandtab = true
		opt.textwidth = 120
		opt.colorcolumn = "120"
	end,
})

vim.api.nvim_create_autocmd("FileType", {
	group = augroup,
	pattern = { "sh", "bash", "zsh" },
	callback = function()
		opt.tabstop = 2
		opt.shiftwidth = 2
		opt.expandtab = true
	end,
})

vim.api.nvim_create_autocmd("FileType", {
	group = augroup,
	pattern = "ps1",
	callback = function()
		opt.tabstop = 2
		opt.shiftwidth = 2
		opt.expandtab = true
	end,
})

vim.api.nvim_create_autocmd("FileType", {
	group = augroup,
	pattern = { "yaml", "yml" },
	callback = function()
		opt.tabstop = 2
		opt.shiftwidth = 2
		opt.expandtab = true
	end,
})

vim.api.nvim_create_autocmd("FileType", {
	group = augroup,
	pattern = "markdown",
	callback = function()
		opt.textwidth = 80
		opt.colorcolumn = "80"
		opt.wrap = true
		opt.linebreak = true
	end,
})
