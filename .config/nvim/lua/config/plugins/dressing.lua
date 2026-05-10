--- Nicer |vim.ui.input| / |vim.ui.select| (code actions, renames, some plugin prompts).

local M = {}

function M.setup()
	require("dressing").setup({
		input = {
			insert_only = false,
			win_options = { winblend = 0 },
		},
		select = {
			backend = { "telescope", "builtin", "nui" },
			builtin = { win_options = { winblend = 0 } },
		},
	})
end

return M
