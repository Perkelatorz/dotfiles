return {
	"lukas-reineke/indent-blankline.nvim",
	event = { "BufReadPre", "BufNewFile" },
	main = "ibl",
	config = function()
		-- Define highlight groups before setup
		local hooks = require("ibl.hooks")

		-- Use global colors if available, otherwise fallback
		local colors = _G.alabaster_colors or {
			bg2 = "#302a40",
			bg3 = "#3a3550",
		}

		-- Create the highlight groups
		hooks.register(hooks.type.HIGHLIGHT_SETUP, function()
			vim.api.nvim_set_hl(0, "IblIndent", { fg = colors.bg2, nocombine = true })
			vim.api.nvim_set_hl(0, "IblScope", { fg = colors.bg3, nocombine = true })
		end)

		require("ibl").setup({
			indent = {
				char = "│",
				tab_char = "│",
				highlight = "IblIndent",
			},
			scope = {
				enabled = true,
				char = "│",
				show_start = true,
				show_end = true,
				highlight = "IblScope",
			},
			exclude = {
				filetypes = {
					"alpha",
					"dashboard",
					"lazy",
					"mason",
					"notify",
					"Trouble",
					"trouble",
				},
			},
		})
	end,
}
