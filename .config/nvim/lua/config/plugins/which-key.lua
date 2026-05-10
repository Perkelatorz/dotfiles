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
		{ "<leader>t", group = "terminal" },
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
end

return M
