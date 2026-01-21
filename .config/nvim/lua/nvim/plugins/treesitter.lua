return {
	"nvim-treesitter/nvim-treesitter",
	build = ":TSUpdate",
	-- Load immediately instead of lazy loading to ensure highlighting works
	lazy = false,
	priority = 1000, -- High priority to load before other plugins
	dependencies = {
		"windwp/nvim-ts-autotag",
	},
	config = function()
		local utils = require("nvim.core.utils")
		
		-- Modern nvim-treesitter (post v1.0) uses a simpler config approach
		-- Disable vim syntax to avoid conflicts with treesitter highlighting
		vim.cmd("syntax off")
		
		-- Setup basic treesitter config
		require("nvim-treesitter.config").setup({
			install_dir = vim.fn.stdpath("data") .. "/site",
		})
		
		-- List of parsers to ensure are installed
		local ensure_installed = {
			-- Web development
			"html", "css", "scss", "javascript", "typescript", "tsx", "svelte",
			-- Configuration
			"json", "yaml", "xml", "dockerfile", "terraform", "hcl", "hyprlang",
			-- Programming languages
			"lua", "vim", "python", "go", "gomod", "gowork", "gosum", "c", "c_sharp", "bash", "powershell",
			-- Documentation
			"markdown", "markdown_inline", "vimdoc",
			-- Other
			"gitignore", "query",
		}
		
		-- Svelte-specific parsers (used by helper commands)
		local SVELTE_PARSERS = {
			"svelte", "html", "javascript", "typescript", "css", "scss",
		}
		
		-- Auto-install missing parsers on first file open
		vim.api.nvim_create_autocmd("FileType", {
			pattern = "*",
			once = true,
			callback = function()
				local config = require("nvim-treesitter.config")
				local installed = config.get_installed("parsers")
				for _, parser in ipairs(ensure_installed) do
					if not vim.list_contains(installed, parser) then
						vim.cmd("TSInstall " .. parser)
					end
				end
			end,
		})

		-- configure autotagging (w/ nvim-ts-autotag plugin)
		local autotag, autotag_ok = utils.safe_require("nvim-ts-autotag")
		if autotag_ok then
			autotag.setup({
				opts = {
					-- Enable auto-tag for these file types
					enable_close = true, -- Auto close tags
					enable_rename = true, -- Auto rename pairs of tags
					enable_close_on_slash = false, -- Auto close on trailing </
				},
				-- Add svelte to supported filetypes
				per_filetype = {
					["html"] = {
						enable_close = true
					},
					["svelte"] = {
						enable_close = true
					},
					["vue"] = {
						enable_close = true
					},
					["javascriptreact"] = {
						enable_close = true
					},
					["typescriptreact"] = {
						enable_close = true
					},
				},
			})
		end
		
		-- Helper command to install all Svelte-related parsers
		vim.api.nvim_create_user_command("TSInstallSvelte", function()
			vim.notify("Installing Svelte parsers: " .. table.concat(SVELTE_PARSERS, ", "), vim.log.levels.INFO)
			
			-- Install all parsers
			for _, parser_name in ipairs(SVELTE_PARSERS) do
				vim.cmd("TSInstall " .. parser_name)
			end
			
			vim.notify("Svelte parsers installation complete!", vim.log.levels.INFO)
		end, { desc = "Install all parsers needed for Svelte syntax highlighting" })
		
		-- Diagnostic command to check Svelte highlighting status
		vim.api.nvim_create_user_command("TSCheckSvelte", function()
			
			local messages = {}
			table.insert(messages, "=== Svelte Treesitter Status ===")
			table.insert(messages, "Filetype: " .. (vim.bo.filetype or "not set"))
			
			-- Check if parsers are installed
			for _, parser_name in ipairs(SVELTE_PARSERS) do
				local parser_path = vim.fn.stdpath("data") .. "/site/parser/" .. parser_name .. ".so"
				local installed = vim.fn.filereadable(parser_path) == 1
				local status = installed and "✓ INSTALLED" or "✗ NOT INSTALLED"
				table.insert(messages, parser_name .. ": " .. status)
			end
			
			-- Check if highlighting is active for current buffer
			local has_ts = pcall(require, "nvim-treesitter")
			table.insert(messages, "Treesitter loaded: " .. (has_ts and "✓ YES" or "✗ NO"))
			
			-- Check if buffer has active highlighter
			local bufnr = vim.api.nvim_get_current_buf()
			local has_highlighter = vim.treesitter.highlighter.active[bufnr] ~= nil
			table.insert(messages, "Active highlighter: " .. (has_highlighter and "✓ YES" or "✗ NO"))
			
			-- Get buffer language
			local lang = vim.treesitter.language.get_lang(vim.bo.filetype) or "none"
			table.insert(messages, "Buffer language: " .. lang)
			
			vim.notify(table.concat(messages, "\n"), vim.log.levels.INFO)
			print(table.concat(messages, "\n"))
		end, { desc = "Check Svelte treesitter configuration status" })
		
		-- Enable Treesitter highlighting for supported filetypes
		-- Modern nvim-treesitter requires explicit vim.treesitter.start() calls
		-- See: https://github.com/nvim-treesitter/nvim-treesitter#highlighting
		local highlight_group = vim.api.nvim_create_augroup("TreesitterHighlight", { clear = true })
		
		vim.api.nvim_create_autocmd("FileType", {
			group = highlight_group,
			pattern = {
				-- Web
				"svelte", "html", "css", "scss", "javascript", "typescript", "tsx", "jsx",
				-- Config
				"json", "yaml", "xml", "dockerfile", "terraform", "hcl", "hyprlang",
				-- Programming
				"lua", "vim", "python", "go", "bash", "sh", "zsh", "c", "c_sharp",
				-- Documentation
				"markdown",
			},
			callback = function()
				local ok, err = pcall(vim.treesitter.start)
				if not ok then
					vim.notify("Failed to start treesitter: " .. tostring(err), vim.log.levels.DEBUG)
				end
			end,
			desc = "Enable treesitter highlighting for supported filetypes",
		})
		
		-- Enable treesitter-based folding for supported filetypes
		local folding_group = vim.api.nvim_create_augroup("TreesitterFolding", { clear = true })
		
		vim.api.nvim_create_autocmd("FileType", {
			group = folding_group,
			pattern = {
				"svelte", "javascript", "typescript", "tsx", "jsx",
				"python", "go", "lua", "rust", "c", "cpp",
			},
			callback = function()
				vim.opt_local.foldmethod = "expr"
				vim.opt_local.foldexpr = "v:lua.vim.treesitter.foldexpr()"
				vim.opt_local.foldenable = false -- Don't fold by default
				vim.opt_local.foldlevel = 99 -- Start with all folds open
			end,
			desc = "Enable treesitter folding for supported filetypes",
		})
		
	end,
}
