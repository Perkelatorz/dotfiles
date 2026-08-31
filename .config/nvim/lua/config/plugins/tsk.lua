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

	-- Track the remote rather than sitting at whatever revision the lockfile
	-- last pinned. This one is mine and changes often, so a pinned copy means
	-- editing the plugin, pushing, and then remembering to run vim.pack.update
	-- before the fix is actually in the editor -- which is how a month-boundary
	-- bug in the date picker stayed live locally after it was already fixed.
	--
	-- Deferred off the startup path because vim.pack.update reaches the network,
	-- and that must never sit between :e and the first keystroke. `force` skips
	-- the confirmation buffer; reviewing a diff of my own commits is theatre.
	--
	-- Skipped without a UI: headless runs are scripts and tests, and they should
	-- neither reach the network nor rewrite the lockfile under a test. The check
	-- has to happen in the timer rather than out here -- the TUI has not attached
	-- while init.lua is still being sourced, so nvim_list_uis() is empty at this
	-- point even for an ordinary interactive session.
	--
	-- The lockfile only changes when the remote actually moved, so this does not
	-- leave yadm permanently dirty -- it bumps on exactly the starts where a new
	-- commit landed.
	vim.api.nvim_create_autocmd("VimEnter", {
		once = true,
		group = vim.api.nvim_create_augroup("config.tsk_autoupdate", { clear = true }),
		callback = function()
			vim.defer_fn(function()
				if #vim.api.nvim_list_uis() == 0 then
					return
				end
				pcall(vim.pack.update, { "tsk.nvim" }, { force = true })
			end, 2000)
		end,
	})
end

return M
