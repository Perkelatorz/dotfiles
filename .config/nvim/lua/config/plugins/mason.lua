--- Mason + mason-tool-installer.nvim: `ensure_installed` for **CLI tools** (same idea as mason-lspconfig for LSP).

local M = {}

function M.setup()
	require("mason").setup({
		ui = { border = "rounded" },
		-- Fewer Mason log lines to file; UI installs unchanged.
		log_level = vim.log.levels.WARN,
	})

	require("mason-tool-installer").setup({
		-- No null-ls / nvim-dap integration (not in this config); avoids extra mapping work.
		integrations = {
			["mason-lspconfig"] = true,
			["mason-null-ls"] = false,
			["mason-nvim-dap"] = false,
		},
		ensure_installed = {
			"prettier",
			-- Formatters / linters (LSPs: |config.plugins.lsp|).
			"ruff",
			"stylua",
			"shfmt",
			"shellcheck",
			"hadolint",
			"ansible-lint",
			"goimports",
			"golangci-lint",
			"actionlint",
			"yamlfmt",
			"yamllint",
			"glow",
		},
	})

	vim.api.nvim_create_autocmd("User", {
		pattern = "MasonToolsUpdateCompleted",
		callback = function(args)
			local names = args.data
			if type(names) ~= "table" or #names == 0 then
				return
			end
			vim.notify(
				("Mason CLI: %d tool(s) touched this run (install/update). Details: :Mason"):format(#names),
				vim.log.levels.INFO,
				{ title = "Mason tools", timeout = 5500 }
			)
		end,
	})
end

return M
