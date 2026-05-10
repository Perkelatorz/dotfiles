--- Status line: mode, git branch, diagnostics, file, filetype, location.
--- Uses |:help 'laststatus'| 3 (global statusline). |showmode| off—mode is on the line.

local M = {}

function M.setup()
	vim.opt.laststatus = 3
	vim.opt.showmode = false

	require("lualine").setup({
		options = {
			icons_enabled = true,
			theme = require("config.plugins.lualine_theme_purpleator").make(),
			component_separators = { left = "·", right = "·" },
			section_separators = { left = "", right = "" },
			globalstatus = true,
			disabled_filetypes = { statusline = { "qf", "help" } },
		},
		sections = {
			lualine_a = { "mode" },
			lualine_b = {
				"branch",
				{ "diff", source = "gitsigns" },
				{
					"diagnostics",
					sources = { "nvim_diagnostic" },
					sections = { "error", "warn", "info", "hint" },
				},
			},
			lualine_c = {
				{
					"filename",
					path = 1,
					symbols = { modified = " ○", readonly = " ", unnamed = " …" },
				},
			},
			lualine_x = { "encoding", "fileformat", "filetype" },
			lualine_y = { "progress" },
			lualine_z = { "location" },
		},
		inactive_sections = {
			lualine_a = { "filename" },
			lualine_b = {},
			lualine_c = {},
			lualine_x = { "location" },
			lualine_y = {},
			lualine_z = {},
		},
		extensions = { "neo-tree", "quickfix", "toggleterm" },
	})
end

return M
