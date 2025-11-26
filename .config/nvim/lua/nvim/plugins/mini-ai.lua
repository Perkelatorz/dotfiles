return {
	"echasnovski/mini.ai",
	event = "VeryLazy",
	dependencies = {
		"nvim-treesitter/nvim-treesitter-textobjects",
	},
	config = function()
		local utils = require("nvim.core.utils")
		
		local ai, ai_ok = utils.safe_require("mini.ai")
		if not ai_ok then
			return
		end

		-- Only add custom textobjects that treesitter doesn't provide by default
		-- Treesitter already provides: af/if (function), ac/ic (class), aa/ia (parameter)
		ai.setup({
			custom_textobjects = {
				-- Add 'o' for block/conditional/loop (not in treesitter by default)
				o = ai.gen_spec.treesitter({
					a = { "@block.outer", "@conditional.outer", "@loop.outer" },
					i = { "@block.inner", "@conditional.inner", "@loop.inner" },
				}, {}),
			},
		})

	end,
}

