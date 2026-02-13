-- Obsidian.nvim: note-taking and vault navigation (Obsidian-style in Neovim)
-- Set your vault path(s) in workspaces below. Requires ripgrep for search.
-- Only loads when the vault directory exists, so no error when you're not using a vault.
local function vault_exists()
	local path = vim.fn.expand("~/vault")
	return vim.fn.isdirectory(path) == 1
end

return {
	"epwalsh/obsidian.nvim",
	version = "*",
	lazy = true,
	ft = "markdown",
	cond = vault_exists, -- don't load when vault is missing
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-telescope/telescope.nvim",
	},
	keys = {
		{ "<leader>on", "<cmd>ObsidianNew<cr>", desc = "Obsidian: New note" },
		{ "<leader>oq", "<cmd>ObsidianQuickSwitch<cr>", desc = "Obsidian: Quick switch" },
		{ "<leader>of", "<cmd>ObsidianFollowLink<cr>", desc = "Obsidian: Follow link" },
		{ "<leader>ob", "<cmd>ObsidianBacklinks<cr>", desc = "Obsidian: Backlinks" },
		{ "<leader>ot", "<cmd>ObsidianToday<cr>", desc = "Obsidian: Today" },
		{ "<leader>od", "<cmd>ObsidianDailies<cr>", desc = "Obsidian: Dailies picker" },
		{ "<leader>os", "<cmd>ObsidianSearch<cr>", desc = "Obsidian: Search vault" },
		{ "<leader>otl", "<cmd>ObsidianTemplate<cr>", desc = "Obsidian: Insert template" },
		{ "<leader>oo", "<cmd>ObsidianOpen<cr>", desc = "Obsidian: Open in app" },
	},
	opts = {
		workspaces = {
			-- Add your vault(s). Example:
			-- { name = "personal", path = "~/vaults/personal" },
			{ name = "main", path = "~/vault" },
		},
		completion = {
			nvim_cmp = true,
			min_chars = 2,
		},
		mappings = {
			["gf"] = {
				action = function()
					return require("obsidian").util.gf_passthrough()
				end,
				opts = { noremap = false, expr = true, buffer = true },
			},
			-- Checkbox: use <leader>oc to avoid conflict with <leader>ch (color highlighter)
			["<leader>oc"] = {
				action = function()
					return require("obsidian").util.toggle_checkbox()
				end,
				opts = { buffer = true },
			},
			["<cr>"] = {
				action = function()
					return require("obsidian").util.smart_action()
				end,
				opts = { buffer = true, expr = true },
			},
		},
		picker = {
			name = "telescope.nvim",
		},
		sort_by = "modified",
		sort_reversed = true,
		open_notes_in = "current",
		preferred_link_style = "wiki",
	},
}
