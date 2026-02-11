-- Fully custom colorscheme - Purpleator
-- All colors defined here for complete control
-- Can switch to nightfox with :ColorschemeToggle or <leader>ct

local M = {}

-- Current theme state
local current_theme = "custom" -- "custom" or "nightfox"

function M.setup()
	local utils = require("nvim.core.utils")

	-- Color palette - Purpleator (poppy, semantic)
	--
	-- Base: fg0/fg1 = main text; fg2/fg3 = dimmed. Data types: string / int / float each get a color.
	-- Matching brackets turn red when cursor is between them (MatchParen).
	--
	local colors = {
		-- Backgrounds (purple undertone)
		bg0 = "#1a1420",
		bg1 = "#251d2e",
		bg2 = "#30283c",
		bg3 = "#3d344a",
		-- Base font (variables, operators, most code)
		fg0 = "#e8e6e3",
		fg1 = "#d4d0ca",
		fg2 = "#a8a29e",
		fg3 = "#78716c",

		-- Semantic accents (poppy but readable)
		control  = "#c4a8ff", -- keywords (violet)
		callable = "#ffcb6b", -- functions (gold)
		type     = "#80cbc4", -- types, classes (teal)
		comment  = "#6a9a6a", -- comments (green-gray)

		-- Data types (string vs int vs float)
		string_color = "#f0a56b", -- strings (coral/peach)
		int_color    = "#81d4fa", -- integers (light blue)
		float_color  = "#a5d6a7", -- floats (mint green)

		-- MatchParen: red when cursor between brackets
		match_paren = "#ef5350",

		-- Errors / warnings / attention
		error = "#e57373",
		warn  = "#ffb74d",
		attention = "#ffb74d", -- TODO, FIXME, etc. (same as warn so they pop)

		-- UI
		ui0 = "#b0b0b0",
		ui1 = "#808080",
		ui2 = "#505050",
		ui3 = "#404040",
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

	-- Matching brackets: red when cursor is between ( ) [ ] { }
	vim.api.nvim_set_hl(0, "MatchParen", { fg = colors.match_paren, bg = "NONE", bold = true, underline = true })

	-- Syntax highlighting - Functions (yellow for all functions)
	vim.api.nvim_set_hl(0, "Function", { fg = colors.callable, bold = true })
	vim.api.nvim_set_hl(0, "@function", { fg = colors.callable, bold = true })
	vim.api.nvim_set_hl(0, "@function.call", { fg = colors.callable, bold = true })
	vim.api.nvim_set_hl(0, "@function.definition", { fg = colors.callable, bold = true })
	vim.api.nvim_set_hl(0, "@function.builtin", { fg = colors.type, bold = false }) -- Builtins stay normal
	-- Python-specific function highlights (same yellow)
	vim.api.nvim_set_hl(0, "@function.call.python", { fg = colors.callable, bold = true })
	vim.api.nvim_set_hl(0, "@function.definition.python", { fg = colors.callable, bold = true })
	vim.api.nvim_set_hl(0, "@function.python", { fg = colors.callable, bold = true })
	vim.api.nvim_set_hl(0, "@function.builtin.python", { fg = colors.type, bold = false })

	-- Syntax highlighting - Keywords (bold for emphasis)
	vim.api.nvim_set_hl(0, "Keyword", { fg = colors.control, bold = true })
	vim.api.nvim_set_hl(0, "@keyword", { fg = colors.control, bold = true })
	vim.api.nvim_set_hl(0, "@keyword.function", { fg = colors.control, bold = true })
	vim.api.nvim_set_hl(0, "@keyword.return", { fg = colors.control, bold = true })
	vim.api.nvim_set_hl(0, "@keyword.operator", { fg = colors.control, bold = true })
	vim.api.nvim_set_hl(0, "@conditional", { fg = colors.control, bold = true })
	vim.api.nvim_set_hl(0, "@repeat", { fg = colors.control, bold = true })

	-- Strings (coral/peach)
	vim.api.nvim_set_hl(0, "String", { fg = colors.string_color, bold = false })
	vim.api.nvim_set_hl(0, "@string", { fg = colors.string_color, bold = false })
	vim.api.nvim_set_hl(0, "@string.regex", { fg = colors.string_color, bold = false })
	vim.api.nvim_set_hl(0, "@string.escape", { fg = colors.string_color, bold = false })

	-- Comments (italic)
	vim.api.nvim_set_hl(0, "Comment", { fg = colors.comment, italic = true, bold = false })
	vim.api.nvim_set_hl(0, "@comment", { fg = colors.comment, italic = true, bold = false })

	-- TODO / FIXME / XXX / HACK / NOTE (stand out in comments; todo-comments.nvim + fallback)
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

	-- Syntax highlighting - Docstrings/Documentation (Python """ """, etc.)
	vim.api.nvim_set_hl(0, "@string.documentation", { fg = colors.fg3, italic = true, bold = false })
	vim.api.nvim_set_hl(0, "@string.documentation.python", { fg = colors.fg3, italic = true, bold = false })
	vim.api.nvim_set_hl(0, "@comment.documentation", { fg = colors.fg3, italic = true, bold = false })

	-- Numbers: integers vs floats (different colors)
	vim.api.nvim_set_hl(0, "Number", { fg = colors.int_color, bold = false })
	vim.api.nvim_set_hl(0, "@number", { fg = colors.int_color, bold = false })
	vim.api.nvim_set_hl(0, "@float", { fg = colors.float_color, bold = false })

	-- Syntax highlighting - Booleans (True/False) - keep bright for importance
	vim.api.nvim_set_hl(0, "Boolean", { fg = colors.control, bold = true })
	vim.api.nvim_set_hl(0, "@boolean", { fg = colors.control, bold = true })
	
	-- Additional elements that should use base color
	vim.api.nvim_set_hl(0, "@property", { fg = colors.fg1, bold = false }) -- object.property
	vim.api.nvim_set_hl(0, "@field", { fg = colors.fg1, bold = false }) -- struct fields
	vim.api.nvim_set_hl(0, "@parameter", { fg = colors.fg2, bold = false }) -- function parameters
	vim.api.nvim_set_hl(0, "@namespace", { fg = colors.fg1, bold = false }) -- namespaces, modules
	vim.api.nvim_set_hl(0, "@label", { fg = colors.fg2, bold = false }) -- labels
	vim.api.nvim_set_hl(0, "@tag", { fg = colors.control, bold = false }) -- HTML/XML tags - keep colored
	vim.api.nvim_set_hl(0, "@tag.attribute", { fg = colors.fg1, bold = false }) -- HTML attributes
	vim.api.nvim_set_hl(0, "@tag.delimiter", { fg = colors.fg3, bold = false }) -- <, >, /

	-- Syntax highlighting - Operators (slightly brighter than base, but not neon)
	-- Using a soft teal/cyan that's between base gray and bright cyan
	local operator_color = "#8fa0b0" -- Soft blue-gray, slightly brighter than fg2
	vim.api.nvim_set_hl(0, "Operator", { fg = operator_color, bold = false })
	vim.api.nvim_set_hl(0, "@operator", { fg = operator_color, bold = false })
	vim.api.nvim_set_hl(0, "@operator.assignment", { fg = operator_color, bold = false }) -- =, +=, etc.
	vim.api.nvim_set_hl(0, "@operator.comparison", { fg = operator_color, bold = false }) -- ==, !=, etc.
	vim.api.nvim_set_hl(0, "@operator.arithmetic", { fg = operator_color, bold = false }) -- +, -, *, /
	vim.api.nvim_set_hl(0, "@operator.logical", { fg = operator_color, bold = false }) -- and, or
	vim.api.nvim_set_hl(0, "@operator.python", { fg = operator_color, bold = false })

	-- Syntax highlighting - Variables (use dimmer base color for regular variables)
	vim.api.nvim_set_hl(0, "Identifier", { fg = colors.fg1, bold = false }) -- Dimmed base color
	vim.api.nvim_set_hl(0, "@variable", { fg = colors.fg1, bold = false }) -- Dimmed base color
	vim.api.nvim_set_hl(0, "@variable.builtin", { fg = colors.type, bold = false }) -- Builtins stay cyan
	vim.api.nvim_set_hl(0, "@variable.parameter", { fg = colors.fg2, bold = false }) -- Parameters even dimmer
	vim.api.nvim_set_hl(0, "@variable.member", { fg = colors.fg1, bold = false }) -- Object properties
	-- Python-specific variable highlights
	vim.api.nvim_set_hl(0, "@variable.python", { fg = colors.fg1, bold = false })

	-- Syntax highlighting - Types/Classes (blue-green, bold for emphasis)
	vim.api.nvim_set_hl(0, "Type", { fg = colors.type, bold = true })
	vim.api.nvim_set_hl(0, "@type", { fg = colors.type, bold = true })
	vim.api.nvim_set_hl(0, "@type.builtin", { fg = colors.type, bold = true })
	vim.api.nvim_set_hl(0, "@type.definition", { fg = colors.type, bold = true })
	-- Class-specific highlights
	vim.api.nvim_set_hl(0, "@class", { fg = colors.type, bold = true })
	vim.api.nvim_set_hl(0, "@class.definition", { fg = colors.type, bold = true })

	-- Syntax highlighting - Constants (bold to stand out)
	vim.api.nvim_set_hl(0, "Constant", { fg = colors.control, bold = true })
	vim.api.nvim_set_hl(0, "@constant", { fg = colors.control, bold = true })
	vim.api.nvim_set_hl(0, "@constant.builtin", { fg = colors.type, bold = true })
	vim.api.nvim_set_hl(0, "@constant.macro", { fg = colors.control, bold = true })

	-- Syntax highlighting - Brackets (dimmed to reduce noise)
	vim.api.nvim_set_hl(0, "@punctuation.bracket", { fg = colors.fg3, bold = false }) -- (), [], {}
	-- Syntax highlighting - Punctuation (dimmed - commas, semicolons, dots)
	vim.api.nvim_set_hl(0, "@punctuation.delimiter", { fg = colors.fg3, bold = false })
	vim.api.nvim_set_hl(0, "@punctuation.special", { fg = colors.fg2, bold = false })
	vim.api.nvim_set_hl(0, "@punctuation", { fg = colors.fg3, bold = false })

	-- Preprocessor
	vim.api.nvim_set_hl(0, "PreProc", { fg = colors.error, bold = true })
	vim.api.nvim_set_hl(0, "@preproc", { fg = colors.error, bold = true })

	-- Decorators / attributes (e.g. Python @decorator, Rust #[...]) — stand out
	vim.api.nvim_set_hl(0, "@attribute", { fg = colors.control, bold = true })
	vim.api.nvim_set_hl(0, "@attribute.python", { fg = colors.control, bold = true })

	-- Markdown / docs: links and URLs (easy to spot)
	vim.api.nvim_set_hl(0, "@markup.link", { fg = colors.type, underline = true })
	vim.api.nvim_set_hl(0, "@markup.link.url", { fg = colors.string_color, underline = true })
	vim.api.nvim_set_hl(0, "markdownUrl", { fg = colors.string_color, underline = true })

	-- Spell and trailing whitespace (so they’re visible)
	vim.api.nvim_set_hl(0, "SpellBad", { sp = colors.error, underline = true })
	vim.api.nvim_set_hl(0, "SpellCap", { sp = colors.warn, underline = true })
	vim.api.nvim_set_hl(0, "SpellRare", { sp = colors.type, underline = true })
	vim.api.nvim_set_hl(0, "Whitespace", { fg = colors.fg3, nocombine = true })
	vim.api.nvim_set_hl(0, "TrailingWhitespace", { fg = colors.error, nocombine = true })

	-- Special/Symbols
	vim.api.nvim_set_hl(0, "Special", { fg = colors.control, bold = false })
	vim.api.nvim_set_hl(0, "@special", { fg = colors.control, bold = false })
	vim.api.nvim_set_hl(0, "@symbol", { fg = colors.control, bold = false })

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
	vim.api.nvim_set_hl(0, "DiagnosticError", { fg = colors.error, bold = false })
	vim.api.nvim_set_hl(0, "DiagnosticWarn", { fg = colors.warn, bold = false })
	vim.api.nvim_set_hl(0, "DiagnosticInfo", { fg = colors.type, bold = false })
	vim.api.nvim_set_hl(0, "DiagnosticHint", { fg = colors.comment, bold = false })
	vim.api.nvim_set_hl(0, "DiagnosticUnderlineError", { sp = colors.error, underline = true })
	vim.api.nvim_set_hl(0, "DiagnosticUnderlineWarn", { sp = colors.warn, underline = true })
	vim.api.nvim_set_hl(0, "DiagnosticUnderlineInfo", { sp = colors.type, underline = true })
	vim.api.nvim_set_hl(0, "DiagnosticUnderlineHint", { sp = colors.comment, underline = true })

	-- Diagnostic signs
	vim.api.nvim_set_hl(0, "DiagnosticSignError", { fg = colors.error, bg = colors.bg0, bold = false })
	vim.api.nvim_set_hl(0, "DiagnosticSignWarn", { fg = colors.warn, bg = colors.bg0, bold = false })
	vim.api.nvim_set_hl(0, "DiagnosticSignInfo", { fg = colors.type, bg = colors.bg0, bold = false })
	vim.api.nvim_set_hl(0, "DiagnosticSignHint", { fg = colors.comment, bg = colors.bg0, bold = false })

	-- Dashboard
	vim.api.nvim_set_hl(0, "AlphaHeader", { fg = colors.ui0, bold = true })
	vim.api.nvim_set_hl(0, "AlphaButton", { fg = colors.comment, bold = false })
	vim.api.nvim_set_hl(0, "AlphaShortcut", { fg = colors.control, bold = false })
	vim.api.nvim_set_hl(0, "AlphaFooter", { fg = colors.comment, italic = true })

	-- Telescope
	vim.api.nvim_set_hl(0, "TelescopePromptPrefix", { fg = colors.control, bold = false })
	vim.api.nvim_set_hl(0, "TelescopeSelection", { fg = colors.fg0, bg = colors.bg3, bold = false })
	vim.api.nvim_set_hl(0, "TelescopeMatching", { fg = colors.comment, bold = false })
	vim.api.nvim_set_hl(0, "TelescopePrompt", { bg = colors.bg0 })
	vim.api.nvim_set_hl(0, "TelescopeResults", { bg = colors.bg0 })
	vim.api.nvim_set_hl(0, "TelescopePreview", { bg = colors.bg0 })
	vim.api.nvim_set_hl(0, "TelescopeBorder", { fg = colors.ui3 })

	-- LSP
	vim.api.nvim_set_hl(0, "LspReferenceText", { bg = colors.bg2, bold = false })
	vim.api.nvim_set_hl(0, "LspReferenceRead", { bg = colors.bg2, bold = false })
	vim.api.nvim_set_hl(0, "LspReferenceWrite", { bg = colors.bg2, bold = false })

	-- Diff
	vim.api.nvim_set_hl(0, "DiffAdd", { fg = colors.comment, bg = "NONE", bold = false })
	vim.api.nvim_set_hl(0, "DiffChange", { fg = colors.warn, bg = "NONE", bold = false })
	vim.api.nvim_set_hl(0, "DiffDelete", { fg = colors.error, bg = "NONE", bold = false })
	vim.api.nvim_set_hl(0, "DiffText", { fg = colors.fg0, bg = colors.bg2, bold = false })

	-- Git signs
	vim.api.nvim_set_hl(0, "GitSignsAdd", { fg = colors.comment, bg = colors.bg0, bold = false })
	vim.api.nvim_set_hl(0, "GitSignsChange", { fg = colors.warn, bg = colors.bg0, bold = false })
	vim.api.nvim_set_hl(0, "GitSignsDelete", { fg = colors.error, bg = colors.bg0, bold = false })

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
	vim.api.nvim_set_hl(0, "CmpItemAbbrMatch", { fg = colors.comment, bold = false })
	vim.api.nvim_set_hl(0, "CmpItemKind", { fg = colors.control, bold = false })
	vim.api.nvim_set_hl(0, "CmpItemMenu", { fg = colors.ui1, bold = false })

	-- Which-key (purple-themed for Purpleator)
	vim.api.nvim_set_hl(0, "WhichKey", { fg = colors.callable, bold = true }) -- Key bindings - bright yellow
	vim.api.nvim_set_hl(0, "WhichKeyGroup", { fg = colors.control, bold = false }) -- Groups - muted purple
	vim.api.nvim_set_hl(0, "WhichKeySeparator", { fg = colors.bg3, bold = false }) -- Separator - subtle
	vim.api.nvim_set_hl(0, "WhichKeyDesc", { fg = colors.fg1, bold = false }) -- Description - base color
	vim.api.nvim_set_hl(0, "WhichKeyValue", { fg = colors.type, bold = false }) -- Values - cyan
	vim.api.nvim_set_hl(0, "WhichKeyFloat", { bg = colors.bg1 }) -- Background - lighter purple
	vim.api.nvim_set_hl(0, "WhichKeyBorder", { fg = colors.control, bg = colors.bg1 }) -- Border - purple accent
	vim.api.nvim_set_hl(0, "WhichKeyTitle", { fg = colors.control, bg = colors.bg1, bold = true }) -- Title - purple

	-- NvimTree
	vim.api.nvim_set_hl(0, "NvimTreeNormal", { fg = colors.fg0, bg = colors.bg0, bold = false })
	vim.api.nvim_set_hl(0, "NvimTreeNormalNC", { fg = colors.fg2, bg = colors.bg0, bold = false })
	vim.api.nvim_set_hl(0, "NvimTreeRootFolder", { fg = colors.control, bold = true })
	vim.api.nvim_set_hl(0, "NvimTreeFolderIcon", { fg = colors.comment, bold = false })
	vim.api.nvim_set_hl(0, "NvimTreeOpenedFolderName", { fg = colors.comment, bold = true })
	vim.api.nvim_set_hl(0, "NvimTreeClosedFolderName", { fg = colors.comment, bold = false })

	-- Notify
	vim.api.nvim_set_hl(0, "NotifyERRORBorder", { fg = colors.error, bold = false })
	vim.api.nvim_set_hl(0, "NotifyWARNBorder", { fg = colors.warn, bold = false })
	vim.api.nvim_set_hl(0, "NotifyINFOBorder", { fg = colors.type, bold = false })
	vim.api.nvim_set_hl(0, "NotifyDEBUGBorder", { fg = colors.ui1, bold = false })
	vim.api.nvim_set_hl(0, "NotifyTRACEBorder", { fg = colors.control, bold = false })

	-- Trouble
	vim.api.nvim_set_hl(0, "TroubleText", { fg = colors.fg0, bold = false })
	vim.api.nvim_set_hl(0, "TroubleCount", { fg = colors.control, bold = false })
	vim.api.nvim_set_hl(0, "TroubleNormal", { fg = colors.fg0, bg = colors.bg0, bold = false })

	-- Python builtins are now handled entirely through Treesitter highlight groups
	-- @function.builtin.python and @variable.builtin are already set above

	-- Set terminal colors for tools that use them
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

	-- Trailing whitespace: highlight on current line only (so it's visible without :set list)
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
