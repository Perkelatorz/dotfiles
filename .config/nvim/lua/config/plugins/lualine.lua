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
			lualine_x = {
				{
					-- Codeium ghost-text indicator: "󰘦 N/M" suggestion count, "󰘦 *" thinking,
					-- "󰘦 0" idle. See codeium/virtual_text.lua status_string().
					function()
						return "󰘦 " .. require("codeium.virtual_text").status_string()
					end,
					cond = function()
						return pcall(require, "codeium.virtual_text")
					end,
				},
				"encoding",
				"fileformat",
				"filetype",
			},
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

	-- Let Codeium force a lualine redraw when suggestion state changes, so the
	-- "󰘦 N/M" indicator above keeps pace with the inline ghost text instead of
	-- lagging until lualine's next refresh tick.
	local ok, vt = pcall(require, "codeium.virtual_text")
	if ok then
		vt.set_statusbar_refresh(function()
			require("lualine").refresh()
		end)
	end
end

return M
