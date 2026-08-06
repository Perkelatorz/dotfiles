--- Popup hints for key sequences; picks up |desc| from |vim.keymap.set| (e.g. LSP, core maps).

local M = {}

function M.setup()
	local wk = require("which-key")
	wk.setup({
		preset = "modern",
		win = { border = "rounded" },
		disable = {
			ft = { "neo-tree", "neo-tree-popup", "neo-tree-preview" },
		},
	})
	wk.add({
		{ "<leader>a", group = "codeium" },
		{ "<leader>c", group = "LSP · Claude · theme" },
		{ "<leader>m", group = "markdown · preview" },
		{ "<leader>k", group = "keys (cheatsheet)" },
		{ "<leader>;", group = "arrow: project bookmarks" },
		{ "<leader>'", group = "arrow: buffer bookmarks" },
		{ "<leader>o", group = "obsidian (notes)" },
		-- Table-mode is a Vimscript plugin and registers its maps without `desc`,
		-- so unlike the Lua plugins its sub-groups have to be labelled by hand.
		{ "<leader>t", group = "tables" },
		{ "<leader>td", group = "table: delete" },
		{ "<leader>tf", group = "table: formula" },
		{ "<leader>ti", group = "table: insert column" },
		{ "<leader>f", group = "find (telescope)" },
		{ "<leader>g", group = "git" },
		{ "<leader>d", group = "diagnostics" },
		{ "<leader>x", group = "trouble / lists" },
		{ "<leader>w", group = "windows" },
		{ "<leader>n", group = "neo-tree" },
		{ "<leader>s", group = "spell" },
		{
			"<leader>?",
			function()
				wk.show({ global = false })
			end,
			desc = "Buffer-local keymaps",
		},
	})

	-- Codeium's ghost-text keys used to be labelled here. They now carry a real `desc`
	-- on the mapping itself (see |config.plugins.codeium|), so which-key picks them up
	-- automatically — and, unlike a which-key-only annotation, they also show up in
	-- Telescope's keymaps picker and `:Keys`. Being single keypresses rather than
	-- prefixes, which-key still never auto-popups for them: browse with `<leader>ka`.
end

return M
