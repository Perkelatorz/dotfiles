local keymap = vim.keymap

keymap.set("i", "jk", "<ESC>", { desc = "Exit insert mode" })

keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear search highlights" })

keymap.set("n", "<C-s>", "<cmd>write<CR>", { desc = "Save file" })

keymap.set("n", "<leader>ct", "<cmd>ColorschemeToggle<CR>", { desc = "Toggle colorscheme" })

keymap.set("n", "[b", "<cmd>bprevious<CR>", { desc = "Previous buffer" })
keymap.set("n", "]b", "<cmd>bnext<CR>", { desc = "Next buffer" })
keymap.set("n", "<leader>bd", "<cmd>bdelete<CR>", { desc = "Delete buffer" })

keymap.set("n", "<leader>q", "<cmd>quit<CR>", { desc = "Quit window" })
keymap.set("n", "<leader>Q", "<cmd>quit!<CR>", { desc = "Force quit" })

keymap.set("n", "<leader>ev", "<cmd>edit $MYVIMRC<CR>", { desc = "Edit config" })

-- Move focus between splits (and Neo-tree ↔ code without leaving the keyboard).
keymap.set("n", "<C-h>", "<C-w>h", { desc = "Window focus left" })
keymap.set("n", "<C-j>", "<C-w>j", { desc = "Window focus down" })
keymap.set("n", "<C-k>", "<C-w>k", { desc = "Window focus up" })
keymap.set("n", "<C-l>", "<C-w>l", { desc = "Window focus right" })
keymap.set("n", "<leader>wp", "<C-w>p", { desc = "Window previous (last focused)" })

-- Diagnostics (global; Trouble still available under <leader>x).
keymap.set("n", "]d", function()
	vim.diagnostic.jump({ count = 1, float = true })
end, { desc = "Next diagnostic" })
keymap.set("n", "[d", function()
	vim.diagnostic.jump({ count = -1, float = true })
end, { desc = "Previous diagnostic" })
keymap.set("n", "<leader>df", vim.diagnostic.open_float, { desc = "Diagnostic float" })
keymap.set("n", "<leader>dl", vim.diagnostic.setloclist, { desc = "Diagnostics → location list" })

-- Keep cursor centered on search results and after half-page jumps.
keymap.set("n", "n", "nzzzv", { desc = "Next search (centered)" })
keymap.set("n", "N", "Nzzzv", { desc = "Prev search (centered)" })
keymap.set("n", "<C-d>", "<C-d>zz", { desc = "Half page down (centered)" })
keymap.set("n", "<C-u>", "<C-u>zz", { desc = "Half page up (centered)" })

-- Join lines without moving cursor.
keymap.set("n", "J", "mzJ`z", { desc = "Join lines (keep cursor)" })

-- Keep selection after indent shift.
keymap.set("x", "<", "<gv", { desc = "Shift left, reselect" })
keymap.set("x", ">", ">gv", { desc = "Shift right, reselect" })

keymap.set("n", "Q", "<nop>", { desc = "Disable ex mode" })
keymap.set("n", "*", "mz*`z", { desc = "Search word (keep cursor)" })
keymap.set("x", "p", [["_dP]], { desc = "Paste without overwriting register" })

-- Errors-only diagnostic nav (skip warns/hints when triaging AI-introduced regressions).
keymap.set("n", "]e", function()
	vim.diagnostic.jump({ count = 1, severity = vim.diagnostic.severity.ERROR, float = true })
end, { desc = "Next error" })
keymap.set("n", "[e", function()
	vim.diagnostic.jump({ count = -1, severity = vim.diagnostic.severity.ERROR, float = true })
end, { desc = "Previous error" })

-- Agentic helpers: review external edits, reload buffer, restart LSP.
-- <leader>cd: diff current buffer vs git index (shows Claude's unstaged edits even after autoread).
keymap.set("n", "<leader>cd", function()
	local ok, gs = pcall(require, "gitsigns")
	if ok then
		gs.diffthis()
	else
		vim.notify("gitsigns not loaded", vim.log.levels.WARN)
	end
end, { desc = "Diff buffer vs git index" })
-- <leader>cD: diff against HEAD (all changes since last commit).
keymap.set("n", "<leader>cD", function()
	local ok, gs = pcall(require, "gitsigns")
	if ok then
		gs.diffthis("HEAD")
	else
		vim.notify("gitsigns not loaded", vim.log.levels.WARN)
	end
end, { desc = "Diff buffer vs HEAD" })
keymap.set("n", "<leader>cr", "<cmd>checktime<CR>", { desc = "Reload buffer from disk" })
keymap.set("n", "<leader>cL", "<cmd>LspRestart<CR>", { desc = "Restart LSP (after external edits)" })
