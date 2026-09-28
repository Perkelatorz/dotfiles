--- In-buffer Markdown rendering (headings, tables, code blocks). Uses Tree-sitter + devicons.

local M = {}

function M.setup()
	require("render-markdown").setup({})
	vim.keymap.set("n", "<leader>mt", "<cmd>RenderMarkdown toggle<cr>", { desc = "Toggle render-markdown" })
	vim.keymap.set("n", "<leader>mv", "<cmd>RenderMarkdown preview<cr>", { desc = "Render-markdown preview window" })

	-- live-preview.nvim: browser preview with mermaid rendering. Toggles start/close.
	local live_preview_running = false
	vim.keymap.set("n", "<leader>ml", function()
		if live_preview_running then
			vim.cmd("LivePreview close")
			live_preview_running = false
		else
			vim.cmd("LivePreview start")
			live_preview_running = true
		end
	end, { desc = "Toggle live browser preview (mermaid)" })
end

return M
