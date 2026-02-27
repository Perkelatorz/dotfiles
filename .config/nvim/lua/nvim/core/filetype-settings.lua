-- This file sets all buffer-local options based on filetype
local M = {}

local settings_by_ft = {
	python = {
		tabstop = 4,
		shiftwidth = 4,
		expandtab = true,
		textwidth = 88,
		colorcolumn = "88",
	},
	go = {
		tabstop = 4,
		shiftwidth = 4,
		expandtab = false, -- Use hard tabs (Go convention)
		textwidth = 120,
		colorcolumn = "120",
	},
	gomod = {
		tabstop = 4,
		shiftwidth = 4,
		expandtab = false,
	},
	gowork = {
		tabstop = 4,
		shiftwidth = 4,
		expandtab = false,
	},
	gosum = {
		tabstop = 4,
		shiftwidth = 4,
		expandtab = false,
	},
	cs = {
		tabstop = 4,
		shiftwidth = 4,
		expandtab = true,
		textwidth = 120,
		colorcolumn = "120",
	},
	markdown = {
		textwidth = 80,
		colorcolumn = "80",
		wrap = true,
		linebreak = true,
		tabstop = 2, -- Good to be explicit
		shiftwidth = 2,
	},

	-- JavaScript/TypeScript
	javascript = {
		tabstop = 2,
		shiftwidth = 2,
		expandtab = true,
		textwidth = 100,
		colorcolumn = "100",
	},
	typescript = {
		tabstop = 2,
		shiftwidth = 2,
		expandtab = true,
		textwidth = 100,
		colorcolumn = "100",
	},
	javascriptreact = {
		tabstop = 2,
		shiftwidth = 2,
		expandtab = true,
		textwidth = 100,
		colorcolumn = "100",
	},
	typescriptreact = {
		tabstop = 2,
		shiftwidth = 2,
		expandtab = true,
		textwidth = 100,
		colorcolumn = "100",
	},
	
	sh = {
		tabstop = 2,
		shiftwidth = 2,
		expandtab = true,
		textwidth = 100,
		colorcolumn = "100",
	},
	bash = {
		tabstop = 2,
		shiftwidth = 2,
		expandtab = true,
		textwidth = 100,
		colorcolumn = "100",
	},
	zsh = {
		tabstop = 2,
		shiftwidth = 2,
		expandtab = true,
		textwidth = 100,
		colorcolumn = "100",
	},

	hyprlang = {
		tabstop = 4,
		shiftwidth = 4,
		expandtab = true,
		textwidth = 120,
		colorcolumn = "120",
	},
	ps1 = {
		tabstop = 2,
		shiftwidth = 2,
		expandtab = true,
		textwidth = 100,
		colorcolumn = "100",
	},
	
	yaml = {
		tabstop = 2,
		shiftwidth = 2,
		expandtab = true,
		textwidth = 80,
		colorcolumn = "80",
	},
	yml = {
		tabstop = 2,
		shiftwidth = 2,
		expandtab = true,
		textwidth = 80,
		colorcolumn = "80",
	},
	
	-- JSON
	json = {
		tabstop = 2,
		shiftwidth = 2,
		expandtab = true,
		textwidth = 100,
		colorcolumn = "100",
	},
	
	-- HTML/CSS
	html = {
		tabstop = 2,
		shiftwidth = 2,
		expandtab = true,
		textwidth = 120,
		colorcolumn = "120",
	},
	css = {
		tabstop = 2,
		shiftwidth = 2,
		expandtab = true,
		textwidth = 120,
		colorcolumn = "120",
	},
	scss = {
		tabstop = 2,
		shiftwidth = 2,
		expandtab = true,
		textwidth = 120,
		colorcolumn = "120",
	},
	
	-- Svelte
	svelte = {
		tabstop = 2,
		shiftwidth = 2,
		expandtab = true,
		textwidth = 100,
		colorcolumn = "100",
	},
	
	-- Lua
	lua = {
		tabstop = 2,
		shiftwidth = 2,
		expandtab = true,
		textwidth = 100,
		colorcolumn = "100",
	},
	
	-- Terraform/HCL
	terraform = {
		tabstop = 2,
		shiftwidth = 2,
		expandtab = true,
		textwidth = 100,
		colorcolumn = "100",
	},
	hcl = {
		tabstop = 2,
		shiftwidth = 2,
		expandtab = true,
		textwidth = 100,
		colorcolumn = "100",
	},
	
	-- Dockerfile
	dockerfile = {
		tabstop = 2,
		shiftwidth = 2,
		expandtab = true,
		textwidth = 100,
		colorcolumn = "100",
	},
	
	-- XML
	xml = {
		tabstop = 2,
		shiftwidth = 2,
		expandtab = true,
		textwidth = 120,
		colorcolumn = "120",
	},
}

function M.setup()
	-- Set your global defaults first (for all other files)
	vim.opt.tabstop = 2
	vim.opt.shiftwidth = 2
	vim.opt.expandtab = true
	vim.opt.wrap = false
	vim.opt.colorcolumn = "100" -- Default line length guide for unconfigured filetypes

	local augroup = vim.api.nvim_create_augroup("FileTypeSettings", { clear = true })

	for ft, settings in pairs(settings_by_ft) do
		vim.api.nvim_create_autocmd("FileType", {
			group = augroup,
			pattern = ft,
			callback = function()
				local opt = vim.opt_local
				for key, value in pairs(settings) do
					opt[key] = value
				end
			end,
		})
	end
end

return M
