vim.g.mapleader = " "

local keymap = vim.keymap

keymap.set("i", "jk", "<ESC>", { desc = "Exit insert mode" })

keymap.set("n", "<Esc>", "<cmd>nohl<CR>", { desc = "Clear search highlights" })

keymap.set("n", "<C-s>", "<cmd>w<CR>", { desc = "Save file" })
keymap.set("n", "<C-S-s>", "<cmd>wa<CR>", { desc = "Save all files" })

keymap.set("n", "<leader>ct", "<cmd>ColorschemeToggle<CR>", { desc = "Toggle colorscheme" })

keymap.set("v", "<", "<gv", { desc = "Indent left and reselect" })
keymap.set("v", ">", ">gv", { desc = "Indent right and reselect" })
keymap.set("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move selected lines down" })
keymap.set("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move selected lines up" })
keymap.set("v", "p", '"_dP', { desc = "Paste without yanking" })

keymap.set("n", "<C-d>", "<C-d>zz", { desc = "Scroll down half page (centered)" })
keymap.set("n", "<C-u>", "<C-u>zz", { desc = "Scroll up half page (centered)" })
keymap.set("n", "n", "nzzzv", { desc = "Next search result (centered)" })
keymap.set("n", "N", "Nzzzv", { desc = "Previous search result (centered)" })

keymap.set("n", "[b", "<cmd>bprevious<CR>", { desc = "Previous buffer" })
keymap.set("n", "]b", "<cmd>bnext<CR>", { desc = "Next buffer" })
keymap.set("n", "<leader>bd", "<cmd>bdelete<CR>", { desc = "Delete current buffer" })
keymap.set("n", "<leader>bx", "<cmd>bdelete!<CR>", { desc = "Force delete buffer" })

keymap.set("n", "<leader>w=", "<C-w>=", { desc = "Equalize windows" })
keymap.set("n", "<leader>w|", "<C-w>|", { desc = "Maximize window width" })
keymap.set("n", "<leader>w_", "<C-w>_", { desc = "Maximize window height" })
keymap.set("n", "<leader>wr", "<cmd>SessionRestore<CR>", { desc = "Restore session" })
keymap.set("n", "<leader>ws", "<cmd>SessionSave<CR>", { desc = "Save session" })

keymap.set("n", "<leader>q", "<cmd>q<CR>", { desc = "Quit window" })
keymap.set("n", "<leader>Q", "<cmd>q!<CR>", { desc = "Force quit window" })

keymap.set("n", "[q", "<cmd>cprev<CR>", { desc = "Previous quickfix item" })
keymap.set("n", "]q", "<cmd>cnext<CR>", { desc = "Next quickfix item" })
keymap.set("n", "[Q", "<cmd>cfirst<CR>", { desc = "First quickfix item" })
keymap.set("n", "]Q", "<cmd>clast<CR>", { desc = "Last quickfix item" })

keymap.set("n", "[l", "<cmd>lprev<CR>", { desc = "Previous location item" })
keymap.set("n", "]l", "<cmd>lnext<CR>", { desc = "Next location item" })
keymap.set("n", "[L", "<cmd>lfirst<CR>", { desc = "First location item" })
keymap.set("n", "]L", "<cmd>llast<CR>", { desc = "Last location item" })

keymap.set("n", "[D", function() vim.diagnostic.goto_prev({ severity = vim.diagnostic.severity.ERROR }) end, { desc = "Previous error" })
keymap.set("n", "]D", function() vim.diagnostic.goto_next({ severity = vim.diagnostic.severity.ERROR }) end, { desc = "Next error" })
keymap.set("n", "<leader>dd", vim.diagnostic.open_float, { desc = "Line diagnostics (float)" })

keymap.set("c", "<C-a>", "<Home>", { desc = "Beginning of line" })
keymap.set("c", "<C-e>", "<End>", { desc = "End of line" })

keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })
keymap.set("t", "<C-h>", "<Cmd>wincmd h<CR>", { desc = "Move to left window" })
keymap.set("t", "<C-j>", "<Cmd>wincmd j<CR>", { desc = "Move to bottom window" })
keymap.set("t", "<C-k>", "<Cmd>wincmd k<CR>", { desc = "Move to top window" })
keymap.set("t", "<C-l>", "<Cmd>wincmd l<CR>", { desc = "Move to right window" })

keymap.set("i", ",", ",<C-g>u", { desc = "Undo breakpoint" })
keymap.set("i", ".", ".<C-g>u", { desc = "Undo breakpoint" })
keymap.set("i", "!", "!<C-g>u", { desc = "Undo breakpoint" })
keymap.set("i", "?", "?<C-g>u", { desc = "Undo breakpoint" })
keymap.set("i", ";", ";<C-g>u", { desc = "Undo breakpoint" })

local function get_block_range()
	local cursor_row = vim.api.nvim_win_get_cursor(0)[1]
	local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
	local depth = 0
	local start_line = nil
	for i = cursor_row, 1, -1 do
		local l = lines[i] or ""
		for j = #l, 1, -1 do
			local c = l:sub(j, j)
			if c == "}" then
				depth = depth + 1
			elseif c == "{" then
				if depth == 0 then
					start_line = i
					break
				end
				depth = depth - 1
			end
		end
		if start_line then break end
	end
	if not start_line then return nil, nil end
	depth = 0
	local end_line = nil
	for i = start_line, #lines do
		local l = lines[i] or ""
		for j = 1, #l do
			local c = l:sub(j, j)
			if c == "{" then
				depth = depth + 1
			elseif c == "}" then
				depth = depth - 1
				if depth == 0 then
					end_line = i
					break
				end
			end
		end
		if end_line then break end
	end
	return start_line, end_line
end

keymap.set("n", "<leader>sr", function()
	local word = vim.fn.expand("<cword>")
	if word == "" then
		vim.notify("No word under cursor", vim.log.levels.WARN)
		return
	end
	local pat = vim.fn.escape(word, "\\/.*$^~[]")
	local start_ln, end_ln = get_block_range()
	local range = start_ln and end_ln and (start_ln .. "," .. end_ln) or "%"
	local keys = ":" .. range .. "s/\\<" .. pat .. "\\>//g" .. vim.api.nvim_replace_termcodes("<Left><Left>", true, false, true)
	vim.api.nvim_feedkeys(keys, "n", false)
end, { desc = "Search/replace word in block" })
keymap.set("v", "<leader>sr", function()
	local word = vim.fn.expand("<cword>")
	if word == "" then
		vim.notify("No word under cursor", vim.log.levels.WARN)
		return
	end
	local pat = vim.fn.escape(word, "\\/.*$^~[]")
	local keys = ":'<,'>s/\\<" .. pat .. "\\>//g" .. vim.api.nvim_replace_termcodes("<Left><Left>", true, false, true)
	vim.api.nvim_feedkeys(keys, "n", false)
end, { desc = "Search/replace in selection" })

keymap.set("n", "<leader>tn", "<cmd>tabnew<CR>", { desc = "New tab" })
keymap.set("n", "<leader>tc", "<cmd>tabclose<CR>", { desc = "Close tab" })
keymap.set("n", "<leader>to", "<cmd>tabonly<CR>", { desc = "Close other tabs" })
keymap.set("n", "<leader>tm", ":tabmove ", { desc = "Move tab to position" })

vim.api.nvim_create_autocmd("RecordingEnter", {
	callback = function()
		vim.notify("Recording macro to register: " .. vim.fn.reg_recording(), vim.log.levels.INFO)
	end,
})

vim.api.nvim_create_autocmd("RecordingLeave", {
	callback = function()
		vim.notify("Macro recording stopped", vim.log.levels.INFO)
	end,
})

keymap.set("n", "<leader>nx", ":%!xxd<CR>", { desc = "Convert to hex view" })
keymap.set("n", "<leader>nr", ":%!xxd -r<CR>", { desc = "Revert hex view" })

keymap.set("n", "<leader>dt", "<cmd>diffthis<CR>", { desc = "Diff this buffer" })
keymap.set("n", "<leader>do", "<cmd>diffoff<CR>", { desc = "Turn off diff" })
keymap.set("n", "<leader>du", "<cmd>diffupdate<CR>", { desc = "Update diff" })

keymap.set("n", "<leader>ev", "<cmd>e $MYVIMRC<CR>", { desc = "Edit init.lua" })

keymap.set("n", "<leader>rr", "<cmd>checktime<CR>", { desc = "Reload buffers from disk" })
keymap.set("n", "<leader>uu", "<cmd>earlier 1f<CR>", { desc = "Undo to previous file save" })

keymap.set("n", "<leader>vc", function() require("nvim.core.checkpoint").create_checkpoint() end, { desc = "Create checkpoint" })
keymap.set("n", "<leader>vr", function() require("nvim.core.checkpoint").restore_checkpoint() end, { desc = "Restore checkpoint" })
keymap.set("n", "<leader>vd", function() require("nvim.core.checkpoint").show_diff() end, { desc = "Diff with checkpoint" })
keymap.set("n", "<leader>vx", function() require("nvim.core.checkpoint").delete_checkpoint() end, { desc = "Delete checkpoint" })

keymap.set("n", "<leader>vh", function() require("nvim.core.checkpoint").create_session_checkpoint() end, { desc = "Checkpoint open files" })
keymap.set("n", "<leader>vj", function() require("nvim.core.checkpoint").create_project_checkpoint() end, { desc = "Checkpoint entire project" })
keymap.set("n", "<leader>vk", function() require("nvim.core.checkpoint").restore_session_checkpoint() end, { desc = "Restore all files" })
keymap.set("n", "<leader>vl", function() require("nvim.core.checkpoint").show_session_diff() end, { desc = "Show all changes" })

keymap.set("n", "<leader>us", "<cmd>set spell!<CR>", { desc = "Toggle spell check" })
keymap.set("n", "<leader>ur", "<cmd>set relativenumber!<CR>", { desc = "Toggle relative numbers" })
keymap.set("n", "<leader>uw", "<cmd>set wrap!<CR>", { desc = "Toggle line wrap" })
keymap.set("n", "<leader>ul", "<cmd>set list!<CR>", { desc = "Toggle whitespace" })

keymap.set("n", "<leader>yp", ':let @+ = expand("%:p")<CR>:echo "Copied: " . expand("%:p")<CR>', { desc = "Yank full path" })
keymap.set("n", "<leader>yr", ':let @+ = expand("%")<CR>:echo "Copied: " . expand("%")<CR>', { desc = "Yank relative path" })
keymap.set("n", "<leader>yn", ':let @+ = expand("%:t")<CR>:echo "Copied: " . expand("%:t")<CR>', { desc = "Yank filename" })

keymap.set("n", "<leader>zt", function() require("nvim.core.terminal").toggle_horizontal() end, { desc = "Toggle terminal" })
keymap.set("t", "<leader>zt", "<C-\\><C-n>:lua require('nvim.core.terminal').toggle_horizontal()<CR>", { desc = "Toggle terminal" })
keymap.set("n", "<leader>zf", function() require("nvim.core.terminal").toggle_float() end, { desc = "Floating terminal" })
keymap.set("n", "<leader>zv", function() require("nvim.core.terminal").toggle_vertical() end, { desc = "Vertical terminal" })
keymap.set("n", "<leader>zx", function() require("nvim.core.terminal").close_all() end, { desc = "Shutdown all terminals" })
keymap.set("n", "<leader>zc", function() require("nvim.core.terminal").cd_to_file_dir() end, { desc = "Terminal cd to file dir" })

vim.api.nvim_create_autocmd("FileType", {
	group = vim.api.nvim_create_augroup("GoKeymaps", { clear = true }),
	pattern = "go",
	callback = function()
		local dir = vim.fn.shellescape(vim.fn.expand("%:p:h"))
		local file = vim.fn.shellescape(vim.fn.expand("%"))
		keymap.set("n", "<leader>Gr", function()
			vim.cmd("split | terminal cd " .. dir .. " && go run " .. file)
		end, { buffer = true, desc = "Go: Run current file" })
		keymap.set("n", "<leader>Gt", function()
			vim.cmd("split | terminal cd " .. dir .. " && go test .")
		end, { buffer = true, desc = "Go: Test package" })
		keymap.set("n", "<leader>Ga", function()
			vim.cmd("split | terminal cd " .. dir .. " && go test ./...")
		end, { buffer = true, desc = "Go: Test all" })
		keymap.set("n", "<leader>Gb", function()
			vim.cmd("split | terminal cd " .. dir .. " && go build .")
		end, { buffer = true, desc = "Go: Build" })
	end,
})
