--- In-buffer Markdown rendering (headings, tables, code blocks). Uses Tree-sitter + devicons.

local M = {}

function M.setup()
	require("render-markdown").setup({})
	vim.keymap.set("n", "<leader>mt", "<cmd>RenderMarkdown toggle<cr>", { desc = "Toggle render-markdown" })
	vim.keymap.set("n", "<leader>mv", "<cmd>RenderMarkdown preview<cr>", { desc = "Render-markdown preview window" })
end

return M
