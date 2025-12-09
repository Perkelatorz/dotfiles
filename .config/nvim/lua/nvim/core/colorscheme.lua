-- Fully custom colorscheme - Purpleator
-- All colors defined here for complete control
-- Can switch to nightfox with :ColorschemeToggle or <leader>ct

local M = {}

-- Current theme state
local current_theme = "custom" -- "custom" or "nightfox"

function M.setup()
	local utils = require("nvim.core.utils")

	-- Color palette - Purpleator theme with purple undertones
	-- Syntax colors use numeric names (color0-color16) so you can change colors without updating variable names
	local colors = {
		-- Base colors - purple undertone backgrounds (Purpleator theme)
		bg0 = "#1a1420", -- Deep purple-black background
		bg1 = "#251d2e", -- Lighter purple (more contrast from bg0)
		bg2 = "#30283c", -- Even lighter purple (more contrast from bg1)
		bg3 = "#3d344a", -- Borders/separators (purple tint, more visible)
		fg0 = "#f0f0f0", -- Base text (bright white-gray) - kept same
		fg1 = "#d8d8d8", -- Secondary text (more contrast from fg0) - kept same
		fg2 = "#c0c0c0", -- Tertiary text (more contrast from fg1) - kept same
		fg3 = "#a8a8a8", -- Dimmed text (more contrast from fg2) - kept same

		-- Syntax colors - bright, high contrast (numeric names for easy changes)
		color0 = "#d87070", -- Errors (muted red)
		color1 = "#6eb03b", -- Comments, hints (bright green)
		color2 = "#9acf9a", -- Strings (light green)
		color3 = "#5a9a8a", -- Classes, types (night evergreen)
		color4 = "#9982d1", -- Keywords, constants (muted purple)
		color5 = "#dd6a18", -- Numbers, warnings (Clemson orange)
		color6 = "#FFD343", -- Functions (Python yellow - official Python logo color) - for function calls
		color7 = "#fff600", -- Brighter yellow for function definitions
		color8 = "#fffb6e", -- Operators (bright lime-yellow green)
		color9 = "#d067d0", -- Symbols (bright magenta)
		color10 = "#77c8c8", -- Variables, builtins, info (softer cyan, easier on eyes)
		color11 = "#5a7ab8", -- Brackets (more blue, less gray - distinct from builtins)
		color12 = "#14b8b8", -- Punctuation (bright cyan - very visible, high contrast)

		-- UI colors (follow bg/fg pattern)
		ui0 = "#b0b0b0", -- gray_light
		ui1 = "#808080", -- gray_medium
		ui2 = "#505050", -- gray_dark
		ui3 = "#404040", -- gray_darker
	}

	-- Export colors globally for other tools to use
	_G.purpleator_colors = colors
	-- Keep old name for backwards compatibility
	_G.alabaster_colors = colors

	-- Set background
	vim.opt.background = "dark"

	-- Base highlights
	vim.api.nvim_set_hl(0, "Normal", { fg = colors.fg0, bg = colors.bg0 })
	vim.api.nvim_set_hl(0, "NormalFloat", { fg = colors.fg0, bg = colors.bg0 })
	vim.api.nvim_set_hl(0, "NormalNC", { fg = colors.fg2, bg = colors.bg0 })

	-- Cursor and line numbers
	vim.api.nvim_set_hl(0, "CursorLine", { bg = colors.bg1, bold = false })
	vim.api.nvim_set_hl(0, "CursorLineNr", { fg = colors.ui0, bg = colors.bg1, bold = true })
	vim.api.nvim_set_hl(0, "LineNr", { fg = colors.ui2, bg = colors.bg0 })
	vim.api.nvim_set_hl(0, "Cursor", { fg = colors.bg0, bg = colors.fg0 })

	-- Sign column and color column
	vim.api.nvim_set_hl(0, "SignColumn", { bg = colors.bg0 })
	vim.api.nvim_set_hl(0, "ColorColumn", { bg = colors.bg1 })

	-- Window separator
	vim.api.nvim_set_hl(0, "WinSeparator", { fg = colors.ui3, bold = false })

	-- Indent guides (set early for indent-blankline)
	vim.api.nvim_set_hl(0, "IndentBlanklineIndent1", { fg = colors.bg3, nocombine = true })
	vim.api.nvim_set_hl(0, "IndentBlanklineIndent2", { fg = colors.bg2, nocombine = true })

	-- Selection
	vim.api.nvim_set_hl(0, "Visual", { bg = colors.bg3, bold = false })
	vim.api.nvim_set_hl(0, "VisualNOS", { bg = colors.bg2, bold = false })

	-- Search
	vim.api.nvim_set_hl(0, "Search", { fg = colors.fg0, bg = colors.bg2 })
	vim.api.nvim_set_hl(0, "IncSearch", { fg = colors.fg0, bg = colors.bg3 })
	vim.api.nvim_set_hl(0, "CurSearch", { fg = colors.fg0, bg = colors.bg3 })

	-- Matching brackets
	vim.api.nvim_set_hl(0, "MatchParen", { fg = "#ff0000", bg = "NONE", bold = true, underline = true })

	-- Syntax highlighting - Functions (yellow for all functions)
	vim.api.nvim_set_hl(0, "Function", { fg = colors.color6, bold = true })
	vim.api.nvim_set_hl(0, "@function", { fg = colors.color6, bold = true })
	vim.api.nvim_set_hl(0, "@function.call", { fg = colors.color6, bold = true })
	vim.api.nvim_set_hl(0, "@function.definition", { fg = colors.color7, bold = true })
	vim.api.nvim_set_hl(0, "@function.builtin", { fg = colors.color10, bold = false }) -- Builtins stay normal
	-- Python-specific function highlights (same yellow)
	vim.api.nvim_set_hl(0, "@function.call.python", { fg = colors.color6, bold = true })
	vim.api.nvim_set_hl(0, "@function.definition.python", { fg = colors.color7, bold = true })
	vim.api.nvim_set_hl(0, "@function.python", { fg = colors.color6, bold = true })
	vim.api.nvim_set_hl(0, "@function.builtin.python", { fg = colors.color10, bold = false })

	-- Syntax highlighting - Keywords (bold for emphasis)
	vim.api.nvim_set_hl(0, "Keyword", { fg = colors.color4, bold = true })
	vim.api.nvim_set_hl(0, "@keyword", { fg = colors.color4, bold = true })
	vim.api.nvim_set_hl(0, "@keyword.function", { fg = colors.color4, bold = true })
	vim.api.nvim_set_hl(0, "@keyword.return", { fg = colors.color4, bold = true })
	vim.api.nvim_set_hl(0, "@keyword.operator", { fg = colors.color4, bold = true })
	vim.api.nvim_set_hl(0, "@conditional", { fg = colors.color4, bold = true })
	vim.api.nvim_set_hl(0, "@repeat", { fg = colors.color4, bold = true })

	-- Syntax highlighting - Strings (light green)
	vim.api.nvim_set_hl(0, "String", { fg = colors.color2, bold = false })
	vim.api.nvim_set_hl(0, "@string", { fg = colors.color2, bold = false })
	vim.api.nvim_set_hl(0, "@string.regex", { fg = colors.color2, bold = false })
	vim.api.nvim_set_hl(0, "@string.escape", { fg = colors.color2, bold = false })

	-- Syntax highlighting - Comments (italic for readability)
	vim.api.nvim_set_hl(0, "Comment", { fg = colors.color1, italic = true, bold = false })
	vim.api.nvim_set_hl(0, "@comment", { fg = colors.color1, italic = true, bold = false })

	-- Syntax highlighting - Docstrings/Documentation (Python """ """, etc.)
	vim.api.nvim_set_hl(0, "@string.documentation", { fg = colors.fg3, italic = true, bold = false })
	vim.api.nvim_set_hl(0, "@string.documentation.python", { fg = colors.fg3, italic = true, bold = false })
	vim.api.nvim_set_hl(0, "@comment.documentation", { fg = colors.fg3, italic = true, bold = false })

	-- Syntax highlighting - Numbers
	vim.api.nvim_set_hl(0, "Number", { fg = colors.color5, bold = false })
	vim.api.nvim_set_hl(0, "@number", { fg = colors.color5, bold = false })
	vim.api.nvim_set_hl(0, "@float", { fg = colors.color5, bold = false })

	-- Syntax highlighting - Booleans (True/False)
	vim.api.nvim_set_hl(0, "Boolean", { fg = colors.color9, bold = true })
	vim.api.nvim_set_hl(0, "@boolean", { fg = colors.color9, bold = true })

	-- Syntax highlighting - Operators
	vim.api.nvim_set_hl(0, "Operator", { fg = colors.color8, bold = false })
	vim.api.nvim_set_hl(0, "@operator", { fg = colors.color8, bold = false })
	vim.api.nvim_set_hl(0, "@operator.assignment", { fg = colors.color8, bold = false })
	vim.api.nvim_set_hl(0, "@operator.comparison", { fg = colors.color8, bold = false })
	vim.api.nvim_set_hl(0, "@operator.arithmetic", { fg = colors.color8, bold = false })
	vim.api.nvim_set_hl(0, "@operator.logical", { fg = colors.color8, bold = false })
	vim.api.nvim_set_hl(0, "@operator.python", { fg = colors.color8, bold = false })

	-- Syntax highlighting - Variables
	vim.api.nvim_set_hl(0, "Identifier", { fg = colors.fg0, bold = false })
	vim.api.nvim_set_hl(0, "@variable", { fg = colors.fg0, bold = false })
	vim.api.nvim_set_hl(0, "@variable.builtin", { fg = colors.color10, bold = false })
	vim.api.nvim_set_hl(0, "@variable.parameter", { fg = colors.fg0, bold = false })
	-- Python-specific variable highlights
	vim.api.nvim_set_hl(0, "@variable.python", { fg = colors.fg0, bold = false })

	-- Syntax highlighting - Types/Classes (blue-green, bold for emphasis)
	vim.api.nvim_set_hl(0, "Type", { fg = colors.color3, bold = true })
	vim.api.nvim_set_hl(0, "@type", { fg = colors.color3, bold = true })
	vim.api.nvim_set_hl(0, "@type.builtin", { fg = colors.color3, bold = true })
	vim.api.nvim_set_hl(0, "@type.definition", { fg = colors.color3, bold = true })
	-- Class-specific highlights
	vim.api.nvim_set_hl(0, "@class", { fg = colors.color3, bold = true })
	vim.api.nvim_set_hl(0, "@class.definition", { fg = colors.color3, bold = true })

	-- Syntax highlighting - Constants (bold to stand out)
	vim.api.nvim_set_hl(0, "Constant", { fg = colors.color4, bold = true })
	vim.api.nvim_set_hl(0, "@constant", { fg = colors.color4, bold = true })
	vim.api.nvim_set_hl(0, "@constant.builtin", { fg = colors.color10, bold = true })
	vim.api.nvim_set_hl(0, "@constant.macro", { fg = colors.color4, bold = true })

	-- Syntax highlighting - Brackets
	vim.api.nvim_set_hl(0, "@punctuation.bracket", { fg = colors.color11, bold = true })
	-- Syntax highlighting - Punctuation (bright cyan, bold for maximum visibility)
	vim.api.nvim_set_hl(0, "@punctuation.delimiter", { fg = colors.color12, bold = true })
	vim.api.nvim_set_hl(0, "@punctuation.special", { fg = colors.color12, bold = true })
	vim.api.nvim_set_hl(0, "@punctuation", { fg = colors.color12, bold = true })

	-- Syntax highlighting - Preprocessor (bold for emphasis)
	vim.api.nvim_set_hl(0, "PreProc", { fg = colors.color0, bold = true })
	vim.api.nvim_set_hl(0, "@preproc", { fg = colors.color0, bold = true })

	-- Syntax highlighting - Special/Symbols (bright magenta)
	vim.api.nvim_set_hl(0, "Special", { fg = colors.color9, bold = false })
	vim.api.nvim_set_hl(0, "@special", { fg = colors.color9, bold = false })
	vim.api.nvim_set_hl(0, "@symbol", { fg = colors.color9, bold = false })

	-- Status line
	vim.api.nvim_set_hl(0, "StatusLine", { fg = colors.ui0, bg = colors.bg1, bold = false })
	vim.api.nvim_set_hl(0, "StatusLineNC", { fg = colors.ui1, bg = colors.bg0, bold = false })
	vim.api.nvim_set_hl(0, "StatusLineTerm", { fg = colors.ui0, bg = colors.bg1, bold = false })
	vim.api.nvim_set_hl(0, "StatusLineTermNC", { fg = colors.ui1, bg = colors.bg0, bold = false })

	-- Tab line
	vim.api.nvim_set_hl(0, "TabLine", { fg = colors.ui1, bg = colors.bg1, bold = false })
	vim.api.nvim_set_hl(0, "TabLineFill", { fg = colors.ui1, bg = colors.bg0, bold = false })
	vim.api.nvim_set_hl(0, "TabLineSel", { fg = colors.fg0, bg = colors.bg2, bold = true })

	-- Diagnostics
	vim.api.nvim_set_hl(0, "DiagnosticError", { fg = colors.color0, bold = false })
	vim.api.nvim_set_hl(0, "DiagnosticWarn", { fg = colors.color5, bold = false })
	vim.api.nvim_set_hl(0, "DiagnosticInfo", { fg = colors.color10, bold = false })
	vim.api.nvim_set_hl(0, "DiagnosticHint", { fg = colors.color1, bold = false })
	vim.api.nvim_set_hl(0, "DiagnosticUnderlineError", { sp = colors.color0, underline = true })
	vim.api.nvim_set_hl(0, "DiagnosticUnderlineWarn", { sp = colors.color5, underline = true })
	vim.api.nvim_set_hl(0, "DiagnosticUnderlineInfo", { sp = colors.color10, underline = true })
	vim.api.nvim_set_hl(0, "DiagnosticUnderlineHint", { sp = colors.color1, underline = true })

	-- Diagnostic signs
	vim.api.nvim_set_hl(0, "DiagnosticSignError", { fg = colors.color0, bg = colors.bg0, bold = false })
	vim.api.nvim_set_hl(0, "DiagnosticSignWarn", { fg = colors.color5, bg = colors.bg0, bold = false })
	vim.api.nvim_set_hl(0, "DiagnosticSignInfo", { fg = colors.color10, bg = colors.bg0, bold = false })
	vim.api.nvim_set_hl(0, "DiagnosticSignHint", { fg = colors.color1, bg = colors.bg0, bold = false })

	-- Dashboard
	vim.api.nvim_set_hl(0, "AlphaHeader", { fg = colors.ui0, bold = true })
	vim.api.nvim_set_hl(0, "AlphaButton", { fg = colors.color1, bold = false })
	vim.api.nvim_set_hl(0, "AlphaShortcut", { fg = colors.color4, bold = false })
	vim.api.nvim_set_hl(0, "AlphaFooter", { fg = colors.color1, italic = true })

	-- Telescope
	vim.api.nvim_set_hl(0, "TelescopePromptPrefix", { fg = colors.color4, bold = false })
	vim.api.nvim_set_hl(0, "TelescopeSelection", { fg = colors.fg0, bg = colors.bg3, bold = false })
	vim.api.nvim_set_hl(0, "TelescopeMatching", { fg = colors.color1, bold = false })
	vim.api.nvim_set_hl(0, "TelescopePrompt", { bg = colors.bg0 })
	vim.api.nvim_set_hl(0, "TelescopeResults", { bg = colors.bg0 })
	vim.api.nvim_set_hl(0, "TelescopePreview", { bg = colors.bg0 })
	vim.api.nvim_set_hl(0, "TelescopeBorder", { fg = colors.ui3 })

	-- LSP
	vim.api.nvim_set_hl(0, "LspReferenceText", { bg = colors.bg2, bold = false })
	vim.api.nvim_set_hl(0, "LspReferenceRead", { bg = colors.bg2, bold = false })
	vim.api.nvim_set_hl(0, "LspReferenceWrite", { bg = colors.bg2, bold = false })

	-- Diff
	vim.api.nvim_set_hl(0, "DiffAdd", { fg = colors.color1, bg = "NONE", bold = false })
	vim.api.nvim_set_hl(0, "DiffChange", { fg = colors.color5, bg = "NONE", bold = false })
	vim.api.nvim_set_hl(0, "DiffDelete", { fg = colors.color0, bg = "NONE", bold = false })
	vim.api.nvim_set_hl(0, "DiffText", { fg = colors.fg0, bg = colors.bg2, bold = false })

	-- Git signs
	vim.api.nvim_set_hl(0, "GitSignsAdd", { fg = colors.color1, bg = colors.bg0, bold = false })
	vim.api.nvim_set_hl(0, "GitSignsChange", { fg = colors.color5, bg = colors.bg0, bold = false })
	vim.api.nvim_set_hl(0, "GitSignsDelete", { fg = colors.color0, bg = colors.bg0, bold = false })

	-- Fold
	vim.api.nvim_set_hl(0, "Folded", { fg = colors.ui1, bg = colors.bg1, bold = false })
	vim.api.nvim_set_hl(0, "FoldColumn", { fg = colors.ui2, bg = colors.bg0, bold = false })

	-- Pmenu (completion menu)
	vim.api.nvim_set_hl(0, "Pmenu", { fg = colors.fg0, bg = colors.bg2, bold = false })
	vim.api.nvim_set_hl(0, "PmenuSel", { fg = colors.fg0, bg = colors.bg3, bold = false })
	vim.api.nvim_set_hl(0, "PmenuSbar", { bg = colors.bg1, bold = false })
	vim.api.nvim_set_hl(0, "PmenuThumb", { bg = colors.bg3, bold = false })

	-- Cmp (completion)
	vim.api.nvim_set_hl(0, "CmpItemAbbr", { fg = colors.fg0, bold = false })
	vim.api.nvim_set_hl(0, "CmpItemAbbrMatch", { fg = colors.color1, bold = false })
	vim.api.nvim_set_hl(0, "CmpItemKind", { fg = colors.color4, bold = false })
	vim.api.nvim_set_hl(0, "CmpItemMenu", { fg = colors.ui1, bold = false })

	-- Which-key
	vim.api.nvim_set_hl(0, "WhichKey", { fg = colors.color1, bold = false }) -- Group names (colored)
	vim.api.nvim_set_hl(0, "WhichKeyGroup", { fg = colors.color1, bold = false }) -- Group names (colored)
	vim.api.nvim_set_hl(0, "WhichKeySeparator", { fg = colors.ui3, bold = false })
	vim.api.nvim_set_hl(0, "WhichKeyDesc", { fg = colors.fg1, bold = false }) -- Description text (fg1)
	vim.api.nvim_set_hl(0, "WhichKeyValue", { fg = colors.color6, bold = false }) -- Key values (colored)

	-- NvimTree
	vim.api.nvim_set_hl(0, "NvimTreeNormal", { fg = colors.fg0, bg = colors.bg0, bold = false })
	vim.api.nvim_set_hl(0, "NvimTreeNormalNC", { fg = colors.fg2, bg = colors.bg0, bold = false })
	vim.api.nvim_set_hl(0, "NvimTreeRootFolder", { fg = colors.color4, bold = true })
	vim.api.nvim_set_hl(0, "NvimTreeFolderIcon", { fg = colors.color11, bold = false })
	vim.api.nvim_set_hl(0, "NvimTreeOpenedFolderName", { fg = colors.color1, bold = true })
	vim.api.nvim_set_hl(0, "NvimTreeClosedFolderName", { fg = colors.color1, bold = false })

	-- Notify
	vim.api.nvim_set_hl(0, "NotifyERRORBorder", { fg = colors.color0, bold = false })
	vim.api.nvim_set_hl(0, "NotifyWARNBorder", { fg = colors.color5, bold = false })
	vim.api.nvim_set_hl(0, "NotifyINFOBorder", { fg = colors.color10, bold = false })
	vim.api.nvim_set_hl(0, "NotifyDEBUGBorder", { fg = colors.ui1, bold = false })
	vim.api.nvim_set_hl(0, "NotifyTRACEBorder", { fg = colors.color4, bold = false })

	-- Trouble
	vim.api.nvim_set_hl(0, "TroubleText", { fg = colors.fg0, bold = false })
	vim.api.nvim_set_hl(0, "TroubleCount", { fg = colors.color4, bold = false })
	vim.api.nvim_set_hl(0, "TroubleNormal", { fg = colors.fg0, bg = colors.bg0, bold = false })

	-- Python builtins are now handled entirely through Treesitter highlight groups
	-- @function.builtin.python and @variable.builtin are already set above

	-- Set terminal colors for tools that use them
	vim.g.terminal_color_0 = colors.bg0
	vim.g.terminal_color_1 = colors.color0
	vim.g.terminal_color_2 = colors.color1
	vim.g.terminal_color_3 = colors.color6
	vim.g.terminal_color_4 = colors.color11
	vim.g.terminal_color_5 = colors.color4
	vim.g.terminal_color_6 = colors.color10
	vim.g.terminal_color_7 = colors.fg0
	vim.g.terminal_color_8 = colors.ui2
	vim.g.terminal_color_9 = colors.color0
	vim.g.terminal_color_10 = colors.color1
	vim.g.terminal_color_11 = colors.color5
	vim.g.terminal_color_12 = colors.color11
	vim.g.terminal_color_13 = colors.color4
	vim.g.terminal_color_14 = colors.color10
	vim.g.terminal_color_15 = colors.fg0
end

-- Function to apply custom theme
function M.apply_custom()
	current_theme = "custom"
	M.setup()
	vim.notify("Colorscheme: Purpleator", vim.log.levels.INFO)
end

-- Function to apply nightfox
function M.apply_nightfox()
	current_theme = "nightfox"
	-- Check if nightfox is available
	local nightfox_ok, _ = pcall(require, "nightfox")
	if not nightfox_ok then
		vim.notify("Nightfox not installed. Run :Lazy to install plugins.", vim.log.levels.WARN)
		return
	end
	vim.cmd("colorscheme nightfox")
	vim.notify("Colorscheme: Nightfox", vim.log.levels.INFO)
end

-- Toggle between custom and nightfox
function M.toggle()
	if current_theme == "custom" then
		M.apply_nightfox()
	else
		M.apply_custom()
	end
end

-- Get current theme
function M.get_current()
	return current_theme
end

-- Create user commands
vim.api.nvim_create_user_command("ColorschemeCustom", M.apply_custom, {
	desc = "Switch to custom Purpleator colorscheme",
})

vim.api.nvim_create_user_command("ColorschemeNightfox", M.apply_nightfox, {
	desc = "Switch to Nightfox colorscheme",
})

vim.api.nvim_create_user_command("ColorschemeToggle", M.toggle, {
	desc = "Toggle between custom and Nightfox colorscheme",
})

-- Auto-run setup (default to custom)
M.setup()

return M
