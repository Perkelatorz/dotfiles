return {
	"neovim/nvim-lspconfig",
	event = { "BufReadPre", "BufNewFile" },
	dependencies = {
		"hrsh7th/cmp-nvim-lsp",
		"williamboman/mason.nvim",
		"williamboman/mason-lspconfig.nvim",
		{ "antosha417/nvim-lsp-file-operations", config = true },
		{ "folke/lazydev.nvim", ft = "lua", opts = {} },
		"b0o/schemastore.nvim",
	},
	config = function()
		local lspconfig = require("lspconfig")
		local cmp_nvim_lsp = require("cmp_nvim_lsp")
		local keymap = vim.keymap

		local inlay_hint_enabled = {}

		local on_attach = function(client, bufnr)
		if client.supports_method("textDocument/inlayHint") then
			inlay_hint_enabled[bufnr] = true
			vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
		end

			local opts = { buffer = bufnr, silent = true }

			if client.supports_method("textDocument/hover") then
				local hover_timer = nil
				vim.api.nvim_create_autocmd("CursorHold", {
					buffer = bufnr,
					callback = function()
						if hover_timer then
							hover_timer:close()
							hover_timer = nil
						end
						hover_timer = vim.defer_fn(function()
							hover_timer = nil
							vim.lsp.buf.hover()
						end, 1000)
					end,
				})
			end

			opts.desc = "Go to definition"
			keymap.set("n", "gd", vim.lsp.buf.definition, opts)
			opts.desc = "Go to declaration"
			keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
			opts.desc = "Go to implementation"
			keymap.set("n", "gi", vim.lsp.buf.implementation, opts)

			opts.desc = "Show LSP references"
			keymap.set("n", "gR", "<cmd>Telescope lsp_references<CR>", opts)

			opts.desc = "Code actions"
			keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts)

			opts.desc = "Rename symbol"
			keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)

			opts.desc = "Buffer diagnostics"
			keymap.set("n", "<leader>dl", "<cmd>Telescope diagnostics bufnr=0<CR>", opts)

			opts.desc = "Line diagnostics (float)"
			keymap.set("n", "<leader>dd", vim.diagnostic.open_float, opts)

			opts.desc = "Restart LSP"
			keymap.set("n", "<leader>rs", ":LspRestart<CR>", opts)

			if client.supports_method("textDocument/inlayHint") then
			opts.desc = "Toggle inlay hints"
			keymap.set("n", "<leader>uh", function()
				local enabled = not inlay_hint_enabled[bufnr]
				inlay_hint_enabled[bufnr] = enabled
				vim.lsp.inlay_hint.enable(enabled, { bufnr = bufnr })
			end, opts)
			end
		end

		local virtual_text_enabled = false
		vim.keymap.set("n", "<leader>uv", function()
			virtual_text_enabled = not virtual_text_enabled
			vim.diagnostic.config({ virtual_text = virtual_text_enabled })
		end, { desc = "Toggle virtual text diagnostics" })

		local capabilities = cmp_nvim_lsp.default_capabilities()
		capabilities.positionEncoding = "utf-8"
		if capabilities.textDocument and capabilities.textDocument.inlayHint then
			capabilities.textDocument.inlayHint.dynamicRegistration = false
		end

		vim.diagnostic.config({
			virtual_text = false,
			signs = {
				text = {
					[vim.diagnostic.severity.ERROR] = " ",
					[vim.diagnostic.severity.WARN] = " ",
					[vim.diagnostic.severity.HINT] = "󰠠 ",
					[vim.diagnostic.severity.INFO] = " ",
				},
				texthl = {
					[vim.diagnostic.severity.ERROR] = "DiagnosticSignError",
					[vim.diagnostic.severity.WARN] = "DiagnosticSignWarn",
					[vim.diagnostic.severity.HINT] = "DiagnosticSignHint",
					[vim.diagnostic.severity.INFO] = "DiagnosticSignInfo",
				},
			},
			update_in_insert = false,
			underline = true,
			severity_sort = true,
			float = {
				focusable = false,
				style = "minimal",
				border = "rounded",
				source = "always",
				header = "",
				prefix = "",
			},
		})

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
						client.server_capabilities.hoverProvider = false
						client.server_capabilities.signatureHelpProvider = nil
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
							client.handlers["textDocument/publishDiagnostics"] = function() end

							client.server_capabilities.documentFormattingProvider = false
							client.server_capabilities.documentRangeFormattingProvider = false

							on_attach(client, bufnr)
						end,
						capabilities = capabilities,
						settings = {
							pylsp = {
								plugins = {
							pycodestyle = { enabled = false },
									pyflakes = { enabled = false },
									mccabe = { enabled = false },
									autopep8 = { enabled = false },
									yapf = { enabled = false },

							jedi_completion = { enabled = true, include_params = true },
									jedi_hover = { enabled = true },
									jedi_signature_help = { enabled = true },
									jedi_symbols = { enabled = true },

							rope_completion = { enabled = true, eager = true },
								},
							},
						},
					})
				end,

			ruff = function()
				lspconfig.ruff.setup({
					on_attach = function(client, bufnr)
						client.server_capabilities.documentFormattingProvider = false
						client.server_capabilities.documentRangeFormattingProvider = false
						vim.keymap.set("n", "<leader>ci", function()
								vim.lsp.buf.code_action({ context = { only = { "source.organizeImports.ruff" } } })
							end, { buffer = bufnr, desc = "Organize imports (Ruff)" })
							on_attach(client, bufnr)
						end,
						capabilities = capabilities,
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
									unusedvariable = true, -- report unused variables
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

			svelte = function()
					lspconfig.svelte.setup({
						on_attach = on_attach,
						capabilities = capabilities,
						filetypes = { "svelte" },
					settings = {
						svelte = {
							plugin = {
								svelte = {
									compilerWarnings = {
										["a11y-accesskey"] = "ignore",
									},
									useNewTransformation = true,
									},
								},
							},
						},
					})
				end,

			emmet_language_server = function()
					lspconfig.emmet_language_server.setup({
						on_attach = on_attach,
						capabilities = capabilities,
						filetypes = {
							"html",
							"css",
							"scss",
							"sass",
							"less",
							"svelte",
							"vue",
							"javascriptreact",
							"typescriptreact",
						},
					init_options = {
						showAbbreviationSuggestions = true,
						showExpandedAbbreviation = "always",
						preferences = {},
						includeLanguages = {
								svelte = "html",
								vue = "html",
							},
						},
					})
				end,

			tailwindcss = function()
					lspconfig.tailwindcss.setup({
						on_attach = on_attach,
						capabilities = capabilities,
						filetypes = {
							"html",
							"css",
							"scss",
							"sass",
							"less",
							"svelte",
							"vue",
							"javascriptreact",
							"typescriptreact",
						},
						settings = {
							tailwindCSS = {
								classAttributes = { "class", "className", "classList", "ngClass" },
								includeLanguages = {
									svelte = "html",
									vue = "html",
								},
								experimental = {
									classRegex = {
										"class:([\\w-]+)",
									},
								},
								lint = {
									cssConflict = "warning",
									invalidApply = "error",
									invalidScreen = "error",
									invalidVariant = "error",
									invalidConfigPath = "error",
									invalidTailwindDirective = "error",
									recommendedVariantOrder = "warning",
								},
								validate = true,
							},
						},
						root_dir = function(fname)
							local root_pattern = require("lspconfig").util.root_pattern(
								"tailwind.config.js",
								"tailwind.config.ts",
								"tailwind.config.cjs",
								"tailwind.config.mjs"
							)
							local root = root_pattern(fname)
							if root then
								return root
							end
							local package_json = require("lspconfig").util.root_pattern("package.json")(fname)
							if package_json then
								local package = vim.fn.json_decode(vim.fn.readfile(package_json .. "/package.json"))
								if
									package
									and (
										(package.dependencies and package.dependencies.tailwindcss)
										or (package.devDependencies and package.devDependencies.tailwindcss)
									)
								then
									return package_json
								end
							end
							return nil
						end,
					})
				end,

				jsonls = function()
					local schemastore_ok, schemastore = pcall(require, "schemastore")
					lspconfig.jsonls.setup({
						on_attach = on_attach,
						capabilities = capabilities,
						settings = {
							json = {
								schemas = schemastore_ok and schemastore.json.schemas() or {},
								validate = { enable = true },
							},
						},
					})
				end,

				yamlls = function()
					local schemastore_ok, schemastore = pcall(require, "schemastore")
					lspconfig.yamlls.setup({
						on_attach = on_attach,
						capabilities = capabilities,
						settings = {
							yaml = {
								schemaStore = {
									enable = false,
									url = "",
								},
								schemas = schemastore_ok and schemastore.yaml.schemas() or {},
								validate = true,
								completion = true,
								hover = true,
								format = {
									enable = true,
								},
								customTags = {
									"!reference sequence",
									"!vault",
								},
							},
						},
					})
				end,

			bashls = function()
					lspconfig.bashls.setup({
						on_attach = on_attach,
						capabilities = capabilities,
						filetypes = { "sh", "bash", "zsh" },
						settings = {
							bash = {
								filetypes = { "sh", "bash", "zsh" },
							},
						},
					})
				end,

			hyprls = function()
					lspconfig.hyprls.setup({
						on_attach = on_attach,
						capabilities = capabilities,
						filetypes = { "hyprlang" },
					})
				end,
			},
		})
	end,
}
