--- Lualine palette from |purpleator_colors|: expressive **mode** strip, quiet middle.

local M = {}

function M.make()
	local c = _G.purpleator_colors
	if not c then
		return "auto"
	end
	local mid = { bg = c.bg1, fg = c.fg2 }
	local trail = { bg = c.bg0, fg = c.fg3 }
	local function accent(fg)
		return { bg = c.bg2, fg = fg, gui = "bold" }
	end
	return {
		normal = {
			a = accent(c.ui0),
			b = mid,
			c = trail,
		},
		insert = {
			a = accent(c.ui_teal),
			b = mid,
			c = trail,
		},
		visual = {
			a = accent(c.purple_lavender),
			b = mid,
			c = trail,
		},
		replace = {
			a = accent(c.string_color),
			b = mid,
			c = trail,
		},
		command = {
			a = accent(c.int_color),
			b = mid,
			c = trail,
		},
		terminal = {
			a = accent(c.type),
			b = mid,
			c = trail,
		},
		inactive = {
			a = { bg = c.bg1, fg = c.ui3, gui = "bold" },
			b = { bg = c.bg0, fg = c.ui3 },
			c = { bg = c.bg0, fg = c.ui3 },
		},
	}
end

return M
