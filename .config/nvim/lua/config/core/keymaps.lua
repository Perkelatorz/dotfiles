local keymap = vim.keymap

keymap.set("i", "jk", "<ESC>", { desc = "Exit insert mode" })

keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear search highlights" })

keymap.set("n", "<C-s>", "<cmd>write<CR>", { desc = "Save file" })

keymap.set("n", "<leader>ct", "<cmd>ColorschemeToggle<CR>", { desc = "Toggle colorscheme" })

keymap.set("n", "[b", "<cmd>bprevious<CR>", { desc = "Previous buffer" })
keymap.set("n", "]b", "<cmd>bnext<CR>", { desc = "Next buffer" })
keymap.set("n", "<leader>bd", "<cmd>bdelete<CR>", { desc = "Delete buffer" })

-- Context-aware quit. Plain |:q|, |ZZ| and |ZQ| are untouched — this is a <Leader> map,
-- not a built-in, so it is free to be clever. It dismisses whatever you are looking at:
--
--   terminal    → :bdelete!  (a Glow pager from <Leader>mp; nothing to save)
--   float       → close the floating window
--   side panel  → :close     (neo-tree, Trouble, help, quickfix, …)
--   real file   → :quit      (`confirm` is on, so unsaved changes prompt rather than vanish)
--
-- NOTE: <Leader> is a literal space, so this cannot fire from terminal *insert* mode —
-- the job needs that key. Press <C-\><C-n> first.
local PANEL_FILETYPES = {
	["neo-tree"] = true,
	["neo-tree-popup"] = true,
	["trouble"] = true,
	["help"] = true,
	["qf"] = true,
	["checkhealth"] = true,
	["man"] = true,
	["lspinfo"] = true,
	["mason"] = true,
	["notify"] = true,
	["DiffviewFiles"] = true,
	["DiffviewFileHistory"] = true,
	["gitsigns-blame"] = true,
}

local function context_quit()
	local buf = vim.api.nvim_get_current_buf()
	local win = vim.api.nvim_get_current_win()
	local ft = vim.bo[buf].filetype
	local bt = vim.bo[buf].buftype

	-- Terminal buffers here are one-shot pagers (Glow). Wipe them rather than :close, so
	-- they do not pile up in the buffer list.
	if bt == "terminal" then
		vim.cmd("bdelete!")
		return
	end

	-- Floating windows (LSP hover, notify history, plugin popups) close, never :quit.
	if vim.api.nvim_win_get_config(win).relative ~= "" then
		pcall(vim.api.nvim_win_close, win, false)
		return
	end

	if PANEL_FILETYPES[ft] or bt == "help" or bt == "quickfix" or bt == "nofile" then
		vim.cmd("close")
		return
	end

	-- Last window holding a real file: :quit exits Nvim, exactly as it always has.
	vim.cmd("quit")
end

keymap.set("n", "<leader>q", context_quit, { desc = "Quit (context-aware)" })
keymap.set("n", "<leader>Q", "<cmd>quit!<CR>", { desc = "Force quit (discard changes)" })

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

-- ---------------------------------------------------------------------------
-- Default Vim keys are deliberately left alone below this line.
--
-- This config used to remap n/N, <C-d>/<C-u>, J, *, visual </>, visual p and Q.
-- They were removed on purpose: each one shadowed a built-in with a slightly
-- different behaviour, which is a bad trade while learning Vim proper. The Vim
-- way to get the same results, for reference:
--
--   centering        zz (center) · zt (top) · zb (bottom) — after n, <C-d>, …
--   join, keep pos   mzJ`z by hand, or just J and move back
--   paste over sel.  "0p  (paste the yank register; plain p consumes it)
--   repeat indent    3>>  ·  gv  to reselect  ·  .  to repeat
--   search word      *  ·  #     (N.B. these move the cursor, by design)
--   Q                repeats the last recorded register (Nvim), not Ex mode
--
-- Keys still remapped are ones that either add a superset of the built-in
-- behaviour (flash's f/t) or bind something Vim leaves unused (<Esc>, <C-s>).
-- ---------------------------------------------------------------------------

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
