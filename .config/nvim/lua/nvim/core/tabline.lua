-- Custom tabline rendering
local M = {}

function M.render()
	local tabline = ""
	local current_tab = vim.fn.tabpagenr()
	local total_tabs = vim.fn.tabpagenr("$")
	
	for i = 1, total_tabs do
		local winnr = vim.fn.tabpagewinnr(i)
		local bufnr = vim.fn.tabpagebuflist(i)[winnr]
		local bufname = vim.fn.bufname(bufnr)
		local filename = bufname ~= "" and vim.fn.fnamemodify(bufname, ":t") or "[No Name]"
		
		-- Check if buffer is modified
		local modified = vim.fn.getbufvar(bufnr, "&modified") == 1 and " [+]" or ""
		
		-- Highlight group for active/inactive tabs
		if i == current_tab then
			tabline = tabline .. "%#TabLineSel#"
		else
			tabline = tabline .. "%#TabLine#"
		end
		
		-- Add clickable tab number
		tabline = tabline .. "%" .. i .. "T"
		
		-- Tab label with number, filename, and modified indicator
		tabline = tabline .. " " .. i .. ": " .. filename .. modified .. " "
		
		-- Add separator
		if i < total_tabs then
			tabline = tabline .. "%#TabLineFill#│"
		end
	end
	
	-- Fill rest with TabLineFill
	tabline = tabline .. "%#TabLineFill#%T"
	
	-- Add close button on the right if more than one tab
	if total_tabs > 1 then
		tabline = tabline .. "%=%#TabLine#%999XX"
	end
	
	return tabline
end

return M
