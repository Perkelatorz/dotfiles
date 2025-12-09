return {
	"hat0uma/prelive.nvim",
	cmd = { "PreLiveGo", "PreLiveStatus", "PreLiveClose", "PreLiveCloseAll", "PreLiveLog" },
	keys = {
		{ "<leader>ls", "<cmd>PreLiveGo<cr>", desc = "Start live server and open current file" },
		{ "<leader>lS", "<cmd>PreLiveStatus<cr>", desc = "Show live server status" },
		{ "<leader>lc", "<cmd>PreLiveClose<cr>", desc = "Stop serving a directory" },
		{ "<leader>lC", "<cmd>PreLiveCloseAll<cr>", desc = "Stop all live servers" },
		{ "<leader>ll", "<cmd>PreLiveLog<cr>", desc = "Open live server log" },
	},
	config = function()
		local prelive = require("prelive")
		
		prelive.setup({
			port = 8080, -- Default port
			open_browser = true, -- Auto-open browser
			browser = "firefox", -- Change to "chrome", "chromium", etc.
			quiet = false, -- Show logs
		})
	end,
}

