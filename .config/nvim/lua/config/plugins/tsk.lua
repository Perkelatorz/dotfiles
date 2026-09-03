--- tsk.nvim: kanban boards backed by plain markdown, Obsidian-Kanban compatible.
--- Boards live in the notes vault at ~/notes/todo; both dialects are read, and
--- the default writer matches Obsidian Kanban so the same file opens as a
--- board in the Obsidian app.
---
--- Installed from git like any other plugin; see |config.pack|.

local M = {}

local TODO_DIR = vim.fn.expand("~/notes/todo")

--- Every .md under the todo directory is a board.
---
--- Listing them by hand meant this file had to be edited to add one, and the
--- agenda silently skipped any board that had not been. Discovering them means
--- creating the file is enough -- and `:Todo <name>` below creates the file --
--- so a new board never involves touching config.
local function discover_boards()
	local boards = {}
	if vim.fn.isdirectory(TODO_DIR) == 0 then
		return boards
	end
	for name, kind in vim.fs.dir(TODO_DIR) do
		if kind == "file" and name:sub(-3) == ".md" then
			boards[name:sub(1, -4)] = TODO_DIR .. "/" .. name
		end
	end
	return boards
end

function M.setup()
	require("tsk").setup({
		boards = discover_boards(),
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

	--- `:Todo [name]` -- what the `todo` shell function calls.
	---
	--- Unlike `:Tsk`, an unknown name is not an error: it is registered against
	--- <todo dir>/<name>.md and opened, and tsk writes the file from its
	--- template on first open. So `:Todo garden` is how a board gets created,
	--- and there is no separate "add a board" step.
	---
	--- nargs is "*" rather than "?" so a name containing a space survives; the
	--- args are rejoined below.
	vim.api.nvim_create_user_command("Todo", function(cmd)
		local name = #cmd.fargs > 0 and table.concat(cmd.fargs, " ") or "work"
		local cfg = require("tsk.config")
		if not cfg.options.boards[name] then
			-- Nothing in tsk creates intermediate directories, so a first board
			-- on a fresh machine needs the folder to exist before the template
			-- can be written.
			vim.fn.mkdir(TODO_DIR, "p")
			cfg.options.boards[name] = TODO_DIR .. "/" .. name .. ".md"
		end
		require("tsk").board(name)
	end, {
		nargs = "*",
		desc = "Open a todo board, creating it if it does not exist",
		complete = function()
			return require("tsk.config").board_names()
		end,
	})

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
