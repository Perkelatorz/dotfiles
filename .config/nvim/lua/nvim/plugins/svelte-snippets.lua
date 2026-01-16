return {
	"nvim-svelte/nvim-svelte-snippets",
	dependencies = {
		"L3MON4D3/LuaSnip",
	},
	config = function()
		local utils = require("nvim.core.utils")
		
		local snippets, snippets_ok = utils.safe_require("nvim-svelte-snippets")
		if not snippets_ok then
			return
		end

		snippets.setup({
			-- Enable all snippet types
			enabled = true,
			
			-- Auto-detect SvelteKit projects (looks for svelte.config.js)
			auto_detect = true,
			
			-- Prefix for TypeScript SvelteKit snippets (e.g., kit-load, kit-action)
			prefix = "kit",
		})

		-- Note: Snippets are automatically loaded into LuaSnip
		-- No additional keybindings needed - they work with your existing completion
	end,
}
