return {
	"williamboman/mason.nvim",
	dependencies = {
		"williamboman/mason-lspconfig.nvim",
		"WhoIsSethDaniel/mason-tool-installer.nvim",
	},
	config = function()
		local mason = require("mason")
		local mason_lspconfig = require("mason-lspconfig")
		local mason_tool_installer = require("mason-tool-installer")

		mason.setup({
			ui = {
				icons = {
					package_installed = "✓",
					package_pending = "➜",
					package_uninstalled = "✗",
				},
			},
		})

		mason_lspconfig.setup({
			ensure_installed = {
				"html",
				"cssls",
				"lua_ls",
				"pyright",
				"powershell_es",
				"ansiblels",
				"dockerls",
				"lemminx",
				"terraformls",
				"omnisharp",
				"jsonls",
				"eslint",
				"ts_ls",
				"bashls",
				"docker_compose_language_service",
				"typos_lsp",
				"gopls",
				"marksman",
			},
			automatic_installation = true,
			handlers = nil,
		})

		mason_tool_installer.setup({
			ensure_installed = {
				"prettier",
				"stylua",
				"isort",
				"black",
				"tflint",
				"golangci-lint",
				"gofumpt",
				"goimports",
				"ansible-lint",
				"hadolint",
				"markdownlint",
				"yamllint",
				"ruff",
				"mypy",
				"csharpier",
				"shfmt",
			},
		})
	end,
}