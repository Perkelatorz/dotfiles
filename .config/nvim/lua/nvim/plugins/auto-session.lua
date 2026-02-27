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
	end,
}
