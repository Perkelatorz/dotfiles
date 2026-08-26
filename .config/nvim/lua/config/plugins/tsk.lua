--- tsk.nvim: kanban boards backed by plain markdown, Obsidian-Kanban compatible.
--- Boards live in the notes vault at ~/notes/todo; both dialects are read, and
--- the default writer matches Obsidian Kanban so the same file opens as a
--- board in the Obsidian app.
---
--- Installed from git like any other plugin; see |config.pack|.

local M = {}

function M.setup()
	require("tsk").setup({
		boards = {
			work = vim.fn.expand("~/notes/todo/work.md"),
			home = vim.fn.expand("~/notes/todo/home.md"),
		},
		board = {
			-- Column tints, keyed by column title.
			column_colors = {
				Backlog = "#3b82f6",
				["This Week"] = "#10b981",
				["In Progress"] = "#f59e0b",
				Done = "#475569",
			},
			-- Card colors, keyed by the card's `[color:: key]` field. Set a
			-- card's color with `C` on it, or type `[color:: urgent]` inline.
			card_colors = {
				urgent = "#ef4444",
				waiting = "#f59e0b",
				study = "#3b82f6",
				homelab = "#10b981",
				yard = "#22c55e",
			},
		},
	})

	local map = function(lhs, rhs, desc)
		vim.keymap.set("n", lhs, rhs, { desc = desc })
	end

	map("<leader>bb", "<cmd>Tsk work<cr>", "Board: work board")
	map("<leader>bh", "<cmd>Tsk home<cr>", "Board: home board")
	map("<leader>ba", "<cmd>TskAgenda<cr>", "Board: agenda (all boards)")
	map("<leader>bf", "<cmd>TskFind<cr>", "Board: find card")
end

return M
