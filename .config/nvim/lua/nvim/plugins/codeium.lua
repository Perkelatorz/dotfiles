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
			-- Enable nvim-cmp source
			enable_cmp_source = true,
			
			-- Enable chat feature
			enable_chat = true,
			
			-- Virtual text configuration (inline ghost text)
			virtual_text = {
				enabled = true,
				manual = false, -- Auto-trigger completions
				idle_delay = 75, -- ms to wait before requesting
				filetypes = {}, -- Enable for all filetypes
				default_filetype_enabled = true,
				map_keys = true, -- Enable default keybindings
				key_bindings = {
					-- Accept full suggestion: Alt-y (C-y reserved for nvim-cmp confirm in completion menu)
					accept = "<M-y>",
					-- Accept word with Alt-w
					accept_word = "<M-w>",
					-- Accept line with Alt-l
					accept_line = "<M-l>",
					-- Clear with Ctrl-]
					clear = "<C-]>",
					-- Cycle with Alt-] and Alt-[
					next = "<M-]>",
					prev = "<M-[>",
				},
			},
			
			-- Workspace root detection (uses LSP)
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

		-- Additional keymaps for Windsurf/Codeium commands
		local keymap = vim.keymap
		
		-- Using <leader>aw prefix for Windsurf (avoiding conflicts)
		-- w = windsurf/codeium
		keymap.set("n", "<leader>aw", "<cmd>Codeium Toggle<cr>", { desc = "Toggle Windsurf/Codeium" })
		keymap.set("n", "<leader>ac", "<cmd>Codeium Chat<cr>", { desc = "Codeium Chat (browser)" })
		keymap.set("n", "<leader>aa", "<cmd>Codeium Auth<cr>", { desc = "Codeium Auth" })
		
		-- Status command (optional, for statusline integration)
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
