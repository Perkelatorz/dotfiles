--- |folke/flash.nvim|: labeled jumps, better |f|/|t|, Treesitter targets. Defaults from plugin README.
--- Replaces |s| / |S| (substitute char/line); use |cl| or |cc| for single-line edits if needed.
--- Note: Arrow uses |;| for its menu, so |;| repeat after |f|/|t| may not behave like stock Vim/Flash;
--- |f|/|t| labels and |/| search labels still work. Change Arrow |leader_key| if you need |;| for motions.

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
