return {
	"brenoprata10/nvim-highlight-colors",
	event = { "BufReadPre", "BufNewFile" },
	config = function()
		local utils = require("nvim.core.utils")
		
		local highlight_colors, highlight_ok = utils.safe_require("nvim-highlight-colors")
		if not highlight_ok then
			return
		end

		highlight_colors.setup({
			-- Rendering mode
			-- 'background' - highlights the background of the color
			-- 'foreground' - highlights the foreground of the color  
			-- 'virtual' - adds a virtual text indicator
			render = "background",

			-- Enable virtual symbol (icon) next to color
			virtual_symbol = "■",

			-- Highlight named colors (e.g., 'red', 'blue')
			enable_named_colors = true,

			-- Enable Tailwind CSS colors
			enable_tailwind = true,

			-- Highlight color formats
			-- Supports: hex, rgb, hsl, named colors, Tailwind
			-- All are enabled by default
			
			-- Custom colors for specific filetypes
			-- Empty means all filetypes are supported
			exclude_filetypes = {},
			exclude_buftypes = {},
		})

		-- Keybindings
		local keymap = vim.keymap

		-- Toggle color highlighting
		keymap.set("n", "<leader>ch", "<cmd>HighlightColors Toggle<cr>", { desc = "Toggle color highlighter" })
	end,
}
