local M = {}

function M.setup()
	vim.opt.fillchars:append({
		horiz = "─",
		horizup = "┴",
		horizdown = "┬",
		vert = "│",
		vertleft = "┤",
		vertright = "├",
		verthoriz = "┼",
	})
	
	local orig_util_open_floating_preview = vim.lsp.util.open_floating_preview
	function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
		opts = opts or {}
		opts.border = opts.border or "rounded"
		return orig_util_open_floating_preview(contents, syntax, opts, ...)
	end
	
	vim.opt.foldtext = "v:lua.require'nvim.core.visual'.foldtext()"
end

function M.foldtext()
	local line = vim.fn.getline(vim.v.foldstart)
	local line_count = vim.v.foldend - vim.v.foldstart + 1
	
	line = line:gsub("^%s*", ""):gsub("^[/#*-]+%s*", "")
	
	return string.format("  %s ... (%d lines) ", line, line_count)
end

return M
