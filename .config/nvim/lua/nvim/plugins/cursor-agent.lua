-- Cursor CLI integration: use Cursor Agent from Neovim instead of Cursor IDE.
-- Requires: Cursor CLI installed (curl https://cursor.com/install -fsSL | bash)
-- Binary: `agent` in PATH
local function ensure_cwd()
	local terminal = require("cursor-agent.terminal")
	if not terminal.working_dir or terminal.working_dir == "" then
		terminal.working_dir = vim.fn.getcwd()
	end
	if vim.fn.isdirectory(terminal.working_dir) == 0 then
		terminal.working_dir = vim.fn.getcwd()
	end
end

return {
	"Sarctiann/cursor-agent.nvim",
	cmd = { "CursorAgent" },
	keys = {
		{ "<leader>al", "<cmd>CursorAgent open_cwd<cr>", desc = "Cursor Agent (cwd)" },
		{ "<leader>aj", "<cmd>CursorAgent open_root<cr>", desc = "Cursor Agent (root)" },
		{
			"<leader>at",
			function()
				local terminal = require("cursor-agent.terminal")
				local commands = require("cursor-agent.commands")
				ensure_cwd()
				commands.show_sessions()
			end,
			desc = "Cursor Agent sessions",
		},
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
