-- Enable faster Lua module loading (Neovim 0.9+)
if vim.loader then
  vim.loader.enable()
end

require("nvim.core")
require("nvim.lazy")
