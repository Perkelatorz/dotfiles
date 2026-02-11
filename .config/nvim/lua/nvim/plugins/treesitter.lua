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
		
		-- Parsers to ensure are installed; plugin installs only *missing* ones (no re-download every startup)
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
		
		-- Setup treesitter: use built-in ensure_installed so only missing parsers are installed once
		require("nvim-treesitter.config").setup({
			ensure_installed = ensure_installed,
			auto_install = false, -- only install from ensure_installed, no on-demand install
		})
		
		-- Svelte-specific parsers (used by helper commands)
		local SVELTE_PARSERS = {
			"svelte", "html", "javascript", "typescript", "css", "scss",
		}

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

		-- Highlight bracket pair in red when cursor is *inside* them (not only when on a bracket)
		local bracket_ns = vim.api.nvim_create_namespace("bracket_inside")
		local open_brackets = { ["("] = true, ["["] = true, ["{"] = true }
		local close_brackets = { [")"] = true, ["]"] = true, ["}"] = true }

		local function get_char(bufnr, row, col)
			local line = vim.api.nvim_buf_get_lines(bufnr, row, row + 1, false)
			if not line or not line[1] then return nil end
			return line[1]:sub(col + 1, col + 1)
		end

		local function find_enclosing_pair(bufnr, cursor_row, cursor_col)
			local ok, parser = pcall(vim.treesitter.get_parser, bufnr)
			if not ok or not parser then return nil end
			local parsed = parser:parse()
			local root = parsed[1] and parsed[1]:root()
			if not root then return nil end

			local function spans_brackets(node)
				local sr, sc, er, ec = node:range()
				local open_ch = get_char(bufnr, sr, sc)
				local close_ch = get_char(bufnr, er, math.max(0, ec - 1))
				return open_ch and close_ch and open_brackets[open_ch] and close_brackets[close_ch]
			end

			local function cursor_inside(node)
				local sr, sc, er, ec = node:range()
				if cursor_row < sr or cursor_row > er then return false end
				if cursor_row == sr and cursor_col <= sc then return false end
				if cursor_row == er and cursor_col >= ec - 1 then return false end
				return true
			end

			local best = nil
			local function visit(node)
				local ok = pcall(function()
					if not spans_brackets(node) then
						for child, _ in node:iter_children() do visit(child) end
						return
					end
					if cursor_inside(node) then
						best = node
						for child, _ in node:iter_children() do visit(child) end
					end
				end)
				if not ok then end -- ignore invalid nodes
			end
			visit(root)
			return best
		end

		local function bracket_highlight()
			local bufnr = vim.api.nvim_get_current_buf()
			vim.api.nvim_buf_clear_namespace(bufnr, bracket_ns, 0, -1)
			local row, col = vim.api.nvim_win_get_cursor(0)[1] - 1, vim.api.nvim_win_get_cursor(0)[2]
			local node = find_enclosing_pair(bufnr, row, col)
			if not node then return end
			local sr, sc, er, ec = node:range()
			vim.api.nvim_buf_add_highlight(bufnr, bracket_ns, "MatchParen", sr, sc, sc + 1)
			vim.api.nvim_buf_add_highlight(bufnr, bracket_ns, "MatchParen", er, math.max(0, ec - 1), ec)
		end

		vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
			callback = bracket_highlight,
			desc = "Highlight bracket pair when cursor is inside",
		})
	end,
}
