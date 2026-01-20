-- Visual enhancements using native Neovim features
local M = {}

function M.setup()
	-- Better window separators
	vim.opt.fillchars:append({
		horiz = "─",
		horizup = "┴",
		horizdown = "┬",
		vert = "│",
		vertleft = "┤",
		vertright = "├",
		verthoriz = "┼",
	})
	
	-- Rounded borders for floating windows globally
	local orig_util_open_floating_preview = vim.lsp.util.open_floating_preview
	function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
		opts = opts or {}
		opts.border = opts.border or "rounded"
		return orig_util_open_floating_preview(contents, syntax, opts, ...)
	end
	
	-- Better cursorline (only highlight line number, subtle line)
	vim.opt.cursorlineopt = "number,line"
	
	-- Better fold text display
	vim.opt.foldtext = "v:lua.require'nvim.core.visual'.foldtext()"
	
	-- Use your existing Purpleator color theme
	-- No custom highlights - your theme already handles everything!
	-- This function intentionally does nothing - your colorscheme.lua sets all colors
	local function set_highlights()
		-- Your Purpleator theme already sets:
		-- - CursorLine, CursorLineNr, LineNr
		-- - Search, IncSearch
		-- - Visual, TabLine, TabLineSel, TabLineFill
		-- - Folded, FoldColumn
		-- - MatchParen
		-- - DiffAdd, DiffChange, DiffDelete, DiffText
		-- - All other highlights
		
		-- Nothing to do here - your theme is complete!
	end
	
	-- Apply highlights on colorscheme change
	vim.api.nvim_create_autocmd("ColorScheme", {
		pattern = "*",
		callback = set_highlights,
		desc = "Apply custom highlights after colorscheme",
	})
	
	-- Apply highlights now
	set_highlights()
end

-- Custom fold text function
function M.foldtext()
	local line = vim.fn.getline(vim.v.foldstart)
	local line_count = vim.v.foldend - vim.v.foldstart + 1
	
	-- Clean up the line (remove leading whitespace and comments)
	line = line:gsub("^%s*", ""):gsub("^[/#*-]+%s*", "")
	
	return string.format("  %s ... (%d lines) ", line, line_count)
end

return M
