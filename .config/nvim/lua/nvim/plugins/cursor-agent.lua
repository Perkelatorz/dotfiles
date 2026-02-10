-- Cursor CLI integration: use Cursor Agent from Neovim instead of Cursor IDE.
-- Requires: Cursor CLI installed (curl https://cursor.com/install -fsSL | bash)
-- Binary: `agent` in PATH
return {
	"Sarctiann/cursor-agent.nvim",
	cmd = { "CursorAgent" },
	keys = {
		{ "<leader>aJ", "<cmd>CursorAgent open_cwd<cr>", desc = "Cursor Agent (cwd)" },
		{ "<leader>aj", "<cmd>CursorAgent open_root<cr>", desc = "Cursor Agent (project root)" },
		{ "<leader>aT", "<cmd>CursorAgent session_list<cr>", desc = "Cursor Agent sessions" },
	},
	dependencies = {
		"folke/snacks.nvim",
	},
	opts = {
		use_default_mappings = false, -- we use our own to avoid <leader>al conflict with OpenCode
		show_help_on_open = true,
		window_width = 0.6,
		open_mode = "normal",
	},
}
