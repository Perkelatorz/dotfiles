--- Sample Lua buffer: lua_ls + Tree-sitter + Stylua on save.
local M = {}

function M.hello(name)
	name = name or "nvim"
	return ("Hello, %s!"):format(name)
end

return M
