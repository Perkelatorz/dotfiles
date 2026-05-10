--- |conform.nvim|: format on save (**Prettier**, **yamlfmt**, Ruff, …); falls back to LSP when no formatter fits.
--- Install binaries once via |:Mason| (see |config.plugins.mason| `ensure_installed`).

local M = {}

local web = { "prettier" }

function M.setup()
	require("conform").setup({
		formatters_by_ft = {
			javascript = web,
			javascriptreact = web,
			typescript = web,
			typescriptreact = web,
			svelte = web,
			vue = web,
			json = web,
			jsonc = web,
			css = web,
			scss = web,
			html = web,
			markdown = web,
			-- |yamlfmt| (Mason) fixes indentation/spacing; |yamlls| handles validation/schemas.
			yaml = { "yamlfmt" },
			["yaml.docker-compose"] = { "yamlfmt" },
			-- Prefer LSP / ansible-lint semantics over Prettier for Ansible buffers.
			["yaml.ansible"] = {},
			graphql = web,
			go = { "goimports", "gofmt" },
			python = { "ruff_format", "ruff_organize_imports" },
			lua = { "stylua" },
			bash = { "shfmt" },
			sh = { "shfmt" },
			toml = { "taplo" },
		},
		format_after_save = {
			lsp_format = "fallback",
			async = true,
		},
	})

	vim.keymap.set({ "n", "v" }, "<leader>cf", function()
		require("conform").format({ async = true, lsp_fallback = true })
	end, { desc = "Format buffer or selection (Conform + LSP fallback)" })
end

return M
