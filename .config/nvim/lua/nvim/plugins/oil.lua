return {
	"stevearc/oil.nvim",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	config = function()
		local utils = require("nvim.core.utils")
		
		local oil, oil_ok = utils.safe_require("oil")
		if not oil_ok then
			return
		end

		oil.setup({
			-- Don't override the default file explorer so it won't conflict with nvim-tree
			default_file_explorer = false,
			columns = {
				"icon",
			},
			buf_options = {
				buflisted = false,
				bufhidden = "hide",
			},
			win_options = {
				wrap = false,
				signcolumn = "no",
				cursorcolumn = false,
				foldcolumn = "0",
				spell = false,
				list = false,
				conceallevel = 3,
				concealcursor = "nvic",
			},
			delete_to_trash = false,
			skip_confirm_for_simple_edits = false,
			prompt_save_on_select_new_entry = true,
			cleanup_delay_ms = 2000,
			lsp_file_methods = {
				enabled = true,
				timeout_ms = 1000,
				autosave_changes = false,
			},
			constrain_cursor = "editable",
			watch_for_changes = false,
			-- Use Oil's default keymaps (g? help, Space select, - parent, g. hidden, etc.)
			use_default_keymaps = true,
			view_options = {
				show_hidden = false,
				is_hidden_file = function(name, bufnr)
					local m = name:match("^%.")
					return m ~= nil
				end,
				is_always_hidden = function(name, bufnr)
					return false
				end,
				natural_order = "fast",
				case_insensitive = false,
				sort = {
					{ "type", "asc" },
					{ "name", "asc" },
				},
			},
			float = {
				padding = 2,
				max_width = 0,
				max_height = 0,
				border = "rounded",
			},
		})

		local keymap = vim.keymap

		-- Oil uses `-` by default to open parent directory
		-- Add floating window variant
		keymap.set("n", "<leader>-", "<cmd>Oil --float<CR>", { desc = "Oil (floating)" })
	end,
}
