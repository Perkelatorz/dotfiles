--- |nvim-lint|: standalone linters → |vim.diagnostic| (complements LSP). Binaries from |:Mason|.

local M = {}

function M.setup()
	local lint = require("lint")

	lint.linters_by_ft = {
		yaml = { "yamllint" },
		["yaml.docker-compose"] = { "yamllint" },
		["yaml.ansible"] = { "ansible_lint" },
		dockerfile = { "hadolint" },
	}

	vim.api.nvim_create_autocmd({ "BufWritePost" }, {
		group = vim.api.nvim_create_augroup("config.lint", { clear = true }),
		callback = function(args)
			if vim.bo[args.buf].buftype ~= "" then
				return
			end
			vim.api.nvim_buf_call(args.buf, function()
				lint.try_lint()
			end)
		end,
	})

	vim.keymap.set("n", "<leader>cl", function()
		lint.try_lint()
	end, { desc = "Run linters (nvim-lint) on buffer" })
end

return M
