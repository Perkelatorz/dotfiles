-- Flash.nvim: s/S override Vim's "delete char/line and insert" in normal mode.
return {
	"folke/flash.nvim",
	event = "VeryLazy",
	keys = {
		{ "s", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash jump" },
		{ "S", mode = { "n", "x", "o" }, function() require("flash").treesitter() end, desc = "Flash Treesitter" },
		{ "r", mode = "o", function() require("flash").remote() end, desc = "Remote Flash" },
		{ "R", mode = { "o", "x" }, function() require("flash").treesitter_search() end, desc = "Flash Treesitter Search" },
		{ "<Space>", mode = "c", function() require("flash").toggle() end, desc = "Toggle Flash Search" },
	},
	opts = {
		labels = "asdfghjklqwertyuiopzxcvbnm",
		search = { mode = "fuzzy" },
		jump = { autojump = true },
		label = {
			after = true,
			before = true,
			style = "overlay",
			uppercase = true,
		},
		modes = {
			char = {
				enabled = true,
				jump_labels = true,
				multi_line = true,
				label = { exclude = "hjkliardc", before = true, after = true },
			},
		},
	},
}

