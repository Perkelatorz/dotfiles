--- Pretty lists: diagnostics, symbols, LSP refs/defs, quickfix, location list.

local M = {}

function M.setup()
	require("trouble").setup({
		auto_close = false,
		auto_preview = true,
		auto_refresh = true,
		focus = false,
		follow = true,
		indent_guides = true,
		multiline = true,
		win = {
			position = "bottom",
			size = { height = 0.28 },
		},
		preview = {
			type = "main",
			scratch = true,
		},
	})

	local map = vim.keymap.set
	local d = { silent = true }
	map("n", "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", vim.tbl_extend("force", d, { desc = "Trouble: diagnostics (workspace)" }))
	map("n", "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", vim.tbl_extend("force", d, { desc = "Trouble: diagnostics (this buffer)" }))
	map("n", "<leader>xs", "<cmd>Trouble symbols toggle focus=false<cr>", vim.tbl_extend("force", d, { desc = "Trouble: document symbols" }))
	map(
		"n",
		"<leader>xl",
		"<cmd>Trouble lsp toggle focus=false win.position=right<cr>",
		vim.tbl_extend("force", d, { desc = "Trouble: LSP defs / refs / …" })
	)
	map("n", "<leader>xq", "<cmd>Trouble qflist toggle<cr>", vim.tbl_extend("force", d, { desc = "Trouble: quickfix list" }))
	map("n", "<leader>xL", "<cmd>Trouble loclist toggle<cr>", vim.tbl_extend("force", d, { desc = "Trouble: location list" }))
end

return M
