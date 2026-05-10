--- nvim-treesitter (rewrite for Nvim 0.12+): installs extra parsers + queries; |vim.treesitter.start()| enables highlights.
--- Neovim’s Tree-sitter *engine* is built-in; this plugin supplies grammars for TS/Svelte/HTML/etc.
--- Requirements: `tree-sitter` CLI (0.26.1+), `curl`, `tar`, C compiler — see https://github.com/nvim-treesitter/nvim-treesitter#requirements

local M = {}

local parsers = {
	"lua",
	"vim",
	"vimdoc",
	"bash",
	"javascript",
	"typescript",
	"tsx",
	"svelte",
	"html",
	"css",
	"scss",
	"json",
	"yaml",
	"toml",
	"dockerfile",
	"markdown",
	"markdown_inline",
	"python",
	"vue",
	"rust",
	"go",
	"regex",
	"nix",
	"graphql",
	"sql",
	"csv",
	"tsv",
}

local highlight_fts = {
	"lua",
	"markdown",
	"c",
	"vim",
	"help",
	"query",
	"javascript",
	"javascriptreact",
	"typescript",
	"typescriptreact",
	"svelte",
	"html",
	"css",
	"scss",
	"json",
	"jsonc",
	"yaml",
	"yaml.ansible",
	"yaml.docker-compose",
	"toml",
	"dockerfile",
	"python",
	"vue",
	"rust",
	"go",
	"nix",
	"graphql",
	"sql",
	"bash",
	"sh",
	"csv",
	"tsv",
}

function M.setup()
	require("nvim-treesitter").setup({
		install_dir = vim.fs.joinpath(vim.fn.stdpath("data") --[[@as string]], "site"),
	})

	-- Install only missing parsers, after startup, with a small job cap so the
	-- first run does not compile ~20 grammars at full parallelism (CPU pegged, UI frozen).
	vim.api.nvim_create_autocmd("VimEnter", {
		once = true,
		callback = function()
			vim.defer_fn(function()
				local ts = require("nvim-treesitter")
				local installed = ts.get_installed("parsers")
				local need = vim.tbl_filter(function(p)
					return not vim.list_contains(installed, p)
				end, parsers)
				if #need > 0 then
					ts.install(need, { max_jobs = 4, summary = true })
				end
			end, 150)
		end,
	})

	vim.api.nvim_create_autocmd("FileType", {
		group = vim.api.nvim_create_augroup("config.treesitter_highlight", { clear = true }),
		pattern = highlight_fts,
		callback = function()
			pcall(vim.treesitter.start)
		end,
	})

	-- Textobjects: select/jump function & class. Plugin is module-style; configure_ts() may be a no-op
	-- with the newer nvim-treesitter rewrite, so we wire keymaps directly via the plugin's select/move APIs.
	local ok_sel, ts_select = pcall(require, "nvim-treesitter-textobjects.select")
	if ok_sel then
		local function sel(query, query_group)
			return function()
				ts_select.select_textobject(query, query_group)
			end
		end
		vim.keymap.set({ "x", "o" }, "af", sel("@function.outer", "textobjects"), { desc = "Around function" })
		vim.keymap.set({ "x", "o" }, "if", sel("@function.inner", "textobjects"), { desc = "Inner function" })
		vim.keymap.set({ "x", "o" }, "ac", sel("@class.outer", "textobjects"), { desc = "Around class" })
		vim.keymap.set({ "x", "o" }, "ic", sel("@class.inner", "textobjects"), { desc = "Inner class" })
	end

	local ok_move, ts_move = pcall(require, "nvim-treesitter-textobjects.move")
	if ok_move then
		vim.keymap.set({ "n", "x", "o" }, "]f", function()
			ts_move.goto_next_start("@function.outer", "textobjects")
		end, { desc = "Next function start" })
		vim.keymap.set({ "n", "x", "o" }, "[f", function()
			ts_move.goto_previous_start("@function.outer", "textobjects")
		end, { desc = "Prev function start" })
		vim.keymap.set({ "n", "x", "o" }, "]F", function()
			ts_move.goto_next_end("@function.outer", "textobjects")
		end, { desc = "Next function end" })
		vim.keymap.set({ "n", "x", "o" }, "[F", function()
			ts_move.goto_previous_end("@function.outer", "textobjects")
		end, { desc = "Prev function end" })
	end
end

return M
