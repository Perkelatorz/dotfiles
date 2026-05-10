--- Fuzzy find files, buffers, text.

local M = {}

function M.setup()
	local builtin = require("telescope.builtin")
	local telescope = require("telescope")

	telescope.setup({
		defaults = {
			path_display = { "truncate" },
			dynamic_preview_title = true,
			layout_strategy = "flex",
			layout_config = {
				horizontal = { preview_width = 0.55 },
			},
			borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
			selection_caret = " › ",
			prompt_prefix = "  ",
		},
	})

	pcall(function()
		telescope.load_extension("fzf")
	end)

	vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Telescope find files" })
	vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Telescope live grep" })
	vim.keymap.set("n", "<leader>fs", builtin.grep_string, { desc = "Telescope grep word under cursor" })
	vim.keymap.set("v", "<leader>fs", builtin.grep_string, { desc = "Telescope grep selection" })
	vim.keymap.set("n", "<leader>fG", builtin.git_status, { desc = "Telescope git status (changed files)" })
	vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Telescope buffers" })
	vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "Telescope help tags" })
	vim.keymap.set("n", "<leader>fr", builtin.oldfiles, { desc = "Telescope recent files" })
	vim.keymap.set("n", "<leader>f/", builtin.current_buffer_fuzzy_find, { desc = "Telescope fuzzy in buffer" })
end

return M
