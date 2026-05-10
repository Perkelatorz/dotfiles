--- Nerd Font file-type icons; used by Mason, which-key, cmp (indirect), and other UIs.

local M = {}

function M.setup()
	require("nvim-web-devicons").setup({
		default = true,
		color_icons = true,
	})
end

return M
