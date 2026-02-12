-- Smart terminal management
local M = {}

-- Terminal state tracking
M.terminals = {
	horizontal = { buf = nil, win = nil },
	vertical = { buf = nil, win = nil },
	float = { buf = nil, win = nil },
}

-- Directory for new terminals: current file's dir, or cwd
local function get_term_cwd()
	local file = vim.api.nvim_buf_get_name(vim.api.nvim_get_current_buf())
	local dir = file ~= "" and vim.fn.fnamemodify(file, ":p:h") or ""
	if dir == "" or not vim.fn.isdirectory(dir) then
		return vim.fn.getcwd()
	end
	return dir
end

-- Start terminal in given buffer with cwd (call from that buffer)
local function start_term_in_buf(cwd)
	vim.fn.termopen(vim.o.shell, { cwd = cwd })
end

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
		local cwd = get_term_cwd()
		vim.cmd("botright split")
		term.win = vim.api.nvim_get_current_win()
		vim.cmd("resize 15")
		term.buf = vim.api.nvim_create_buf(false, true)
		vim.bo[term.buf].buflisted = false
		vim.api.nvim_win_set_buf(term.win, term.buf)
		start_term_in_buf(cwd)
	end

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
		local cwd = get_term_cwd()
		vim.cmd("botright vsplit")
		term.win = vim.api.nvim_get_current_win()
		vim.cmd("vertical resize 80")
		term.buf = vim.api.nvim_create_buf(false, true)
		vim.bo[term.buf].buflisted = false
		vim.api.nvim_win_set_buf(term.win, term.buf)
		start_term_in_buf(cwd)
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

	-- Get cwd before we switch to term buffer (so it's the current file's dir)
	local cwd = get_term_cwd()

	if not term.buf or not vim.api.nvim_buf_is_valid(term.buf) then
		term.buf = vim.api.nvim_create_buf(false, true)
		vim.bo[term.buf].buflisted = false
	end

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

	if not vim.b[term.buf].terminal_job_id then
		start_term_in_buf(cwd)
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

-- Find a terminal buffer (our tracked one, or any visible terminal)
local function find_terminal_buf()
	for _, term in pairs(M.terminals) do
		if term.buf and vim.api.nvim_buf_is_valid(term.buf) and vim.bo[term.buf].buftype == "terminal" then
			if term.win and vim.api.nvim_win_is_valid(term.win) then
				return term.buf
			end
		end
	end
	for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
		local buf = vim.api.nvim_win_get_buf(win)
		if vim.bo[buf].buftype == "terminal" then
			return buf
		end
	end
	return nil
end

-- Send "cd <current file's dir>" to the terminal (so you can sync terminal to open file)
function M.cd_to_file_dir()
	local dir = get_term_cwd()
	local term_buf = find_terminal_buf()
	if not term_buf then
		vim.notify("No terminal found", vim.log.levels.WARN)
		return
	end
	local job = vim.b[term_buf].terminal_job_id
	if not job then
		vim.notify("Terminal has no job", vim.log.levels.WARN)
		return
	end
	local cmd = "cd " .. vim.fn.shellescape(dir) .. "\n"
	vim.api.nvim_chan_send(job, cmd)
	vim.notify("Terminal: cd " .. dir, vim.log.levels.INFO)
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

vim.api.nvim_create_user_command("TermCd", function()
	M.cd_to_file_dir()
end, { desc = "Send cd (current file dir) to terminal" })

return M
