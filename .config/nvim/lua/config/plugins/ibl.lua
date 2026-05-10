--- Subtle indent guides + scope (treesitter-aware).

local M = {}

function M.setup()
	require("ibl").setup({
		indent = {
			char = "│",
			tab_char = "│",
			highlight = "IblIndent",
		},
		whitespace = {
			highlight = "IblWhitespace",
		},
		scope = {
			enabled = true,
			show_start = true,
			show_end = false,
			highlight = "IblScope",
		},
		exclude = {
			filetypes = {
				"help",
				"lazy",
				"neo-tree",
				"neo-tree-popup",
				"TelescopePrompt",
				"TelescopeResults",
				"notify",
				"qf",
				"checkhealth",
				"noice",
			},
		},
	})
end

return M
