-- Enable faster Lua module loading (Neovim 0.9+)
if vim.loader then
	vim.loader.enable()
end

require("config.core")
require("config.pack_hooks").register()
require("config.pack").setup()
require("config.plugins").setup()
