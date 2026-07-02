--- File tree when you want hierarchy; |w| in tree picks target window (needs nvim-window-picker).

local M = {}

function M.setup()
	require("window-picker").setup({
		hint = "floating-big-letter",
		filter_rules = {
			bo = {
				filetype = {
					"neo-tree",
					"neo-tree-popup",
					"neo-tree-preview",
					"notify",
					"qf",
				},
				buftype = { "terminal", "quickfix", "nofile" },
			},
		},
	})

	vim.keymap.set("n", "<leader>nt", "<cmd>Neotree toggle position=left<cr>", { desc = "Neo-tree toggle" })
	vim.keymap.set("n", "<leader>nf", "<cmd>Neotree filesystem reveal left<cr>", { desc = "Neo-tree reveal file" })

	require("neo-tree").setup({
		close_if_last_window = true,
		popup_border_style = "rounded",
		filesystem = {
			hijack_netrw_behavior = "open_default",
			follow_current_file = {
				enabled = true,
			},
			use_libuv_file_watcher = true,
			filtered_items = {
				visible = true,
				hide_dotfiles = false,
				hide_gitignored = false,
			},
		},
		window = {
			width = 32,
		},
	})
end

return M
