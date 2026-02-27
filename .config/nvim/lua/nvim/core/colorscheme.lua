local M = {}

local current_theme = "custom" -- "custom" or "nightfox"

function M.setup()
	local utils = require("nvim.core.utils")

	local colors = {
		bg0 = "#1a1420",
		bg1 = "#261e30",
		bg2 = "#342c42",
		bg3 = "#4a4060",
		fg0 = "#ede9e4",
		fg1 = "#ddd8d0",
		fg2 = "#bdb8ca",
		fg3 = "#918c9c",

		control  = "#ad9bef",
		purple_lavender = "#c8b5f0",
		purple_mauve   = "#9680b8",
		comment  = "#8b95a5",

		callable = "#e4c85a",
		type     = "#5ee0d6",
		string_color = "#f0a060",
		int_color    = "#90c8f0",
		float_color  = "#80e0aa",

		match_paren = "#f06868",

		error = "#f09090",
		warn  = "#e4c85a",
		attention = "#e4c85a",

		ui0 = "#ad9bef",
		ui1 = "#c8b5f0",
		ui2 = "#8e849c",
		ui3 = "#605678",
		ui_teal = "#5ee0d6",
		ui_gold = "#e4c85a",

		bool = "#f07898",
		constant = "#d0b878",

		ghost = "#8a847e",
		operator = "#9ca0b0",
	}

	_G.purpleator_colors = colors

	vim.opt.background = "dark"

	vim.api.nvim_set_hl(0, "Normal", { fg = colors.fg0, bg = colors.bg0 })
	vim.api.nvim_set_hl(0, "NormalFloat", { fg = colors.fg0, bg = colors.bg1 })
	vim.api.nvim_set_hl(0, "NormalNC", { fg = colors.fg2, bg = colors.bg0 })
	vim.api.nvim_set_hl(0, "FloatBorder", { fg = colors.ui1, bg = colors.bg1 })
	vim.api.nvim_set_hl(0, "FloatTitle", { fg = colors.control, bg = colors.bg1, bold = true })

	vim.api.nvim_set_hl(0, "CursorLine", { bg = colors.bg1, bold = false })
	vim.api.nvim_set_hl(0, "CursorLineNr", { fg = colors.ui0, bg = colors.bg1, bold = true })
	vim.api.nvim_set_hl(0, "LineNr", { fg = colors.ui2, bg = colors.bg0 })
	vim.api.nvim_set_hl(0, "Cursor", { fg = colors.bg0, bg = colors.fg0 })

	vim.api.nvim_set_hl(0, "SignColumn", { bg = colors.bg0 })
	vim.api.nvim_set_hl(0, "ColorColumn", { bg = colors.bg1 })

	vim.api.nvim_set_hl(0, "WinSeparator", { fg = colors.ui_teal, bold = false })

	vim.api.nvim_set_hl(0, "IndentBlanklineIndent1", { fg = colors.ui3, nocombine = true })
	vim.api.nvim_set_hl(0, "IndentBlanklineIndent2", { fg = colors.ui_teal, nocombine = true })

	vim.api.nvim_set_hl(0, "Visual", { bg = colors.bg3, bold = false })
	vim.api.nvim_set_hl(0, "VisualNOS", { bg = colors.bg2, bold = false })

	vim.api.nvim_set_hl(0, "Search", { fg = colors.fg0, bg = colors.bg3 })
	vim.api.nvim_set_hl(0, "IncSearch", { fg = colors.bg0, bg = colors.callable, bold = true })
	vim.api.nvim_set_hl(0, "CurSearch", { fg = colors.bg0, bg = colors.callable, bold = true })

	vim.api.nvim_set_hl(0, "MatchParen", { fg = colors.match_paren, bg = "NONE", bold = true, underline = true })

	vim.api.nvim_set_hl(0, "Function", { fg = colors.callable, bold = true })
	vim.api.nvim_set_hl(0, "@function", { fg = colors.callable, bold = true })
	vim.api.nvim_set_hl(0, "@function.call", { fg = colors.callable, bold = false })
	vim.api.nvim_set_hl(0, "@function.method", { fg = colors.callable, bold = true })
	vim.api.nvim_set_hl(0, "@function.method.call", { fg = colors.callable, bold = false })
	vim.api.nvim_set_hl(0, "@function.builtin", { fg = colors.type, bold = false })

	vim.api.nvim_set_hl(0, "Keyword", { fg = colors.control, bold = true })
	vim.api.nvim_set_hl(0, "@keyword", { fg = colors.control, bold = true })
	vim.api.nvim_set_hl(0, "@keyword.function", { fg = colors.control, bold = true })
	vim.api.nvim_set_hl(0, "@keyword.return", { fg = colors.control, bold = true })
	vim.api.nvim_set_hl(0, "@keyword.operator", { fg = colors.control, bold = true })
	vim.api.nvim_set_hl(0, "@conditional", { fg = colors.control, bold = true })
	vim.api.nvim_set_hl(0, "@repeat", { fg = colors.control, bold = true })

	vim.api.nvim_set_hl(0, "String", { fg = colors.string_color, bold = false })
	vim.api.nvim_set_hl(0, "@string", { fg = colors.string_color, bold = false })
	vim.api.nvim_set_hl(0, "@string.regex", { fg = colors.string_color, bold = false })
	vim.api.nvim_set_hl(0, "@string.escape", { fg = colors.string_color, bold = false })

	vim.api.nvim_set_hl(0, "Comment", { fg = colors.comment, italic = true, bold = false })
	vim.api.nvim_set_hl(0, "@comment", { fg = colors.comment, italic = true, bold = false })

	vim.api.nvim_set_hl(0, "Todo", { fg = colors.attention, bold = true, italic = false })
	vim.api.nvim_set_hl(0, "TodoFgFix", { fg = colors.error, bold = true })
	vim.api.nvim_set_hl(0, "TodoFgTodo", { fg = colors.attention, bold = true })
	vim.api.nvim_set_hl(0, "TodoFgNote", { fg = colors.type, bold = true })
	vim.api.nvim_set_hl(0, "TodoFgWarning", { fg = colors.warn, bold = true })
	vim.api.nvim_set_hl(0, "TodoFgTest", { fg = colors.callable, bold = true })
	vim.api.nvim_set_hl(0, "TodoBgFix", { fg = colors.error })
	vim.api.nvim_set_hl(0, "TodoBgTodo", { fg = colors.attention })
	vim.api.nvim_set_hl(0, "TodoBgNote", { fg = colors.type })
	vim.api.nvim_set_hl(0, "TodoBgWarning", { fg = colors.warn })
	vim.api.nvim_set_hl(0, "TodoBgTest", { fg = colors.callable })

	vim.api.nvim_set_hl(0, "@string.documentation", { fg = colors.fg3, italic = true, bold = false })
	vim.api.nvim_set_hl(0, "@string.documentation.python", { fg = colors.fg3, italic = true, bold = false })
	vim.api.nvim_set_hl(0, "@comment.documentation", { fg = colors.fg3, italic = true, bold = false })

	vim.api.nvim_set_hl(0, "Number", { fg = colors.int_color, bold = false })
	vim.api.nvim_set_hl(0, "@number", { fg = colors.int_color, bold = false })
	vim.api.nvim_set_hl(0, "@float", { fg = colors.float_color, bold = false })

	vim.api.nvim_set_hl(0, "Boolean", { fg = colors.bool })
	vim.api.nvim_set_hl(0, "@boolean", { fg = colors.bool })
	
	vim.api.nvim_set_hl(0, "@property", { fg = colors.fg1, bold = false })
	vim.api.nvim_set_hl(0, "@field", { fg = colors.fg1, bold = false })
	vim.api.nvim_set_hl(0, "@parameter", { fg = colors.fg2, bold = false })
	vim.api.nvim_set_hl(0, "@namespace", { fg = colors.purple_lavender, bold = false })
	vim.api.nvim_set_hl(0, "@label", { fg = colors.fg2, bold = false })
	vim.api.nvim_set_hl(0, "@tag", { fg = colors.purple_mauve, bold = false })
	vim.api.nvim_set_hl(0, "@tag.attribute", { fg = colors.fg1, bold = false })
	vim.api.nvim_set_hl(0, "@tag.delimiter", { fg = colors.fg3, bold = false })

	vim.api.nvim_set_hl(0, "Operator", { fg = colors.operator, bold = false })
	vim.api.nvim_set_hl(0, "@operator", { fg = colors.operator, bold = false })
	vim.api.nvim_set_hl(0, "@operator.assignment", { fg = colors.operator, bold = false })
	vim.api.nvim_set_hl(0, "@operator.comparison", { fg = colors.operator, bold = false })
	vim.api.nvim_set_hl(0, "@operator.arithmetic", { fg = colors.operator, bold = false })
	vim.api.nvim_set_hl(0, "@operator.logical", { fg = colors.operator, bold = false })
	vim.api.nvim_set_hl(0, "@operator.python", { fg = colors.operator, bold = false })

	vim.api.nvim_set_hl(0, "Identifier", { fg = colors.fg1, bold = false })
	vim.api.nvim_set_hl(0, "@variable", { fg = colors.fg1, bold = false })
	vim.api.nvim_set_hl(0, "@variable.builtin", { fg = colors.type, bold = false })
	vim.api.nvim_set_hl(0, "@variable.parameter", { fg = colors.fg2, bold = false })
	vim.api.nvim_set_hl(0, "@variable.member", { fg = colors.fg1, bold = false })
	vim.api.nvim_set_hl(0, "@variable.python", { fg = colors.fg1, bold = false })

	vim.api.nvim_set_hl(0, "Type", { fg = colors.type })
	vim.api.nvim_set_hl(0, "@type", { fg = colors.type })
	vim.api.nvim_set_hl(0, "@type.builtin", { fg = colors.type })
	vim.api.nvim_set_hl(0, "@type.definition", { fg = colors.type })
	vim.api.nvim_set_hl(0, "@class", { fg = colors.type })
	vim.api.nvim_set_hl(0, "@class.definition", { fg = colors.type })

	vim.api.nvim_set_hl(0, "Constant", { fg = colors.constant })
	vim.api.nvim_set_hl(0, "@constant", { fg = colors.constant })
	vim.api.nvim_set_hl(0, "@constant.builtin", { fg = colors.constant })
	vim.api.nvim_set_hl(0, "@constant.macro", { fg = colors.constant })

	vim.api.nvim_set_hl(0, "@punctuation.bracket", { fg = colors.operator, bold = false })
	vim.api.nvim_set_hl(0, "@punctuation.delimiter", { fg = colors.operator, bold = false })
	vim.api.nvim_set_hl(0, "@punctuation.special", { fg = colors.fg2, bold = false })
	vim.api.nvim_set_hl(0, "@punctuation", { fg = colors.operator, bold = false })

	vim.api.nvim_set_hl(0, "PreProc", { fg = colors.error })
	vim.api.nvim_set_hl(0, "@preproc", { fg = colors.error })

	vim.api.nvim_set_hl(0, "@attribute", { fg = colors.control, italic = true })
	vim.api.nvim_set_hl(0, "@attribute.python", { fg = colors.control, italic = true })

	vim.api.nvim_set_hl(0, "@markup.link", { fg = colors.type, underline = true })
	vim.api.nvim_set_hl(0, "@markup.link.url", { fg = colors.string_color, underline = true })
	vim.api.nvim_set_hl(0, "markdownUrl", { fg = colors.string_color, underline = true })

	-- Spell and trailing whitespace (so they’re visible)
	vim.api.nvim_set_hl(0, "SpellBad", { sp = colors.error, underline = true })
	vim.api.nvim_set_hl(0, "SpellCap", { sp = colors.warn, underline = true })
	vim.api.nvim_set_hl(0, "SpellRare", { sp = colors.type, underline = true })
	vim.api.nvim_set_hl(0, "Whitespace", { fg = colors.fg3, nocombine = true })
	vim.api.nvim_set_hl(0, "TrailingWhitespace", { fg = colors.error, nocombine = true })

	vim.api.nvim_set_hl(0, "Special", { fg = colors.control, bold = false })
	vim.api.nvim_set_hl(0, "@special", { fg = colors.control, bold = false })
	vim.api.nvim_set_hl(0, "@symbol", { fg = colors.control, bold = false })

	vim.api.nvim_set_hl(0, "Title", { fg = colors.control, bold = true })
	vim.api.nvim_set_hl(0, "Underlined", { fg = colors.type, underline = true })
	vim.api.nvim_set_hl(0, "NonText", { fg = colors.ui3 })
	vim.api.nvim_set_hl(0, "Question", { fg = colors.callable, bold = true })
	vim.api.nvim_set_hl(0, "MoreMsg", { fg = colors.type, bold = false })
	vim.api.nvim_set_hl(0, "Directory", { fg = colors.ui1, bold = false })
	vim.api.nvim_set_hl(0, "WildMenu", { fg = colors.fg0, bg = colors.ui1, bold = false })

	vim.api.nvim_set_hl(0, "StatusLine", { fg = colors.ui0, bg = colors.bg1, bold = false })
	vim.api.nvim_set_hl(0, "StatusLineNC", { fg = colors.ui2, bg = colors.bg0, bold = false })
	vim.api.nvim_set_hl(0, "StatusLineTerm", { fg = colors.ui0, bg = colors.bg1, bold = false })
	vim.api.nvim_set_hl(0, "StatusLineTermNC", { fg = colors.ui2, bg = colors.bg0, bold = false })

	vim.api.nvim_set_hl(0, "TabLine", { fg = colors.ui2, bg = colors.bg1, bold = false })
	vim.api.nvim_set_hl(0, "TabLineFill", { fg = colors.ui2, bg = colors.bg0, bold = false })
	vim.api.nvim_set_hl(0, "TabLineSel", { fg = colors.ui_gold, bg = colors.bg2, bold = true })

	vim.api.nvim_set_hl(0, "DiagnosticError", { fg = colors.error, bold = false })
	vim.api.nvim_set_hl(0, "DiagnosticWarn", { fg = colors.warn, bold = false })
	vim.api.nvim_set_hl(0, "DiagnosticInfo", { fg = colors.type, bold = false })
	vim.api.nvim_set_hl(0, "DiagnosticHint", { fg = colors.type, bold = false })
	vim.api.nvim_set_hl(0, "DiagnosticUnderlineError", { sp = colors.error, underline = true })
	vim.api.nvim_set_hl(0, "DiagnosticUnderlineWarn", { sp = colors.warn, underline = true })
	vim.api.nvim_set_hl(0, "DiagnosticUnderlineInfo", { sp = colors.type, underline = true })
	vim.api.nvim_set_hl(0, "DiagnosticUnderlineHint", { sp = colors.type, underline = true })

	vim.api.nvim_set_hl(0, "DiagnosticSignError", { fg = colors.error, bg = colors.bg0, bold = false })
	vim.api.nvim_set_hl(0, "DiagnosticSignWarn", { fg = colors.warn, bg = colors.bg0, bold = false })
	vim.api.nvim_set_hl(0, "DiagnosticSignInfo", { fg = colors.type, bg = colors.bg0, bold = false })
	vim.api.nvim_set_hl(0, "DiagnosticSignHint", { fg = colors.type, bg = colors.bg0, bold = false })

	vim.api.nvim_set_hl(0, "AlphaHeader", { fg = colors.control, bold = true })
	vim.api.nvim_set_hl(0, "AlphaButton", { fg = colors.fg1, bold = false })
	vim.api.nvim_set_hl(0, "AlphaShortcut", { fg = colors.callable, bold = false })
	vim.api.nvim_set_hl(0, "AlphaFooter", { fg = colors.fg3, italic = true })

	vim.api.nvim_set_hl(0, "TelescopePromptPrefix", { fg = colors.control, bold = false })
	vim.api.nvim_set_hl(0, "TelescopeSelection", { fg = colors.fg0, bg = colors.bg3, bold = false })
	vim.api.nvim_set_hl(0, "TelescopeMatching", { fg = colors.callable, bold = false })
	vim.api.nvim_set_hl(0, "TelescopePrompt", { fg = colors.fg0, bg = colors.bg1 })
	vim.api.nvim_set_hl(0, "TelescopeResults", { fg = colors.fg0, bg = colors.bg1 })
	vim.api.nvim_set_hl(0, "TelescopePreview", { fg = colors.fg0, bg = colors.bg1 })
	vim.api.nvim_set_hl(0, "TelescopeBorder", { fg = colors.ui1, bg = colors.bg1 })
	vim.api.nvim_set_hl(0, "TelescopeTitle", { fg = colors.control, bg = colors.bg1, bold = true })

	vim.api.nvim_set_hl(0, "LspReferenceText", { bg = colors.bg2, bold = false })
	vim.api.nvim_set_hl(0, "LspReferenceRead", { bg = colors.bg2, bold = false })
	vim.api.nvim_set_hl(0, "LspReferenceWrite", { bg = colors.bg2, bold = false })
	vim.api.nvim_set_hl(0, "LspInlayHint", { fg = colors.ghost, italic = true })
	vim.api.nvim_set_hl(0, "CodeiumSuggestion", { fg = colors.ghost, italic = true })

	vim.api.nvim_set_hl(0, "DiffAdd", { fg = colors.comment, bg = "NONE", bold = false })
	vim.api.nvim_set_hl(0, "DiffChange", { fg = colors.warn, bg = "NONE", bold = false })
	vim.api.nvim_set_hl(0, "DiffDelete", { fg = colors.error, bg = "NONE", bold = false })
	vim.api.nvim_set_hl(0, "DiffText", { fg = colors.fg0, bg = colors.bg2, bold = false })

	vim.api.nvim_set_hl(0, "GitSignsAdd", { fg = colors.comment, bg = colors.bg0, bold = false })
	vim.api.nvim_set_hl(0, "GitSignsChange", { fg = colors.warn, bg = colors.bg0, bold = false })
	vim.api.nvim_set_hl(0, "GitSignsDelete", { fg = colors.error, bg = colors.bg0, bold = false })

	vim.api.nvim_set_hl(0, "Folded", { fg = colors.ui1, bg = colors.bg1, bold = false })
	vim.api.nvim_set_hl(0, "FoldColumn", { fg = colors.ui2, bg = colors.bg0, bold = false })

	vim.api.nvim_set_hl(0, "Pmenu", { fg = colors.fg0, bg = colors.bg2, bold = false })
	vim.api.nvim_set_hl(0, "PmenuSel", { fg = colors.fg0, bg = colors.bg3, bold = false })
	vim.api.nvim_set_hl(0, "PmenuSbar", { bg = colors.bg1, bold = false })
	vim.api.nvim_set_hl(0, "PmenuThumb", { bg = colors.bg3, bold = false })

	vim.api.nvim_set_hl(0, "CmpItemAbbr", { fg = colors.fg0, bold = false })
	vim.api.nvim_set_hl(0, "CmpItemAbbrMatch", { fg = colors.callable, bold = true })
	vim.api.nvim_set_hl(0, "CmpItemKind", { fg = colors.control, bold = false })
	vim.api.nvim_set_hl(0, "CmpItemMenu", { fg = colors.ui1, bold = false })

	vim.api.nvim_set_hl(0, "WhichKey", { fg = colors.callable, bold = true })
	vim.api.nvim_set_hl(0, "WhichKeyGroup", { fg = colors.purple_lavender, bold = false })
	vim.api.nvim_set_hl(0, "WhichKeySeparator", { fg = colors.bg3, bold = false })
	vim.api.nvim_set_hl(0, "WhichKeyDesc", { fg = colors.fg1, bold = false })
	vim.api.nvim_set_hl(0, "WhichKeyValue", { fg = colors.type, bold = false })
	vim.api.nvim_set_hl(0, "WhichKeyFloat", { bg = colors.bg1 })
	vim.api.nvim_set_hl(0, "WhichKeyNormal", { fg = colors.fg0, bg = colors.bg1 })
	vim.api.nvim_set_hl(0, "WhichKeyBorder", { fg = colors.bg3, bg = colors.bg1 })
	vim.api.nvim_set_hl(0, "WhichKeyTitle", { fg = colors.control, bg = colors.bg1, bold = true })

	vim.api.nvim_set_hl(0, "NvimTreeNormal", { fg = colors.fg0, bg = colors.bg0, bold = false })
	vim.api.nvim_set_hl(0, "NvimTreeNormalNC", { fg = colors.fg2, bg = colors.bg0, bold = false })
	vim.api.nvim_set_hl(0, "NvimTreeRootFolder", { fg = colors.control, bold = true })
	vim.api.nvim_set_hl(0, "NvimTreeFolderIcon", { fg = colors.ui1, bold = false })
	vim.api.nvim_set_hl(0, "NvimTreeOpenedFolderName", { fg = colors.ui0, bold = true })
	vim.api.nvim_set_hl(0, "NvimTreeClosedFolderName", { fg = colors.ui1, bold = false })

	vim.api.nvim_set_hl(0, "NotifyERRORBorder", { fg = colors.error, bold = false })
	vim.api.nvim_set_hl(0, "NotifyWARNBorder", { fg = colors.warn, bold = false })
	vim.api.nvim_set_hl(0, "NotifyINFOBorder", { fg = colors.type, bold = false })
	vim.api.nvim_set_hl(0, "NotifyDEBUGBorder", { fg = colors.ui1, bold = false })
	vim.api.nvim_set_hl(0, "NotifyTRACEBorder", { fg = colors.control, bold = false })

	vim.api.nvim_set_hl(0, "TroubleText", { fg = colors.fg0, bold = false })
	vim.api.nvim_set_hl(0, "TroubleCount", { fg = colors.control, bold = false })
	vim.api.nvim_set_hl(0, "TroubleNormal", { fg = colors.fg0, bg = colors.bg0, bold = false })

	vim.api.nvim_set_hl(0, "FlashLabel", { fg = colors.bg0, bg = colors.callable, bold = true })
	vim.api.nvim_set_hl(0, "FlashCurrent", { fg = colors.bg0, bg = colors.type, bold = true })
	vim.api.nvim_set_hl(0, "FlashMatch", { fg = colors.callable, bg = colors.bg2, bold = true })
	vim.api.nvim_set_hl(0, "FlashBackdrop", { fg = colors.fg3, bg = "NONE" })
	vim.api.nvim_set_hl(0, "FlashPromptIcon", { fg = colors.callable, bold = true })
	vim.api.nvim_set_hl(0, "FlashPrompt", { fg = colors.fg0, bg = colors.bg1 })
	vim.api.nvim_set_hl(0, "FlashPromptBorder", { fg = colors.bg3, bg = colors.bg1 })

	vim.g.terminal_color_0 = colors.bg0
	vim.g.terminal_color_1 = colors.error
	vim.g.terminal_color_2 = colors.comment
	vim.g.terminal_color_3 = colors.callable
	vim.g.terminal_color_4 = colors.comment
	vim.g.terminal_color_5 = colors.control
	vim.g.terminal_color_6 = colors.type
	vim.g.terminal_color_7 = colors.fg0
	vim.g.terminal_color_8 = colors.ui2
	vim.g.terminal_color_9 = colors.error
	vim.g.terminal_color_10 = colors.comment
	vim.g.terminal_color_11 = colors.string_color
	vim.g.terminal_color_12 = colors.comment
	vim.g.terminal_color_13 = colors.control
	vim.g.terminal_color_14 = colors.type
	vim.g.terminal_color_15 = colors.fg0

	local trail_ns = vim.api.nvim_create_namespace("trailing_whitespace")
	vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI", "BufEnter" }, {
		callback = function()
			local bufnr = vim.api.nvim_get_current_buf()
			local row = vim.api.nvim_win_get_cursor(0)[1] - 1
			vim.api.nvim_buf_clear_namespace(bufnr, trail_ns, 0, -1)
			local line = vim.api.nvim_buf_get_lines(bufnr, row, row + 1, false)[1]
			if line then
				local start_col = line:match("^.*()%s+$")
				if start_col then
					vim.api.nvim_buf_add_highlight(bufnr, trail_ns, "TrailingWhitespace", row, start_col - 1, -1)
				end
			end
		end,
		desc = "Highlight trailing whitespace on current line",
	})
end

function M.apply_custom()
	current_theme = "custom"
	M.setup()
	vim.notify("Colorscheme: Purpleator", vim.log.levels.INFO)
end

function M.apply_nightfox()
	current_theme = "nightfox"
	local nightfox_ok, _ = pcall(require, "nightfox")
	if not nightfox_ok then
		vim.notify("Nightfox not installed. Run :Lazy to install plugins.", vim.log.levels.WARN)
		return
	end
	vim.cmd("colorscheme nightfox")
	vim.notify("Colorscheme: Nightfox", vim.log.levels.INFO)
end

function M.toggle()
	if current_theme == "custom" then
		M.apply_nightfox()
	else
		M.apply_custom()
	end
end

function M.get_current()
	return current_theme
end

vim.api.nvim_create_user_command("ColorschemeCustom", M.apply_custom, {
	desc = "Switch to custom Purpleator colorscheme",
})

vim.api.nvim_create_user_command("ColorschemeNightfox", M.apply_nightfox, {
	desc = "Switch to Nightfox colorscheme",
})

vim.api.nvim_create_user_command("ColorschemeToggle", M.toggle, {
	desc = "Toggle between custom and Nightfox colorscheme",
})

return M
