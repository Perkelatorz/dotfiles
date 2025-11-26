return {
	"rmagatti/auto-session",
	lazy = false,

	config = function()
		local auto_session = require("auto-session")

		-- Portable session configuration
		local home = os.getenv("HOME") or vim.fn.expand("~")
		local suppressed_dirs = {
			home .. "/",
			home .. "/Downloads",
			home .. "/Documents",
			home .. "/Desktop",
		}
		
		-- Add custom dev directory if set
		local dev_dir = os.getenv("DEV_DIR") or home .. "/Dev"
		if dev_dir then
			table.insert(suppressed_dirs, dev_dir)
		end

		auto_session.setup({
			auto_restore = false,
			suppressed_dirs = suppressed_dirs,
		})

		local keymap = vim.keymap

		keymap.set("n", "<leader>wr", "<cmd>SessionRestore<CR>", { desc = "Restore session for cwd" }) -- restore last workspace session for current directory
		keymap.set("n", "<leader>ws", "<cmd>SessionSave<CR>", { desc = "Save session for auto session root dir" }) -- save workspace session for current working directory
	end,
}
