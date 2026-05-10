--- Wire-up for plugins declared in |config.pack|.
--- Order matters: Notify → Devicons → Gitsigns → Which-key → Lualine → Mason → Tree-sitter →
--- Render-markdown → CSV view → … → LSP → Fidget → Trouble → Diffview → Conform → nvim-lint.

local M = {}

function M.setup()
	require("config.plugins.notify").setup()
	require("config.plugins.devicons").setup()
	require("config.plugins.gitsigns").setup()
	require("config.plugins.which-key").setup()
	require("config.plugins.lualine").setup()
	require("config.plugins.mason").setup()
	require("config.plugins.treesitter").setup()
	require("config.plugins.ts_autotag").setup()
	require("config.plugins.surround").setup()
	require("config.plugins.render_markdown").setup()
	require("config.plugins.csvview").setup()
	require("config.plugins.ibl").setup()
	require("config.plugins.flash").setup()
	require("config.plugins.telescope").setup()
	require("config.plugins.dressing").setup()
	require("config.plugins.arrow").setup()
	require("config.plugins.neo-tree").setup()
	require("config.plugins.toggleterm").setup()
	require("config.plugins.codeium").setup()
	require("config.plugins.cmp").setup()
	require("config.plugins.autopairs").setup()
	require("config.plugins.lsp").setup()
	require("config.plugins.fidget").setup()
	require("config.plugins.trouble").setup()
	require("config.plugins.diffview").setup()
	require("config.plugins.format").setup()
	require("config.plugins.lint").setup()
end

return M
