--- |folke/flash.nvim|: labeled jumps, better |f|/|t|, Treesitter targets. Defaults from plugin README.
---
--- Deliberately a *superset* of the built-ins: |f| |F| |t| |T| still take a character and
--- move exactly where Vim would, and |;| / |,| still repeat that motion forward/backward
--- (flash's char mode owns all six keys). Only the jump labels are new, so nothing has to
--- be unlearned. Arrow used to steal |;| for its menu, which silently broke repeat-f/t;
--- it now lives on <leader>; (see |config.plugins.arrow|).
---
--- The one real replacement is |s| / |S| (Vim's substitute char/line). Vim equivalents:
--- |cl| for |s|, |cc| for |S|.

local M = {}

function M.setup()
	require("flash").setup({
		modes = {
			-- Label matches while searching with |/| and |?| (toggle in cmdline with <C-s> per mapping below).
			search = {
				enabled = true,
			},
		},
	})

	vim.keymap.set({ "n", "x", "o" }, "s", function()
		require("flash").jump()
	end, { desc = "Flash jump" })

	vim.keymap.set({ "n", "x", "o" }, "S", function()
		require("flash").treesitter()
	end, { desc = "Flash Treesitter" })

	vim.keymap.set("o", "r", function()
		require("flash").remote()
	end, { desc = "Flash remote" })

	vim.keymap.set({ "o", "x" }, "R", function()
		require("flash").treesitter_search()
	end, { desc = "Flash Treesitter search" })

	vim.keymap.set("c", "<C-s>", function()
		require("flash").toggle()
	end, { desc = "Flash toggle search" })
end

return M
