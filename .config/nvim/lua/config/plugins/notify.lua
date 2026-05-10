--- Toast-style |vim.notify|; load first so other plugins use it.
--- Mason + mason-tool-installer emit two INFO toasts per package; we keep ERROR/WARN and one CLI summary (|config.plugins.mason|).

local M = {}

---@param msg string|nil
---@param level? integer
---@param opts? table
---@return boolean
local function mute_mason_chatter(msg, level, opts)
	if type(msg) ~= "string" then
		return false
	end
	if level ~= vim.log.levels.INFO then
		return false
	end
	local title = type(opts) == "table" and opts.title or ""
	if title == "mason-tool-installer" then
		if msg:find("successfully installed", 1, true) or msg:find(": installing", 1, true) or msg:find(": updating to", 1, true) then
			return true
		end
	end
	if title == "mason-lspconfig.nvim" then
		if msg:find("successfully installed", 1, true) or msg:find("installing ", 1, true) then
			return true
		end
	end
	return false
end

function M.setup()
	local notify = require("notify")
	local bg = (_G.purpleator_colors and _G.purpleator_colors.bg1) or "#261e30"
	notify.setup({
		stages = "fade_in_slide_out",
		timeout = 3200,
		fps = 60,
		background_colour = bg,
		max_height = function()
			return math.floor(vim.o.lines * 0.35)
		end,
		max_width = function()
			return math.floor(vim.o.columns * 0.42)
		end,
	})
	vim.notify = function(msg, level, opts)
		if mute_mason_chatter(msg, level, opts) then
			return
		end
		return notify(msg, level, opts)
	end
end

return M
