local autocmd = vim.api.nvim_create_autocmd
local augroup = vim.api.nvim_create_augroup

autocmd("TextYankPost", {
	group = augroup("HighlightYank", { clear = true }),
	pattern = "*",
	callback = function()
		vim.highlight.on_yank({ higroup = "IncSearch", timeout = 150 })
	end,
	desc = "Flash yanked region",
})

autocmd("FileType", {
	group = augroup("CloseWithQ", { clear = true }),
	pattern = { "help", "qf", "man", "checkhealth" },
	callback = function(event)
		vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = event.buf, silent = true })
	end,
})

-- Trim trailing whitespace on save (markdown skipped: trailing 2-space = line break).
autocmd("BufWritePre", {
	group = augroup("TrimTrailingWS", { clear = true }),
	callback = function(ev)
		if vim.bo[ev.buf].filetype == "markdown" then
			return
		end
		local view = vim.fn.winsaveview()
		vim.cmd([[silent! keeppatterns %s/\s\+$//e]])
		vim.fn.winrestview(view)
	end,
	desc = "Trim trailing whitespace",
})

-- Auto-close terminal buffer when shell exits cleanly (Claude/shell toggleterm leftovers).
autocmd("TermClose", {
	group = augroup("AutoCloseTerm", { clear = true }),
	callback = function(ev)
		if vim.v.event.status == 0 then
			pcall(vim.api.nvim_buf_delete, ev.buf, {})
		end
	end,
	desc = "Wipe terminal buffer on clean exit",
})

-- After focus or leaving a terminal (e.g. Claude in toggleterm), pick up disk changes without :edit.
autocmd({ "FocusGained", "TermLeave", "TermClose" }, {
	group = augroup("config_autoread", { clear = true }),
	pattern = "*",
	callback = function()
		if vim.fn.getcmdwintype() == "" then
			vim.cmd("silent! checktime")
		end
	end,
	desc = "If file changed on disk, reload buffer when safe (see :help autoread)",
})

-- Notify when a buffer was reloaded from disk (so AI/external edits don't slip past silently).
autocmd("FileChangedShellPost", {
	group = augroup("config_reload_notify", { clear = true }),
	pattern = "*",
	callback = function(ev)
		local name = vim.fn.fnamemodify(ev.file, ":t")
		vim.notify(("Reloaded %s (changed on disk)"):format(name), vim.log.levels.INFO, { title = "autoread" })
	end,
	desc = "Toast when buffer reloads from disk",
})
