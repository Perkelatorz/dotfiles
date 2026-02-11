-- Cursor CLI integration: use Cursor Agent from Neovim instead of Cursor IDE.
-- Requires: Cursor CLI installed (curl https://cursor.com/install -fsSL | bash)
-- Binary: `agent` in PATH
return {
	"Sarctiann/cursor-agent.nvim",
	cmd = { "CursorAgent" },
	keys = {
		{ "<leader>al", "<cmd>CursorAgent open_cwd<cr>", desc = "Cursor Agent (cwd)" },
		{ "<leader>aj", "<cmd>CursorAgent open_root<cr>", desc = "Cursor Agent (root)" },
		{ "<leader>at", "<cmd>CursorAgent session_list<cr>", desc = "Cursor Agent sessions" },
	},
	dependencies = {
		"folke/snacks.nvim",
	},
	opts = {
		use_default_mappings = false,
		show_help_on_open = true,
		window_width = 0.6,
		open_mode = "normal",
	},
}
