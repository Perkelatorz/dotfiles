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

		-- Get theme colors
		local colors = _G.alabaster_colors or {}
		
		-- Clean, minimal statusline with subtle flair
		lualine.setup({
			options = {
				theme = "auto",
				component_separators = { left = "", right = "" }, -- No separators for cleaner look
				section_separators = { left = "", right = "" },
				disabled_filetypes = {
					statusline = { "alpha", "dashboard" },
				},
				globalstatus = true, -- Single statusline for all windows
			},
			sections = {
				lualine_a = {
					{
						"mode",
						icons_enabled = true,
						icon = nil,
						fmt = function(str)
							local mode_icons = {
								n = "󰈔",
								i = "󰌌",
								v = "󰆍",
								V = "󰆍",
								["\22"] = "󰆍",
								c = "󰘳",
								s = "󰆐",
								S = "󰆐",
								["\19"] = "󰆐",
								R = "󰒞",
								r = "󰒞",
								["!"] = "󰆍",
								t = "󰆍",
							}
							return (mode_icons[str] or "󰈔") .. " " .. str:sub(1, 1)
						end,
						separator = { left = "", right = "│" },
						color = { fg = colors.fg0 or "#f0f0f0", bg = colors.bg1 or "#252030" },
					},
				},
				lualine_b = {
					{
						"branch",
						icon = "󰘬",
						separator = { left = "", right = "│" },
						color = { fg = colors.green or "#5BF65B", gui = "bold" },
					},
					{
						"diff",
						symbols = { added = "󰐖 ", modified = "󰏬 ", removed = "󰍴 " },
						separator = { left = "", right = "│" },
						diff_color = {
							added = { fg = colors.green or "#5BF65B" },
							modified = { fg = colors.orange or "#f56600" },
							removed = { fg = colors.red or "#d87070" },
						},
					},
					{
						"diagnostics",
						symbols = { error = "󰅚 ", warn = "󰀪 ", info = "󰋽 ", hint = "󰌶 " },
						separator = { left = "", right = "│" },
						diagnostics_color = {
							error = { fg = colors.red or "#d87070" },
							warn = { fg = colors.orange or "#f56600" },
							info = { fg = colors.cyan or "#8ab5b5" },
							hint = { fg = colors.green or "#5BF65B" },
						},
					},
				},
				lualine_c = {
					{
						"filename",
						path = 1, -- Show full path
						symbols = {
							modified = " 󰏬",
							readonly = " 󰌾",
							unnamed = " 󰈔",
							newfile = " 󰎔",
						},
						color = { fg = colors.fg0 or "#f0f0f0" },
					},
				},
				lualine_x = {
					{
						"filetype",
						icon_only = false,
						icon = { align = "right" },
						separator = { left = "│", right = "" },
						color = { fg = colors.purple or "#9d8bc8" },
					},
					{
						lazy_status.updates,
						cond = lazy_status.has_updates,
						color = { fg = colors.orange or "#f56600", gui = "bold" },
						icon = "󰑓",
						separator = { left = "│", right = "" },
					},
					{
						"encoding",
						icon = "󰨞",
						separator = { left = "│", right = "" },
						color = { fg = colors.cyan or "#8ab5b5" },
					},
					{
						"fileformat",
						symbols = {
							unix = "󰘧",
							dos = "󰘧",
							mac = "󰘧",
						},
						separator = { left = "│", right = "" },
						color = { fg = colors.orange or "#f56600" },
					},
					{
						"location",
						icon = "󰦨",
						separator = { left = "│", right = "" },
						color = { fg = colors.cyan or "#8ab5b5" },
					},
					{
						"progress",
						icon = "󰦞",
						separator = { left = "│", right = "" },
						color = { fg = colors.green or "#5BF65B" },
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
