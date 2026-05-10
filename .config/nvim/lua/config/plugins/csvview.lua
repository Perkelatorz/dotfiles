--- Tabular CSV/TSV view (virtual text, sticky header). |:CsvViewToggle| when disabled.

local M = {}

local max_lines_auto = 12000

function M.setup()
	require("csvview").setup({
		parser = {
			comments = { "#", "//" },
		},
		view = {
			display_mode = "highlight",
			sticky_header = { enabled = true },
		},
	})

	vim.api.nvim_create_autocmd("FileType", {
		group = vim.api.nvim_create_augroup("config.csvview", { clear = true }),
		pattern = { "csv", "tsv" },
		callback = function()
			if vim.api.nvim_buf_line_count(0) > max_lines_auto then
				return
			end
			local ok, err = pcall(require("csvview").enable)
			if not ok then
				vim.notify("csvview: " .. tostring(err), vim.log.levels.WARN)
			end
		end,
	})

	vim.keymap.set("n", "<leader>cv", "<cmd>CsvViewToggle<cr>", { desc = "Toggle CSV/TSV table view" })
	vim.keymap.set("n", "<leader>cI", "<cmd>CsvViewInfo<cr>", { desc = "CSV view info (delimiter, size)" })
end

return M
