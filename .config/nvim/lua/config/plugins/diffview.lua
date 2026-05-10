--- Full-repo / file-history diffs (|sindrets/diffview.nvim|). Needs plenary + git.

local M = {}

function M.setup()
	require("diffview").setup({
		view = { merge_tool = { layout = "diff3_mixed" } },
	})

	vim.keymap.set("n", "<leader>go", "<cmd>DiffviewOpen<cr>", { desc = "Diffview: open (repo)" })
	vim.keymap.set("n", "<leader>gO", "<cmd>DiffviewClose<cr>", { desc = "Diffview: close" })
	vim.keymap.set("n", "<leader>gh", "<cmd>DiffviewFileHistory %<cr>", { desc = "Diffview: file history" })
	vim.keymap.set("n", "<leader>gH", "<cmd>DiffviewFileHistory<cr>", { desc = "Diffview: repo file history" })
end

return M
