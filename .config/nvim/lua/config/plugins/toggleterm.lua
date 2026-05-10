--- Floating/split terminals via |toggleterm.nvim|. |<Leader>cc| = Claude Code in a **vertical** split (right with |splitright|).
--- Vertical splits: |winfixwidth| is cleared on open. In **terminal mode**, |<C-w>| is sent to the shell by default, so we map |<C-w><| / |<C-w>>| / |<C-w>=| (and +/− for height) to leave terminal mode, resize, then |:startinsert|.

local M = {}

local Terminal = require("toggleterm.terminal").Terminal

--- Allow split terminals to share space like a normal |:vsplit| (toggleterm sets winfix* otherwise).
local function unfix_split_win(term)
	if not term.window or not vim.api.nvim_win_is_valid(term.window) then
		return
	end
	vim.wo[term.window].winfixwidth = false
	vim.wo[term.window].winfixheight = false
end

local claude_term = Terminal:new({
	cmd = "claude",
	count = 97,
	hidden = true,
	direction = "vertical",
	display_name = "Claude",
	size = function()
		return math.floor(vim.o.columns * 0.42)
	end,
	on_open = unfix_split_win,
})

local shell_term = Terminal:new({
	count = 96,
	hidden = true,
	direction = "float",
	display_name = "Terminal",
	float_opts = {
		border = "rounded",
		width = function()
			return math.floor(vim.o.columns * 0.88)
		end,
		height = function()
			return math.floor(vim.o.lines * 0.82)
		end,
	},
})

local horiz_term = Terminal:new({
	count = 95,
	hidden = true,
	direction = "horizontal",
	display_name = "Shell",
	size = 15,
	on_open = unfix_split_win,
})

function M.setup()
	require("toggleterm").setup({
		start_in_insert = true,
		persist_mode = true,
		persist_size = true,
		shade_terminals = true,
		direction = "float",
		float_opts = {
			border = "rounded",
		},
	})

	-- Terminal mode eats |<C-w>| before Neovim sees window commands; prefix with |<C-\><C-n>| then return to insert.
	local resize_end = [[:startinsert<CR>]]
	local function tmap(bufnr, lhs, rhs, desc)
		vim.keymap.set("t", lhs, rhs, { buffer = bufnr, silent = true, desc = desc })
	end
	local aug = vim.api.nvim_create_augroup("config.toggleterm_resize", { clear = true })
	vim.api.nvim_create_autocmd("FileType", {
		group = aug,
		pattern = "toggleterm",
		callback = function(args)
			local b = args.buf
			tmap(b, "<C-w><lt>", "<C-\\><C-n><C-w><lt>" .. resize_end, "Terminal: narrower window")
			tmap(b, "<C-w><gt>", "<C-\\><C-n><C-w><gt>" .. resize_end, "Terminal: wider window")
			tmap(b, "<C-w>=", "<C-\\><C-n><C-w>=" .. resize_end, "Terminal: equalize splits")
			tmap(b, "<C-w>+", "<C-\\><C-n><C-w>+" .. resize_end, "Terminal: taller window")
			tmap(b, "<C-w>-", "<C-\\><C-n><C-w>-" .. resize_end, "Terminal: shorter window")
		end,
	})

	vim.keymap.set("n", "<leader>cc", function()
		claude_term:toggle()
	end, { desc = "Claude Code (vertical, right)" })

	vim.keymap.set("n", "<leader>tt", function()
		shell_term:toggle()
	end, { desc = "Toggle shell terminal (float)" })

	vim.keymap.set("n", "<leader>th", function()
		horiz_term:toggle()
	end, { desc = "Toggle terminal (horizontal split)" })

	-- Glow (Mason `glow`): pager preview for saved Markdown files.
	vim.keymap.set("n", "<leader>mp", function()
		local path = vim.api.nvim_buf_get_name(0)
		if path == "" then
			vim.notify("Save the buffer first — Glow needs a file path.", vim.log.levels.WARN)
			return
		end
		if vim.bo.filetype ~= "markdown" and not path:lower():match("%.md$") and not path:lower():match("%.markdown$") then
			vim.notify("Glow preview is meant for Markdown buffers.", vim.log.levels.WARN)
			return
		end
		vim.cmd("belowright 18split | terminal glow " .. vim.fn.shellescape(path))
	end, { desc = "Glow markdown preview (split terminal)" })

	-- yadm diff in a floating terminal (Diffview/gitsigns can't see the yadm git dir cleanly).
	if vim.fn.executable("yadm") == 1 then
		local yadm_diff = Terminal:new({
			cmd = "yadm diff --color=always | less -R",
			count = 94,
			hidden = true,
			direction = "float",
			display_name = "yadm diff",
			close_on_exit = false,
			float_opts = {
				border = "rounded",
				width = function()
					return math.floor(vim.o.columns * 0.9)
				end,
				height = function()
					return math.floor(vim.o.lines * 0.85)
				end,
			},
		})
		vim.keymap.set("n", "<leader>gy", function()
			yadm_diff:toggle()
		end, { desc = "yadm diff (floating terminal)" })
	end
end

return M
