--- Per-project + per-buffer bookmarks (arrow.nvim).
---
--- Upstream defaults are |;| (project menu) and |m| (buffer menu). Both are rebound here
--- because they shadow built-ins that matter:
---   |;| repeats the last |f|/|t| motion — losing it guts the f/t motions, including the
---       labelled versions flash.nvim provides (see |config.plugins.flash|).
---   |m| sets a mark (|ma|, then |`a| / |'a| to jump back) — one of Vim's core features.
--- Moved to <leader>; and <leader>' , which keep the old muscle memory one key away and
--- mirror Vim's own |'| mark-jump for the per-buffer list.

local M = {}

function M.setup()
	require("arrow").setup({
		show_icons = true,
		leader_key = "<leader>;",
		buffer_leader_key = "<leader>'",
	})
end

return M
