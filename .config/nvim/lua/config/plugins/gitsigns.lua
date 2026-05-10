--- Inline hunks, blame, stage/reset from the buffer (|lewis6991/gitsigns.nvim|).
---
local M = {}

function M.setup()
	require("gitsigns").setup({
		signs = {
			add = { text = "│" },
			change = { text = "│" },
			delete = { text = "󰍵" },
			topdelete = { text = "‾" },
			changedelete = { text = "~" },
			untracked = { text = "┆" },
		},
		signcolumn = true,
		watch_gitdir = { follow_files = true },
		current_line_blame = true,
		current_line_blame_opts = { virt_text_pos = "eol", delay = 200 },
		preview_config = { border = "rounded", style = "minimal" },
	})

	-- Global gitsigns keymaps: claim leader-g binds so we never fall back to stock `gp` (paste).
	-- gs.* functions no-op gracefully when gitsigns is not attached to the current buffer.
	local function gs()
		return require("gitsigns")
	end

	local function nav(dir)
		return function()
			if vim.wo.diff then
				vim.cmd("normal! " .. (dir == "next" and "]c" or "[c"))
			else
				gs().nav_hunk(dir)
			end
		end
	end

	local function range_op(op)
		return function()
			local f = math.min(vim.fn.line("."), vim.fn.line("v"))
			local l = math.max(vim.fn.line("."), vim.fn.line("v"))
			gs()[op]({ f, l })
		end
	end

	vim.keymap.set("n", "]c", nav("next"), { desc = "Git next hunk" })
	vim.keymap.set("n", "[c", nav("prev"), { desc = "Git prev hunk" })

	vim.keymap.set("n", "<leader>gs", function()
		gs().stage_hunk()
	end, { desc = "Git stage hunk" })
	vim.keymap.set("n", "<leader>gr", function()
		gs().reset_hunk()
	end, { desc = "Git reset hunk" })
	vim.keymap.set("n", "<leader>gp", function()
		gs().preview_hunk()
	end, { desc = "Git preview hunk" })
	vim.keymap.set("n", "<leader>gB", function()
		gs().toggle_current_line_blame()
	end, { desc = "Git toggle line blame" })
	vim.keymap.set("v", "<leader>gs", range_op("stage_hunk"), { desc = "Git stage hunk (visual)" })
	vim.keymap.set("v", "<leader>gr", range_op("reset_hunk"), { desc = "Git reset hunk (visual)" })

	-- Repo-wide hunk surface: dump every hunk in every changed file to the quickfix list,
	-- then walk them with ]q / [q. Survives buffers being closed.
	vim.keymap.set("n", "<leader>gQ", function()
		gs().setqflist("all", { open = true })
	end, { desc = "Git: all hunks in repo → quickfix" })
end

return M
