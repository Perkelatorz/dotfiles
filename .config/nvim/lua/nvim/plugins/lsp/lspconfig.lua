return {
	"neovim/nvim-lspconfig",
	event = { "BufReadPre", "BufNewFile" },
	dependencies = {
		"hrsh7th/cmp-nvim-lsp",
		"williamboman/mason.nvim",
		"williamboman/mason-lspconfig.nvim",
		{ "antosha417/nvim-lsp-file-operations", config = true },
		{ "folke/neodev.nvim", opts = {} },
		"b0o/schemastore.nvim",
	},
	config = function()
		local lspconfig = require("lspconfig")
		local cmp_nvim_lsp = require("cmp_nvim_lsp")
		local keymap = vim.keymap

		-- Track inlay hint state per buffer
		local inlay_hint_enabled = {}

		local on_attach = function(client, bufnr)
			-- Start with inlay hints enabled by default
			if client.supports_method("textDocument/inlayHint") then
				inlay_hint_enabled[bufnr] = true
				vim.lsp.inlay_hint(bufnr, true)
			end

			local opts = { buffer = bufnr, silent = true }

			-- Enhanced references with Telescope (better than default gr)
			opts.desc = "Show LSP references"
			keymap.set("n", "gR", "<cmd>Telescope lsp_references<CR>", opts)

			-- Code actions (standard binding)
			opts.desc = "Code actions"
			keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts)

			-- Rename (standard binding)
			opts.desc = "Rename symbol"
			keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)

			-- Diagnostics in Telescope (enhanced view)
			opts.desc = "Buffer diagnostics"
			keymap.set("n", "<leader>dl", "<cmd>Telescope diagnostics bufnr=0<CR>", opts)

			-- Diagnostic float (quick view); <leader>dd to avoid conflict with Flash on "f"
			opts.desc = "Line diagnostics (float)"
			keymap.set("n", "<leader>dd", vim.diagnostic.open_float, opts)

			-- Restart LSP
			opts.desc = "Restart LSP"
			keymap.set("n", "<leader>rs", ":LspRestart<CR>", opts)

			-- Toggle inlay hints
			if client.supports_method("textDocument/inlayHint") then
				opts.desc = "Toggle inlay hints"
				keymap.set("n", "<leader>uh", function()
					local enabled = not inlay_hint_enabled[bufnr]
					inlay_hint_enabled[bufnr] = enabled
					vim.lsp.inlay_hint(bufnr, enabled)
				end, opts)
			end
		end

		-- Global toggle for virtual text diagnostics
		local virtual_text_enabled = false
		vim.keymap.set("n", "<leader>uv", function()
			virtual_text_enabled = not virtual_text_enabled
			vim.diagnostic.config({ virtual_text = virtual_text_enabled })
		end, { desc = "Toggle virtual text diagnostics" })

		local capabilities = cmp_nvim_lsp.default_capabilities()
		-- Ensure all clients use UTF-8 position encoding to avoid mismatches
		capabilities.positionEncoding = "utf-8"
		-- Disable inlay hints (inline type hints, parameter hints, etc.)
		if capabilities.textDocument and capabilities.textDocument.inlayHint then
			capabilities.textDocument.inlayHint.dynamicRegistration = false
		end

		-- Configure diagnostics using the modern API
		vim.diagnostic.config({
			virtual_text = false, -- Disable inline diagnostic text
			signs = {
				-- Define diagnostic signs using the modern API (replaces deprecated sign_define)
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

				-- Svelte Language Server
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
											-- Adjust warnings as needed
											["a11y-accesskey"] = "ignore",
										},
										-- Use TypeScript version from workspace
										useNewTransformation = true,
									},
								},
							},
						},
					})
				end,

				-- Emmet Language Server for fast HTML expansion
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
							-- Show abbreviation suggestions
							showAbbreviationSuggestions = true,
							-- Show expanded abbreviations
							showExpandedAbbreviation = "always",
							-- Emmet preferences
							preferences = {},
							-- Include languages
							includeLanguages = {
								svelte = "html",
								vue = "html",
							},
						},
					})
				end,

				-- Tailwind CSS Language Server (auto-detects tailwind.config.js)
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
								-- Class attributes to check
								classAttributes = { "class", "className", "classList", "ngClass" },
								-- Include Svelte as HTML
								includeLanguages = {
									svelte = "html",
									vue = "html",
								},
								-- Experimental features
								experimental = {
									classRegex = {
										-- Support for class: directive in Svelte
										"class:([\\w-]+)",
									},
								},
								-- Lint settings
								lint = {
									cssConflict = "warning",
									invalidApply = "error",
									invalidScreen = "error",
									invalidVariant = "error",
									invalidConfigPath = "error",
									invalidTailwindDirective = "error",
									recommendedVariantOrder = "warning",
								},
								-- Validate on file types
								validate = true,
							},
						},
						-- Only activate if tailwind.config.js/ts or tailwind in package.json exists
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
							-- Also check package.json for tailwindcss dependency
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

				-- Bash Language Server
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

				-- Hyprland Language Server (hyprls)
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
