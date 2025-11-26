-- This file sets all buffer-local options based on filetype
local M = {}

-- 1. Define all your settings in ONE table.
--    This is much easier to read and add to.
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
		expandtab = false, -- Use hard tabs
		textwidth = 120,
		colorcolumn = "120",
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
	
	-- Shell scripts
	["sh,bash,zsh"] = {
		tabstop = 2,
		shiftwidth = 2,
		expandtab = true,
		textwidth = 100,
		colorcolumn = "100",
	},
	ps1 = {
		tabstop = 2,
		shiftwidth = 2,
		expandtab = true,
		textwidth = 100,
		colorcolumn = "100",
	},
	
	-- YAML
	["yaml,yml"] = {
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

-- 2. This is the "engine" that runs the setup
function M.setup()
	-- Set your global defaults first (for all other files)
	vim.opt.tabstop = 2
	vim.opt.shiftwidth = 2
	vim.opt.expandtab = true
	vim.opt.wrap = false
	vim.opt.colorcolumn = "100" -- Default line length guide for unconfigured filetypes

	local augroup = vim.api.nvim_create_augroup("FileTypeSettings", { clear = true })

	-- 3. Loop over the settings table
	for patterns, settings in pairs(settings_by_ft) do
		-- Split patterns like "yaml,yml" into a list {"yaml", "yml"}
		local pattern_list = vim.split(patterns, ",")

		vim.api.nvim_create_autocmd("FileType", {
			group = augroup,
			pattern = pattern_list,
			callback = function()
				-- 4. Apply the settings as BUFFER-LOCAL
				--    This is the critical bug fix.
				local opt = vim.opt_local
				for key, value in pairs(settings) do
					opt[key] = value
				end
			end,
		})
	end
end

return M
