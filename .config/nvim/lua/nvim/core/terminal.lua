-- Smart terminal management
local M = {}

-- Terminal state tracking
M.terminals = {
	horizontal = { buf = nil, win = nil },
	vertical = { buf = nil, win = nil },
	float = { buf = nil, win = nil },
}

-- Create or toggle horizontal terminal
function M.toggle_horizontal()
	local term = M.terminals.horizontal
	
	-- If window exists and is visible, hide it
	if term.win and vim.api.nvim_win_is_valid(term.win) then
		vim.api.nvim_win_hide(term.win)
		term.win = nil
		return
	end
	
	-- If buffer exists, reuse it
	if term.buf and vim.api.nvim_buf_is_valid(term.buf) then
		vim.cmd("botright split")
		term.win = vim.api.nvim_get_current_win()
		vim.api.nvim_win_set_buf(term.win, term.buf)
		vim.cmd("resize 15")
	else
		-- Create new terminal
		vim.cmd("botright split")
		term.win = vim.api.nvim_get_current_win()
		vim.cmd("resize 15")
		vim.cmd("terminal")
		term.buf = vim.api.nvim_get_current_buf()
		
		-- Set buffer options
		vim.bo[term.buf].buflisted = false
	end
	
	-- Start in insert mode
	vim.cmd("startinsert")
end

-- Create or toggle vertical terminal
function M.toggle_vertical()
	local term = M.terminals.vertical
	
	if term.win and vim.api.nvim_win_is_valid(term.win) then
		vim.api.nvim_win_hide(term.win)
		term.win = nil
		return
	end
	
	if term.buf and vim.api.nvim_buf_is_valid(term.buf) then
		vim.cmd("botright vsplit")
		term.win = vim.api.nvim_get_current_win()
		vim.api.nvim_win_set_buf(term.win, term.buf)
		vim.cmd("vertical resize 80")
	else
		vim.cmd("botright vsplit")
		term.win = vim.api.nvim_get_current_win()
		vim.cmd("vertical resize 80")
		vim.cmd("terminal")
		term.buf = vim.api.nvim_get_current_buf()
		vim.bo[term.buf].buflisted = false
	end
	
	vim.cmd("startinsert")
end

-- Create or toggle floating terminal
function M.toggle_float()
	local term = M.terminals.float
	
	if term.win and vim.api.nvim_win_is_valid(term.win) then
		vim.api.nvim_win_hide(term.win)
		term.win = nil
		return
	end
	
	-- Create buffer and start terminal if needed
	if not term.buf or not vim.api.nvim_buf_is_valid(term.buf) then
		term.buf = vim.api.nvim_create_buf(false, true)
		vim.bo[term.buf].buflisted = false
	end
	
	-- Create centered floating window
	local width = math.floor(vim.o.columns * 0.8)
	local height = math.floor(vim.o.lines * 0.8)
	local row = math.floor((vim.o.lines - height) / 2)
	local col = math.floor((vim.o.columns - width) / 2)
	
	local opts = {
		relative = "editor",
		width = width,
		height = height,
		row = row,
		col = col,
		style = "minimal",
		border = "rounded",
	}
	
	term.win = vim.api.nvim_open_win(term.buf, true, opts)
	
	-- Start terminal if this is the first time
	if not vim.b[term.buf].terminal_job_id then
		vim.cmd("terminal")
	end
	
	vim.cmd("startinsert")
end

-- Close all terminals
function M.close_all()
	for name, term in pairs(M.terminals) do
		-- Hide window if it exists
		if term.win and vim.api.nvim_win_is_valid(term.win) then
			vim.api.nvim_win_hide(term.win)
			term.win = nil
		end
		
		-- Delete buffer if it exists
		if term.buf and vim.api.nvim_buf_is_valid(term.buf) then
			vim.api.nvim_buf_delete(term.buf, { force = true })
			term.buf = nil
		end
	end
	vim.notify("All terminals closed", vim.log.levels.INFO)
end

-- Create user commands
vim.api.nvim_create_user_command("TermToggle", function()
	M.toggle_horizontal()
end, { desc = "Toggle horizontal terminal" })

vim.api.nvim_create_user_command("TermVertical", function()
	M.toggle_vertical()
end, { desc = "Toggle vertical terminal" })

vim.api.nvim_create_user_command("TermFloat", function()
	M.toggle_float()
end, { desc = "Toggle floating terminal" })

vim.api.nvim_create_user_command("TermCloseAll", function()
	M.close_all()
end, { desc = "Close all terminals" })

return M
