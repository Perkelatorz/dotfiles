return {
	"folke/flash.nvim",
	event = "VeryLazy",
	opts = {
		modes = {
			char = {
				enabled = false, -- Disable char mode by default
			},
		},
	},
	keys = {
		{
			"<leader>j",
			mode = { "n", "x", "o" },
			function()
				require("flash").jump()
			end,
			desc = "Flash jump",
		},
		{
			"<leader>S",
			mode = { "n", "o", "x" },
			function()
				require("flash").treesitter()
			end,
			desc = "Flash Treesitter",
		},
		{
			"r",
			mode = "o",
			function()
				require("flash").remote()
			end,
			desc = "Remote Flash",
		},
		{
			"R",
			mode = { "o", "x" },
			function()
				require("flash").treesitter_search()
			end,
			desc = "Flash Treesitter Search",
		},
		{
			"<c-s>",
			mode = { "c" },
			function()
				require("flash").toggle()
			end,
			desc = "Toggle Flash Search",
		},
	},
	config = function()
		local utils = require("nvim.core.utils")
		
		local flash, flash_ok = utils.safe_require("flash")
		if not flash_ok then
			return
		end

		flash.setup({
			labels = "abcdefghijklmnopqrstuvwxyz",
			search = {
				mode = "fuzzy",
			},
			jump = {
				autojump = true,
			},
		})
	end,
}

