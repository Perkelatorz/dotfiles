--- Auto-close + rename paired tags in HTML/JSX/TSX/Svelte/Vue.

local M = {}

function M.setup()
	require("nvim-ts-autotag").setup({
		opts = {
			enable_close = true,
			enable_rename = true,
			enable_close_on_slash = false,
		},
	})
end

return M
