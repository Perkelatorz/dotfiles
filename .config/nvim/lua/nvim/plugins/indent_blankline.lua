return {
	"lukas-reineke/indent-blankline.nvim",
	event = { "BufReadPre", "BufNewFile" },
	main = "ibl",
	opts = {
		indent = {
			char = "│", -- Cleaner vertical line
			tab_char = "│",
		},
		scope = {
			enabled = true, -- Show scope highlighting
			char = "│",
			show_start = true,
			show_end = true,
			highlight = { "IndentBlanklineIndent1", "IndentBlanklineIndent2" },
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
	},
}
