return {
	"nvim-lualine/lualine.nvim",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	config = function()
		local utils = require("nvim.core.utils")
		
		local lualine, lualine_ok = utils.safe_require("lualine")
		if not lualine_ok then
			return
		end
		
		local lazy_status, lazy_status_ok = utils.safe_require("lazy.status")
		if not lazy_status_ok then
			return
		end

		-- Purpleator palette (from colorscheme: black bg, pastel purples)
		local c = _G.alabaster_colors or {}
		local colors = {
			fg0 = c.fg0 or "#f2f0f4",
			bg0 = c.bg0 or "#000000",
			bg1 = c.bg1 or "#0d0c0f",
			control = c.control or "#c4b5fd",
			callable = c.callable or "#e9d5ff",
			type = c.type or "#a5b4fc",
			comment = c.comment or "#6b7280",
			error = c.error or "#fca5a5",
			warn = c.warn or "#fcd34d",
			string_color = c.string_color or "#f9a8d4",
		}

		lualine.setup({
			options = {
				theme = "auto",
				component_separators = { left = "", right = "▐" },
				section_separators = { left = "", right = "" },
				disabled_filetypes = {
					statusline = { "alpha", "dashboard" },
				},
				globalstatus = true,
			},
			sections = {
				lualine_a = {
					{
						"mode",
						icons_enabled = true,
						fmt = function(str)
							local mode_icons = {
								n = "󰈔", i = "󰌌", v = "󰆍", V = "󰆍", ["\22"] = "󰆍",
								c = "󰘳", s = "󰆐", S = "󰆐", ["\19"] = "󰆐",
								R = "󰒞", r = "󰒞", ["!"] = "󰆍", t = "󰆍",
							}
							return (mode_icons[str] or "󰈔") .. " " .. str:sub(1, 1)
						end,
						separator = { left = "", right = "▐" },
						color = { fg = colors.fg0, bg = colors.bg1 },
					},
				},
				lualine_b = {
					{
						"branch",
						icon = "󰘬",
						separator = { left = "", right = "▐" },
						color = { fg = colors.control, gui = "bold" },
					},
					{
						"diff",
						symbols = { added = "󰐖 ", modified = "󰏬 ", removed = "󰍴 " },
						separator = { left = "", right = "▐" },
						diff_color = {
							added = { fg = colors.comment },
							modified = { fg = colors.warn },
							removed = { fg = colors.error },
						},
					},
					{
						"diagnostics",
						symbols = { error = "󰅚 ", warn = "󰀪 ", info = "󰋽 ", hint = "󰌶 " },
						separator = { left = "", right = "▐" },
						diagnostics_color = {
							error = { fg = colors.error },
							warn = { fg = colors.warn },
							info = { fg = colors.type },
							hint = { fg = colors.type },
						},
					},
				},
				lualine_c = {
					{
						"filename",
						path = 1,
						symbols = {
							modified = " 󰏬",
							readonly = " 󰌾",
							unnamed = " 󰈔",
							newfile = " 󰎔",
						},
						color = { fg = colors.fg0 },
					},
				},
				lualine_x = {
					{
						"filetype",
						icon_only = false,
						icon = { align = "right" },
						separator = { left = "▐", right = "" },
						color = { fg = colors.control },
					},
					{
						lazy_status.updates,
						cond = lazy_status.has_updates,
						color = { fg = colors.warn, gui = "bold" },
						icon = "󰑓",
						separator = { left = "▐", right = "" },
					},
					{
						"encoding",
						icon = "󰨞",
						separator = { left = "▐", right = "" },
						color = { fg = colors.type },
					},
					{
						"fileformat",
						symbols = { unix = "󰘧", dos = "󰘧", mac = "󰘧" },
						separator = { left = "▐", right = "" },
						color = { fg = colors.string_color },
					},
					{
						"location",
						icon = "󰦨",
						separator = { left = "▐", right = "" },
						color = { fg = colors.type },
					},
					{
						"progress",
						icon = "󰦞",
						separator = { left = "▐", right = "" },
						color = { fg = colors.callable },
					},
				},
				lualine_y = {},
				lualine_z = {},
			},
			inactive_sections = {
				lualine_a = {},
				lualine_b = {},
				lualine_c = { "filename" },
				lualine_x = { "location" },
				lualine_y = {},
				lualine_z = {},
			},
		})
	end,
}
