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
		local modified = vim.fn.getbufvar(bufnr, "&modified") == 1 and " [+]" or ""

		if i == current_tab then
			tabline = tabline .. "%#TabLineSel#"
		else
			tabline = tabline .. "%#TabLine#"
		end

		tabline = tabline .. "%" .. i .. "T"
		tabline = tabline .. " " .. i .. ": " .. filename .. modified .. " "

		if i < total_tabs then
			tabline = tabline .. "%#TabLineFill#│"
		end
	end

	tabline = tabline .. "%#TabLineFill#%T"

	if total_tabs > 1 then
		tabline = tabline .. "%=%#TabLine#%999XX"
	end

	return tabline
end

return M
