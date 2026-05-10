require("config.core.options")
require("config.core.spell").setup()
require("config.core.docs").setup({
	-- Zeal: docset name must match an installed docset (Zeal sidebar). If `svelte:…` fails, try:
	-- zeal_docsets = { svelte = "Svelte" },
})
require("config.core.keymaps")
require("config.core.autocmds")
require("config.core.colorscheme").setup()
