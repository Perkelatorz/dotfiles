--- LSP progress in the corner (|j-hui/fidget.nvim|).

local M = {}

function M.setup()
	require("fidget").setup({
		progress = {
			display = {
				done_icon = "✓",
				progress_icon = { pattern = "dots", period = 1.5 },
			},
		},
		notification = {
			window = { winblend = 0, border = "rounded" },
		},
	})
end

return M
