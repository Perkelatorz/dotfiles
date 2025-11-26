return {
	"rcarriga/nvim-notify",
	event = "VeryLazy",
	config = function()
		local utils = require("nvim.core.utils")
		
		local notify, notify_ok = utils.safe_require("notify")
		if not notify_ok then
			return
		end

		notify.setup({
			timeout = 3000,
			max_height = function()
				return math.floor(vim.o.lines * 0.75)
			end,
			max_width = function()
				return math.floor(vim.o.columns * 0.75)
			end,
		})

		-- Use notify as the default notification handler
		vim.notify = notify
	end,
}

