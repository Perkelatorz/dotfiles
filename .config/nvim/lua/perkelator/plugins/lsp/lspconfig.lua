return {
	"neovim/nvim-lspconfig",
	event = { "BufReadPre", "BufNewFile" },
	dependencies = {
		"hrsh7th/cmp-nvim-lsp",
		"williamboman/mason.nvim",
		"williamboman/mason-lspconfig.nvim",
		{ "antosha417/nvim-lsp-file-operations", config = true },
		{ "folke/neodev.nvim", opts = {} },
	},
	config = function()
		local lspconfig = require("lspconfig")
		local cmp_nvim_lsp = require("cmp_nvim_lsp")
		local keymap = vim.keymap

		local on_attach = function(client, bufnr)
			local opts = { buffer = bufnr, silent = true }

			opts.desc = "Show LSP references"
			keymap.set("n", "gR", "<cmd>Telescope lsp_references<CR>", opts)

			opts.desc = "Go to declaration"
			keymap.set("n", "gD", vim.lsp.buf.declaration, opts)

			opts.desc = "Show LSP definitions"
			keymap.set("n", "gd", "<cmd>Telescope lsp_definitions<CR>", opts)

			opts.desc = "Show LSP implementations"
			keymap.set("n", "gi", "<cmd>Telescope lsp_implementations<CR>", opts)

			opts.desc = "Show LSP type definitions"
			keymap.set("n", "gt", "<cmd>Telescope lsp_type_definitions<CR>", opts)

			opts.desc = "See available code actions"
			keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts)

			opts.desc = "Smart rename"
			keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)

			opts.desc = "Show buffer diagnostics"
			keymap.set("n", "<leader>D", "<cmd>Telescope diagnostics bufnr=0<CR>", opts)

			opts.desc = "Show line diagnostics"
			keymap.set("n", "<leader>d", vim.diagnostic.open_float, opts)

			opts.desc = "Go to previous diagnostic"
			keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)

			opts.desc = "Go to next diagnostic"
			keymap.set("n", "]d", vim.diagnostic.goto_next, opts)

			opts.desc = "Show documentation for what is under cursor"
			keymap.set("n", "K", vim.lsp.buf.hover, opts)

			opts.desc = "Restart LSP"
			keymap.set("n", "<leader>rs", ":LspRestart<CR>", opts)
		end

		local capabilities = cmp_nvim_lsp.default_capabilities()

		local signs = { Error = " ", Warn = " ", Hint = "󰠠 ", Info = " " }
		for type, icon in pairs(signs) do
			local hl = "DiagnosticSign" .. type
			vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
		end

		local default_setup = function(server)
			lspconfig[server].setup({
				on_attach = on_attach,
				capabilities = capabilities,
			})
		end

		require("mason-lspconfig").setup({
			ensure_installed = {},
			automatic_installation = true,
			handlers = {
				default_setup,

				lua_ls = function()
					lspconfig.lua_ls.setup({
						on_attach = on_attach,
						capabilities = capabilities,
						settings = {
							Lua = {
								diagnostics = {
									globals = { "vim" },
								},
								completion = {
									callSnippet = "Replace",
								},
							},
						},
					})
				end,

				pyright = function()
					lspconfig.pyright.setup({
						on_attach = function(client, bufnr)
							-- Turn off doc-related providers from Pyright
							client.server_capabilities.hoverProvider = false
							client.server_capabilities.signatureHelpProvider = nil
							-- optional: also disable completion if you want pylsp completions
							-- client.server_capabilities.completionProvider = nil

							on_attach(client, bufnr)
						end,
						capabilities = capabilities,
						settings = {
							python = {
								analysis = {
									typeCheckingMode = "basic",
									autoSearchPaths = true,
									useLibraryCodeForTypes = true,
									diagnosticMode = "workspace",
								},
							},
						},
					})
				end,
				pylsp = function()
					lspconfig.pylsp.setup({
						on_attach = function(client, bufnr)
							-- Let pyright own diagnostics; keep jedi hover/signature
							-- Neovim doesn’t have a simple diagnosticProvider toggle, so prevent pylsp from publishing diagnostics:
							client.handlers["textDocument/publishDiagnostics"] = function() end

							-- Optional: also turn off formatting here if you use black/ruff elsewhere
							client.server_capabilities.documentFormattingProvider = false
							client.server_capabilities.documentRangeFormattingProvider = false

							on_attach(client, bufnr)
						end,
						capabilities = capabilities,
						settings = {
							pylsp = {
								plugins = {
									-- Turn off pylsp linters/formatters if you use ruff/black
									pycodestyle = { enabled = false },
									pyflakes = { enabled = false },
									mccabe = { enabled = false },
									autopep8 = { enabled = false },
									yapf = { enabled = false },

									-- Jedi for rich docs
									jedi_completion = { enabled = true, include_params = true },
									jedi_hover = { enabled = true },
									jedi_signature_help = { enabled = true },
									jedi_symbols = { enabled = true },

									-- Optional: rope
									rope_completion = { enabled = true, eager = true },
								},
							},
						},
					})
				end,

				-- Optional but recommended: Ruff for lint/fixes/imports; keep formatting off if using Black
				ruff = function()
					lspconfig.ruff.setup({
						on_attach = function(client, bufnr)
							client.server_capabilities.documentFormattingProvider = false
							client.server_capabilities.documentRangeFormattingProvider = false
							-- Optional: keymap to organize imports via Ruff
							vim.keymap.set("n", "<leader>oi", function()
								vim.lsp.buf.code_action({ context = { only = { "source.organizeImports.ruff" } } })
							end, { buffer = bufnr, desc = "Ruff: Organize Imports" })
							on_attach(client, bufnr)
						end,
						capabilities = capabilities,
					})
				end,

				powershell_es = function()
					lspconfig.powershell_es.setup({
						on_attach = on_attach,
						capabilities = capabilities,
						bundle_path = vim.fn.stdpath("data") .. "/mason/packages/powershell-editor-services",
						single_file_support = true,
					})
				end,

				gopls = function()
					lspconfig.gopls.setup({
						on_attach = on_attach,
						capabilities = capabilities,
						settings = {
							gopls = {
								analyses = {
									unusedparams = true,
									shadow = true,
								},
								staticcheck = true,
								gofumpt = true,
								usePlaceholders = true,
								completeUnimported = true,
							},
						},
						-- Optional flags or root_dir can be added here if desired
						-- flags = { debounce_text_changes = 150 },
					})
				end,
			},
		})
	end,
}
