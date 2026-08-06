-- Enable faster Lua module loading (Neovim 0.9+)
if vim.loader then
	vim.loader.enable()
end

require("config.core")
require("config.pack_hooks").register()
-- vim-table-mode is Vimscript: it binds its mappings when vim.pack sources it below,
-- reading g:table_mode_* at that moment. These must therefore be set first.
require("config.plugins.table_mode").prelude()
require("config.pack").setup()
require("config.plugins").setup()
