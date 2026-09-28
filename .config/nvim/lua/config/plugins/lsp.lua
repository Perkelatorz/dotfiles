--- nvim-lspconfig: default cmd/filetypes/root_dir per server, as `lsp/<name>.lua` files that
--- |vim.lsp.config()| merges with (so you rarely type them by hand).
--- mason-lspconfig (v2): installs `ensure_installed` and calls |vim.lsp.enable()| for every
--- Mason-installed server. It has **no** `handlers` any more — a v1-style `handlers = {…}`
--- table is silently ignored, so per-server settings go through |vim.lsp.config()| below.
--- Neovim core: |vim.lsp.buf| commands, LspAttach, clients — no extra "LSP engine" plugin.

local M = {}

function M.setup()
	-- Every server: nvim-cmp's completion capabilities.
	vim.lsp.config("*", {
		capabilities = require("cmp_nvim_lsp").default_capabilities(),
	})

	-- Per-server overrides, merged over nvim-lspconfig's defaults. Declared before
	-- mason-lspconfig enables anything; config is resolved when a client starts anyway.
	vim.lsp.config("lua_ls", {
		settings = {
			Lua = {
				runtime = { version = "LuaJIT" },
				diagnostics = { globals = { "vim" } },
				workspace = { checkThirdParty = false },
			},
		},
	})

	vim.lsp.config("rust_analyzer", {
		settings = {
			["rust-analyzer"] = {
				checkOnSave = true,
			},
		},
	})

	vim.lsp.config("pyright", {
		settings = {
			python = {
				analysis = {
					typeCheckingMode = "basic",
					diagnosticMode = "workspace",
				},
			},
		},
	})

	vim.lsp.config("yamlls", {
		-- Avoid stacking with |docker_compose_language_service| on Compose buffers.
		filetypes = { "yaml" },
		settings = {
			redhat = { telemetry = { enabled = false } },
			yaml = {
				-- Conform uses |yamlfmt|; avoid two formatters fighting.
				format = { enable = false },
				validate = true,
				schemaStore = { enable = true },
			},
		},
	})

	require("mason-lspconfig").setup({
		-- lua_ls: Neovim Lua.
		-- ts_ls: TypeScript/JS in .ts/.tsx/.js/.jsx (not the .svelte buffer itself).
		-- eslint: lint + ESLint actions (includes filetype "svelte" in lspconfig defaults).
		-- svelte: svelte-language-server for .svelte (script/style/template, go-to-def inside components).
		-- tailwindcss: Tailwind IntelliSense (class completion, lint) when tailwind.config.* exists.
		-- gopls / pyright / dockerls / docker_compose_language_service / ansiblels: Go, Python, Dockerfile,
		-- Compose YAML (ft yaml.docker-compose), Ansible (ft yaml.ansible).
		-- Nix LSP: **not** from Mason (Mason’s `nil` build needs the Nix package manager). If a **`nil`** binary is on `PATH` (e.g. AUR `nil-git`), it is wired below after this block.
		-- bashls / taplo / html / jsonls / cssls / graphql / marksman / yamlls: shell, TOML, HTML, JSON, CSS/SCSS, GraphQL, Markdown, YAML (schemas; use yamlfmt in Conform to format).
		--
		-- Cross-file TS <-> Svelte (rename/refs across .ts and .svelte): add devDependency
		-- `typescript-svelte-plugin` and in tsconfig.json:
		--   "compilerOptions": { "plugins": [{ "name": "typescript-svelte-plugin" }] }
		-- See: https://github.com/sveltejs/language-tools/tree/master/packages/typescript-plugin
		ensure_installed = {
			"lua_ls",
			"ts_ls",
			"eslint",
			"svelte",
			"tailwindcss",
			"gopls",
			"pyright",
			"dockerls",
			"docker_compose_language_service",
			"ansiblels",
			"rust_analyzer",
			"vue_ls",
			"bashls",
			"taplo",
			"html",
			"jsonls",
			"cssls",
			"graphql",
			"marksman",
			"yamlls",
		},
	})

	-- oxalica/nil as **system** `nil` (e.g. AUR `nil-git`). Mason’s `nil` package is not used (it requires the Nix PM to compile).
	if vim.fn.executable("nil") == 1 then
		vim.lsp.enable("nil_ls")
	end

	-- clangd (C) as the **system** binary from the Arch `clang` package, so it always matches
	-- the installed clang-format/libc headers; not from Mason. Compile flags and clang-tidy
	-- checks for files with no compile_commands.json: ~/.config/clangd/config.yaml.
	if vim.fn.executable("clangd") == 1 then
		vim.lsp.config("clangd", {
			cmd = {
				"clangd",
				"--background-index",
				"--clang-tidy",
				-- Show each overload/parameter list in the menu, not one collapsed entry.
				"--completion-style=detailed",
				-- Never add #include lines behind your back: knowing which header declares
				-- what (stdio.h for printf, stdlib.h for malloc) is part of learning C.
				"--header-insertion=never",
			},
		})
		vim.lsp.enable("clangd")
	end

	-- Servers that must not serve the notes vault, and why.
	--
	--   marksman    Duplicates obsidian.nvim's in-process LSP (definition, references,
	--               rename, completion, symbols) but validates `[[wiki]]` links against
	--               its own index, which does not track notes written to disk outside
	--               the running session -- a Syncthing pull from another machine, the
	--               Obsidian desktop app, a second Nvim. The result is "Link to
	--               non-existent document" on links that resolve fine, and the index
	--               never catches up on its own.
	--   tailwindcss Attaches to markdown looking for class names. There are none in a
	--               notes vault; it is a wasted server and wasted CPU.
	--
	-- Both stay enabled everywhere else -- a README in a code repo still wants marksman.
	-- Detach rather than refuse to start: the vault is also a git repo, so `root_dir`
	-- matches and these would attach regardless.
	local VAULT_EXCLUDED_SERVERS = { marksman = true, tailwindcss = true }

	local function notes_vault()
		local raw = vim.env.NOTES
		if raw == nil or raw == "" then
			raw = "~/notes"
		end
		return (vim.fn.resolve(vim.fn.expand(raw)):gsub("/$", ""))
	end

	vim.api.nvim_create_autocmd("LspAttach", {
		group = vim.api.nvim_create_augroup("config.lsp.vault", { clear = true }),
		callback = function(event)
			local client = vim.lsp.get_client_by_id(event.data.client_id)
			if not client or not VAULT_EXCLUDED_SERVERS[client.name] then
				return
			end
			local name = vim.api.nvim_buf_get_name(event.buf)
			if name == "" then
				return
			end
			local vault = notes_vault()
			local path = vim.fn.resolve(vim.fn.fnamemodify(name, ":p"))
			if path:sub(1, #vault + 1) ~= vault .. "/" then
				return
			end
			vim.schedule(function()
				pcall(vim.lsp.buf_detach_client, event.buf, client.id)
				local ns = vim.lsp.diagnostic.get_namespace(client.id)
				if ns then
					pcall(vim.diagnostic.reset, ns, event.buf)
				end
			end)
		end,
		desc = "Notes vault: detach servers that duplicate or misread obsidian-ls",
	})

	vim.api.nvim_create_autocmd("LspAttach", {
		group = vim.api.nvim_create_augroup("config.lsp", { clear = true }),
		callback = function(event)
			local function map(mode, lhs, rhs, desc)
				vim.keymap.set(mode, lhs, rhs, { buffer = event.buf, silent = true, desc = desc })
			end
			map("n", "K", vim.lsp.buf.hover, "LSP hover (gx on link after Ctrl-w w into float)")
			map("n", "gd", vim.lsp.buf.definition, "LSP definition")
			map("n", "gD", vim.lsp.buf.declaration, "LSP declaration")
			map("n", "gI", vim.lsp.buf.implementation, "LSP implementation")
			map("n", "gy", vim.lsp.buf.type_definition, "LSP type definition")
			map("n", "gr", vim.lsp.buf.references, "LSP references")
			map("n", "<leader>rn", vim.lsp.buf.rename, "LSP rename")
			map({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, "LSP code action")

			-- Inlay hints (0.10+): types/param names inline. Helpful when reading AI-written code.
			if vim.lsp.inlay_hint then
				local client = vim.lsp.get_client_by_id(event.data.client_id)
				if client and client:supports_method("textDocument/inlayHint") then
					vim.lsp.inlay_hint.enable(true, { bufnr = event.buf })
					map("n", "<leader>ch", function()
						local enabled = vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf })
						vim.lsp.inlay_hint.enable(not enabled, { bufnr = event.buf })
					end, "Toggle inlay hints")
				end
			end
		end,
	})
end

return M
