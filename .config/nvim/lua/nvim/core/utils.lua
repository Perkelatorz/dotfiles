-- Utility functions for the Neovim configuration
local M = {}

--- Safely require a module with error handling
---@param module string Module name to require
---@return table|nil module The required module or nil if failed
---@return boolean success Whether the require was successful
function M.safe_require(module)
  local ok, result = pcall(require, module)
  if not ok then
    vim.notify("Failed to load module: " .. module, vim.log.levels.WARN)
    return nil, false
  end
  return result, true
end

--- Check if a module is available
---@param module string Module name to check
---@return boolean available Whether the module is available
function M.is_available(module)
  local ok, _ = pcall(require, module)
  return ok
end

--- Create a keymap with error handling
---@param mode string|table Vim mode(s)
---@param lhs string Left-hand side (key combination)
---@param rhs string|function Right-hand side (command or function)
---@param opts table|nil Options table
function M.map(mode, lhs, rhs, opts)
  opts = opts or {}
  opts.desc = opts.desc or ""
  vim.keymap.set(mode, lhs, rhs, opts)
end

--- Create a buffer-local keymap with error handling
---@param mode string|table Vim mode(s)
---@param lhs string Left-hand side (key combination)
---@param rhs string|function Right-hand side (command or function)
---@param opts table|nil Options table
---@param bufnr number|nil Buffer number (defaults to current buffer)
function M.buf_map(mode, lhs, rhs, opts, bufnr)
  opts = opts or {}
  opts.buffer = bufnr or 0
  opts.desc = opts.desc or ""
  vim.keymap.set(mode, lhs, rhs, opts)
end

return M

