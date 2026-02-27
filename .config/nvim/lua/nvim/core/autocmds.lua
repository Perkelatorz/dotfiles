local autocmd = vim.api.nvim_create_autocmd
local augroup = vim.api.nvim_create_augroup

autocmd("TextYankPost", {
	group = augroup("HighlightYank", { clear = true }),
	pattern = "*",
	callback = function()
		vim.highlight.on_yank({ higroup = "IncSearch", timeout = 200 })
	end,
	desc = "Highlight yanked text",
})

autocmd("BufWritePre", {
	group = augroup("TrimWhitespace", { clear = true }),
	pattern = "*",
	callback = function()
		local save_cursor = vim.fn.getpos(".")
		vim.cmd([[%s/\s\+$//e]])
		vim.fn.setpos(".", save_cursor)
	end,
	desc = "Trim trailing whitespace on save",
})

autocmd({ "FocusGained", "BufEnter", "CursorHold", "CursorHoldI", "TermClose", "TermLeave" }, {
	group = augroup("AutoReload", { clear = true }),
	callback = function()
		if vim.fn.mode() ~= "c" and vim.o.buftype ~= "nofile" then
			local current_win = vim.api.nvim_get_current_win()

			vim.cmd("checktime")

			if vim.api.nvim_get_current_win() ~= current_win and vim.api.nvim_win_is_valid(current_win) then
				vim.api.nvim_set_current_win(current_win)
			end
		end
	end,
	desc = "Auto-reload files when changed externally (AI tools)",
})

autocmd("FileChangedShell", {
	group = augroup("FileChangedWarning", { clear = true }),
	callback = function()
		local checkpoint = require("nvim.core.checkpoint")
		checkpoint.auto_checkpoint(vim.api.nvim_get_current_buf())
		
		vim.notify(
			"⚠️  File changed on disk!\n📌 Auto-checkpoint created\nReloading...",
			vim.log.levels.WARN,
			{ title = "External Change Detected", timeout = 2000 }
		)
	end,
	desc = "Auto-checkpoint before file reload",
})

autocmd("FileChangedShellPost", {
	group = augroup("FileChangedNotification", { clear = true }),
	callback = function()
		local bufnr = vim.api.nvim_get_current_buf()
		local filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(bufnr), ":t")
		
		local current_win = vim.api.nvim_get_current_win()

		vim.notify(
			string.format("✨ %s reloaded (checkpoint saved)\n<leader>vr to undo | <leader>vd to diff", filename),
			vim.log.levels.INFO,
			{ 
				title = "AI Edit",
				timeout = 3000,
			}
		)
		
		vim.schedule(function()
			if vim.api.nvim_win_is_valid(current_win) then
				vim.api.nvim_set_current_win(current_win)
			end
		end)
		
		vim.b[bufnr].file_reloaded = true
		vim.defer_fn(function()
			vim.b[bufnr].file_reloaded = nil
		end, 3000)
	end,
	desc = "Show notification when file reloads from disk",
})

autocmd("VimResized", {
	group = augroup("ResizeSplits", { clear = true }),
	callback = function()
		local current_tab = vim.fn.tabpagenr()
		vim.cmd("tabdo wincmd =")
		vim.cmd("tabnext " .. current_tab)
	end,
	desc = "Resize splits on window resize",
})

autocmd("FileType", {
	group = augroup("CloseWithQ", { clear = true }),
	pattern = {
		"help",
		"lspinfo",
		"man",
		"notify",
		"qf",
		"query",
		"checkhealth",
		"startuptime",
	},
	callback = function(event)
		vim.bo[event.buf].buflisted = false
		vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = event.buf, silent = true, desc = "Close window" })
	end,
	desc = "Close certain filetypes with 'q'",
})

autocmd("FileType", {
	group = augroup("QuickfixWrap", { clear = true }),
	pattern = "qf",
	callback = function()
		vim.opt_local.wrap = true
	end,
	desc = "Enable line wrap in quickfix",
})

autocmd("BufEnter", {
	group = augroup("DisableAutoComment", { clear = true }),
	pattern = "*",
	callback = function()
		vim.opt_local.formatoptions:remove({ "c", "r", "o" })
	end,
	desc = "Disable automatic comment insertion",
})

autocmd({ "InsertEnter" }, {
	group = augroup("LineNumbersInsert", { clear = true }),
	pattern = "*",
	callback = function()
		if vim.wo.number then
			vim.wo.relativenumber = false
		end
	end,
	desc = "Show absolute line numbers in insert mode",
})

autocmd({ "InsertLeave" }, {
	group = augroup("LineNumbersNormal", { clear = true }),
	pattern = "*",
	callback = function()
		if vim.wo.number then
			vim.wo.relativenumber = true
		end
	end,
	desc = "Show relative line numbers in normal mode",
})

autocmd("InsertLeave", {
	group = augroup("PasteModeLeave", { clear = true }),
	pattern = "*",
	callback = function()
		vim.opt.paste = false
	end,
	desc = "Disable paste mode when leaving insert mode",
})

autocmd("BufWritePre", {
	group = augroup("CreateParentDirs", { clear = true }),
	pattern = "*",
	callback = function(event)
		if event.match:match("^%w%w+:[\\/][\\/]") then
			return
		end
		local file = vim.uv.fs_realpath(event.match) or event.match
		vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
	end,
	desc = "Create parent directories if they don't exist",
})

autocmd("TermOpen", {
	group = augroup("TerminalSettings", { clear = true }),
	pattern = "*",
	callback = function()
		vim.opt_local.number = false
		vim.opt_local.relativenumber = false
		vim.opt_local.signcolumn = "no"
		vim.opt_local.scrolloff = 0
		vim.cmd("startinsert")
	end,
	desc = "Configure terminal buffer settings",
})

autocmd("BufReadPost", {
	group = augroup("LastLocation", { clear = true }),
	pattern = "*",
	callback = function(event)
		local exclude_ft = { "gitcommit", "gitrebase", "svn", "hgcommit" }
		local buf = event.buf
		if vim.tbl_contains(exclude_ft, vim.bo[buf].filetype) or vim.b[buf].last_location then
			return
		end
		vim.b[buf].last_location = true
		local mark = vim.api.nvim_buf_get_mark(buf, '"')
		local lcount = vim.api.nvim_buf_line_count(buf)
		if mark[1] > 0 and mark[1] <= lcount then
			pcall(vim.api.nvim_win_set_cursor, 0, mark)
		end
	end,
	desc = "Go to last location when opening a buffer",
})

autocmd("FileType", {
	group = augroup("SpellCheck", { clear = true }),
	pattern = { "gitcommit", "markdown", "text" },
	callback = function()
		vim.opt_local.spell = true
	end,
	desc = "Enable spell checking for text-like files",
})

autocmd({ "BufRead", "BufNewFile" }, {
	group = augroup("ShebangDetection", { clear = true }),
	pattern = "*",
	callback = function()
		local line1 = vim.fn.getline(1)
		if line1:match("^#!.*/bash") or line1:match("^#!.*/env%s+bash") then
			vim.bo.filetype = "bash"
		end
	end,
	desc = "Detect bash from shebang",
})

autocmd("BufReadPre", {
	group = augroup("LargeFile", { clear = true }),
	pattern = "*",
	callback = function(event)
		local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(event.buf))
		if ok and stats and stats.size > 1024000 then
			vim.b[event.buf].large_file = true
			vim.opt_local.swapfile = false
			vim.opt_local.foldmethod = "manual"
			vim.opt_local.undolevels = -1
			vim.opt_local.undoreload = 0
			vim.opt_local.list = false
			vim.cmd("syntax off")
			vim.notify("Large file detected, some features disabled for performance", vim.log.levels.WARN)
		end
	end,
	desc = "Optimize settings for large files",
})

autocmd("BufReadPost", {
	group = augroup("BinaryFile", { clear = true }),
	pattern = "*",
	callback = function()
		if vim.bo.binary then
			vim.opt_local.number = false
			vim.opt_local.relativenumber = false
			vim.opt_local.list = false
			vim.opt_local.wrap = false
			vim.cmd("syntax off")
		end
	end,
	desc = "Configure binary file display",
})

autocmd("BufReadPost", {
	group = augroup("ReadOnlyFile", { clear = true }),
	pattern = "*",
	callback = function()
		if vim.bo.readonly then
			vim.notify("File is read-only", vim.log.levels.INFO)
			vim.keymap.set("n", "q", ":q<CR>", { buffer = true, silent = true, desc = "Close read-only file" })
		end
	end,
	desc = "Better handling for read-only files",
})
