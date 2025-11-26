return {
	"nvim-telescope/telescope.nvim",
	branch = "0.1.x",
	cmd = "Telescope",
	dependencies = {
		"nvim-lua/plenary.nvim",
		{
			"nvim-telescope/telescope-fzf-native.nvim",
			build = "make",
		},
		"nvim-tree/nvim-web-devicons",
		"folke/todo-comments.nvim",
	},
	config = function()
		local utils = require("nvim.core.utils")
		
		local telescope, telescope_ok = utils.safe_require("telescope")
		if not telescope_ok then
			return
		end
		
		local actions, actions_ok = utils.safe_require("telescope.actions")
		if not actions_ok then
			return
		end

		telescope.setup({
			defaults = {
				path_display = { "smart" },
				prompt_prefix = "  ",
				selection_caret = "  ",
				entry_prefix = "  ",
				initial_mode = "insert",
				selection_strategy = "reset",
				sorting_strategy = "ascending",
				layout_strategy = "horizontal",
				layout_config = {
					horizontal = {
						prompt_position = "top",
						preview_width = 0.55,
						results_width = 0.8,
					},
					vertical = {
						mirror = false,
					},
					width = 0.87,
					height = 0.80,
					preview_cutoff = 120,
				},
				file_ignore_patterns = { "%.git", "node_modules" },
				mappings = {
					i = {
						["<C-k>"] = actions.move_selection_previous, -- move to prev result
						["<C-j>"] = actions.move_selection_next, -- move to next result
						["<C-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
					},
				},
			},
			pickers = {
				find_files = {
					theme = "dropdown",
					previewer = true,
					hidden = false,
				},
				live_grep = {
					theme = "dropdown",
					previewer = true,
				},
				buffers = {
					theme = "dropdown",
					previewer = false,
					initial_mode = "normal",
				},
				oldfiles = {
					theme = "dropdown",
					previewer = true,
				},
			},
		})

		telescope.load_extension("fzf")

		-- set keymaps
		local keymap = vim.keymap -- for conciseness

		keymap.set("n", "<leader>ff", "<cmd>Telescope find_files<cr>", { desc = "Fuzzy find files in cwd" })
		keymap.set("n", "<leader>fr", "<cmd>Telescope oldfiles<cr>", { desc = "Fuzzy find recent files" })
		keymap.set("n", "<leader>fs", "<cmd>Telescope live_grep<cr>", { desc = "Find string in cwd" })
		keymap.set("n", "<leader>fc", "<cmd>Telescope grep_string<cr>", { desc = "Find string under cursor in cwd" })
		keymap.set("n", "<leader>ft", "<cmd>TodoTelescope<cr>", { desc = "Find todos" })
		keymap.set("n", "<leader>fb", function()
			local builtin, builtin_ok = utils.safe_require("telescope.builtin")
			local themes, themes_ok = utils.safe_require("telescope.themes")
			if not builtin_ok or not themes_ok then
				return
			end
			builtin.buffers(themes.get_ivy({
				sort_mru = true,
				sort_lastused = true,
				initial_mode = "normal",
				-- Pre-select the current buffer
				-- that's basically the main benefit lamw25wmal
				-- ignore_current_buffer = false,
				-- select_current = true,
				layout_config = {
					-- Set preview width, 0.7 sets it to 70% of the window width
					preview_width = 0.7,
				},
			}))
		end, { desc = "[P]Open telescope buffers" })
	end,
}
