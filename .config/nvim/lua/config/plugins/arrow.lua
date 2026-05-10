--- Per-project + per-buffer bookmarks. Defaults: |;| project menu, |m| buffer menu (see arrow.nvim README).

local M = {}

function M.setup()
	require("arrow").setup({
		show_icons = true,
		leader_key = ";",
		buffer_leader_key = "m",
	})
end

return M
