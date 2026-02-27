return {
	"Exafunction/codeium.nvim",
	event = "InsertEnter",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"hrsh7th/nvim-cmp",
	},
	config = function()
		local utils = require("nvim.core.utils")
		
		local codeium, codeium_ok = utils.safe_require("codeium")
		if not codeium_ok then
			return
		end

		codeium.setup({
			enable_cmp_source = true,
			enable_chat = true,
			virtual_text = {
				enabled = true,
				manual = false,
				idle_delay = 75,
				filetypes = {},
				default_filetype_enabled = true,
				map_keys = true,
				key_bindings = {
					accept = "<M-y>",
					accept_word = "<M-w>",
					accept_line = "<M-l>",
					clear = "<C-]>",
					next = "<M-]>",
					prev = "<M-[>",
				},
			},
			workspace_root = {
				use_lsp = true,
				find_root = nil,
				paths = {
					".bzr",
					".git",
					".hg",
					".svn",
					"_FOSSIL_",
					"package.json",
				},
			},
		})

		local keymap = vim.keymap
		keymap.set("n", "<leader>aw", "<cmd>Codeium Toggle<cr>", { desc = "Toggle Windsurf/Codeium" })
		keymap.set("n", "<leader>ac", "<cmd>Codeium Chat<cr>", { desc = "Codeium Chat (browser)" })
		keymap.set("n", "<leader>aa", "<cmd>Codeium Auth<cr>", { desc = "Codeium Auth" })
		
		keymap.set("n", "<leader>as", function()
			local status = require('codeium.virtual_text').status()
			local msg = "Windsurf: "
			if status.state == 'idle' then
				msg = msg .. "Idle"
			elseif status.state == 'waiting' then
				msg = msg .. "Waiting for suggestions..."
			elseif status.state == 'completions' and status.total > 0 then
				msg = msg .. string.format("Suggestion %d/%d", status.current, status.total)
			else
				msg = msg .. "No suggestions"
			end
			vim.notify(msg, vim.log.levels.INFO)
		end, { desc = "Windsurf status" })
	end,
}
