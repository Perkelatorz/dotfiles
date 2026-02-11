-- set leader key to space
vim.g.mapleader = " "

local keymap = vim.keymap -- for conciseness

---------------------
-- General Keymaps -------------------

-- use jk to exit insert mode
keymap.set("i", "jk", "<ESC>", { desc = "Exit insert mode with jk" })

-- clear search highlights
keymap.set("n", "<leader>nh", ":nohl<CR>", { desc = "Clear search highlights" })

-- increment/decrement numbers
keymap.set("n", "<leader>+", "<C-a>", { desc = "Increment number" }) -- increment
keymap.set("n", "<leader>=", "<C-x>", { desc = "Decrement number" }) -- decrement

-- Spell: toggle is our only custom bind; rest use Vim defaults ([s ]s z= zg zw zug)
keymap.set("n", "<leader>ts", ":set spell!<CR>", { desc = "Toggle spell check" })

-- colorscheme toggle
keymap.set("n", "<leader>ct", "<cmd>ColorschemeToggle<CR>", { desc = "Toggle colorscheme (custom/nightfox)" })

-- Better visual mode indenting (stay in visual mode after indent)
keymap.set("v", "<", "<gv", { desc = "Indent left and reselect" })
keymap.set("v", ">", ">gv", { desc = "Indent right and reselect" })

-- Move lines up/down in visual mode
keymap.set("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move selected lines down" })
keymap.set("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move selected lines up" })

-- Don't yank when pasting over selection in visual mode
keymap.set("v", "p", '"_dP', { desc = "Paste without yanking" })

-- Keep cursor centered when scrolling or searching (non-default but very useful)
keymap.set("n", "<C-d>", "<C-d>zz", { desc = "Scroll down half page and center" })
keymap.set("n", "<C-u>", "<C-u>zz", { desc = "Scroll up half page and center" })
keymap.set("n", "n", "nzzzv", { desc = "Next search result (centered)" })
keymap.set("n", "N", "Nzzzv", { desc = "Previous search result (centered)" })

-- Better buffer navigation (using [ and ] which is Vim convention)
keymap.set("n", "[b", ":bprevious<CR>", { desc = "Previous buffer" })
keymap.set("n", "]b", ":bnext<CR>", { desc = "Next buffer" })
keymap.set("n", "<leader>bd", ":bdelete<CR>", { desc = "Delete current buffer" })
keymap.set("n", "<leader>bx", ":bdelete!<CR>", { desc = "Force delete current buffer" })

-- Window resizing (using leader since default Vim doesn't have easy resize)
keymap.set("n", "<leader>w=", "<C-w>=", { desc = "Make windows equal size" })
keymap.set("n", "<leader>w|", "<C-w>|", { desc = "Maximize window width" })
keymap.set("n", "<leader>w_", "<C-w>_", { desc = "Maximize window height" })

-- Quick save (non-default but very useful)
keymap.set("n", "<leader>w", ":w<CR>", { desc = "Save file" })
keymap.set("n", "<leader>ww", ":wa<CR>", { desc = "Save all files" })

-- Quick quit
keymap.set("n", "<leader>q", ":q<CR>", { desc = "Quit window" })
keymap.set("n", "<leader>qq", ":q!<CR>", { desc = "Force quit window" })

-- Quickfix navigation (follows Vim [ ] convention)
keymap.set("n", "[q", ":cprev<CR>", { desc = "Previous quickfix item" })
keymap.set("n", "]q", ":cnext<CR>", { desc = "Next quickfix item" })
keymap.set("n", "[Q", ":cfirst<CR>", { desc = "First quickfix item" })
keymap.set("n", "]Q", ":clast<CR>", { desc = "Last quickfix item" })

-- Location list navigation
keymap.set("n", "[l", ":lprev<CR>", { desc = "Previous location list item" })
keymap.set("n", "]l", ":lnext<CR>", { desc = "Next location list item" })
keymap.set("n", "[L", ":lfirst<CR>", { desc = "First location list item" })
keymap.set("n", "]L", ":llast<CR>", { desc = "Last location list item" })

-- Diagnostic navigation (already have <leader>d for float, add navigation)
keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Previous diagnostic" })
keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Next diagnostic" })
keymap.set("n", "[D", function() vim.diagnostic.goto_prev({ severity = vim.diagnostic.severity.ERROR }) end, { desc = "Previous error" })
keymap.set("n", "]D", function() vim.diagnostic.goto_next({ severity = vim.diagnostic.severity.ERROR }) end, { desc = "Next error" })

-- Better command-line editing
keymap.set("c", "<C-a>", "<Home>", { desc = "Move to beginning of line" })
keymap.set("c", "<C-e>", "<End>", { desc = "Move to end of line" })

-- Terminal mode keymaps
keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })
keymap.set("t", "<C-h>", "<Cmd>wincmd h<CR>", { desc = "Move to left window from terminal" })
keymap.set("t", "<C-j>", "<Cmd>wincmd j<CR>", { desc = "Move to bottom window from terminal" })
keymap.set("t", "<C-k>", "<Cmd>wincmd k<CR>", { desc = "Move to top window from terminal" })
keymap.set("t", "<C-l>", "<Cmd>wincmd l<CR>", { desc = "Move to right window from terminal" })

-- Add undo breakpoints in insert mode (better granular undo)
keymap.set("i", ",", ",<C-g>u", { desc = "Add undo breakpoint at comma" })
keymap.set("i", ".", ".<C-g>u", { desc = "Add undo breakpoint at period" })
keymap.set("i", "!", "!<C-g>u", { desc = "Add undo breakpoint at exclamation" })
keymap.set("i", "?", "?<C-g>u", { desc = "Add undo breakpoint at question" })
keymap.set("i", ";", ";<C-g>u", { desc = "Add undo breakpoint at semicolon" })

-- Better search and replace (populate command with word under cursor)
keymap.set("n", "<leader>sr", [[:%s/\<<C-r><C-w>\>//g<Left><Left>]], { desc = "Search and replace word under cursor" })
keymap.set("v", "<leader>sr", [[:s/\<<C-r><C-w>\>//g<Left><Left>]], { desc = "Search and replace in selection" })

-- Tab management (gt/gT are default, adding leader shortcuts)
keymap.set("n", "<leader>tn", ":tabnew<CR>", { desc = "New tab" })
keymap.set("n", "<leader>tc", ":tabclose<CR>", { desc = "Close tab" })
keymap.set("n", "<leader>to", ":tabonly<CR>", { desc = "Close other tabs" })
keymap.set("n", "<leader>tp", ":tabprevious<CR>", { desc = "Previous tab" })
keymap.set("n", "<leader>tj", ":tabnext<CR>", { desc = "Next tab" })
keymap.set("n", "<leader>tm", ":tabmove ", { desc = "Move tab to position" })
keymap.set("n", "<leader>t1", "1gt", { desc = "Go to tab 1" })
keymap.set("n", "<leader>t2", "2gt", { desc = "Go to tab 2" })
keymap.set("n", "<leader>t3", "3gt", { desc = "Go to tab 3" })
keymap.set("n", "<leader>t4", "4gt", { desc = "Go to tab 4" })
keymap.set("n", "<leader>t5", "5gt", { desc = "Go to tab 5" })

-- Marks navigation (built-in but document for which-key)
keymap.set("n", "'", "'", { desc = "Jump to mark (line)" })
keymap.set("n", "`", "`", { desc = "Jump to mark (exact)" })
keymap.set("n", "m", "m", { desc = "Set mark" })

-- Better macro recording feedback
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

-- Case conversion shortcuts
keymap.set("n", "<leader>gu", "gUiw", { desc = "Uppercase word" })
keymap.set("n", "<leader>gl", "guiw", { desc = "Lowercase word" })
keymap.set("n", "<leader>g~", "g~iw", { desc = "Toggle case word" })
keymap.set("v", "<leader>gu", "gU", { desc = "Uppercase selection" })
keymap.set("v", "<leader>gl", "gu", { desc = "Lowercase selection" })
keymap.set("v", "<leader>g~", "g~", { desc = "Toggle case selection" })

-- Number format conversion (increment/decrement in different bases)
keymap.set("n", "<leader>nx", ":%!xxd<CR>", { desc = "Convert to hex view" })
keymap.set("n", "<leader>nr", ":%!xxd -r<CR>", { desc = "Revert hex view" })

-- Better diff shortcuts
keymap.set("n", "<leader>dt", ":diffthis<CR>", { desc = "Diff this buffer" })
keymap.set("n", "<leader>do", ":diffoff<CR>", { desc = "Turn off diff" })
keymap.set("n", "<leader>du", ":diffupdate<CR>", { desc = "Update diff" })

-- Quick edit config
keymap.set("n", "<leader>ev", ":e $MYVIMRC<CR>", { desc = "Edit init.lua" })
keymap.set("n", "<leader>sv", ":source $MYVIMRC<CR>", { desc = "Source init.lua" })

-- File reload and version control (for AI tool changes)
keymap.set("n", "<leader>rr", ":checktime<CR>", { desc = "Reload all buffers from disk" })
keymap.set("n", "<leader>uu", ":earlier 1f<CR>", { desc = "Undo to previous file save" })

-- Checkpoint system (for AI tool multi-edit sessions)
-- Using <leader>v prefix (v for "version control" / "versions")
keymap.set("n", "<leader>vc", function() require("nvim.core.checkpoint").create_checkpoint() end, { desc = "Create checkpoint" })
keymap.set("n", "<leader>vr", function() require("nvim.core.checkpoint").restore_checkpoint() end, { desc = "Restore checkpoint" })
keymap.set("n", "<leader>vd", function() require("nvim.core.checkpoint").show_diff() end, { desc = "Diff with checkpoint" })
keymap.set("n", "<leader>vx", function() require("nvim.core.checkpoint").delete_checkpoint() end, { desc = "Delete checkpoint" })

-- Session checkpoint (for multi-file AI edits)
keymap.set("n", "<leader>vh", function() require("nvim.core.checkpoint").create_session_checkpoint() end, { desc = "Checkpoint open files" })
keymap.set("n", "<leader>vj", function() require("nvim.core.checkpoint").create_project_checkpoint() end, { desc = "Checkpoint entire project" })
keymap.set("n", "<leader>vk", function() require("nvim.core.checkpoint").restore_session_checkpoint() end, { desc = "Restore all files" })
keymap.set("n", "<leader>vl", function() require("nvim.core.checkpoint").show_session_diff() end, { desc = "Show all changes" })

-- Toggle relative number
keymap.set("n", "<leader>tr", ":set relativenumber!<CR>", { desc = "Toggle relative numbers" })

-- Toggle wrap
keymap.set("n", "<leader>tw", ":set wrap!<CR>", { desc = "Toggle line wrap" })

-- Toggle list (show whitespace)
keymap.set("n", "<leader>tl", ":set list!<CR>", { desc = "Toggle show whitespace" })

-- Yank path to clipboard (y = yank; f reserved for Find/Telescope)
keymap.set("n", "<leader>yp", ':let @+ = expand("%:p")<CR>:echo "Copied: " . expand("%:p")<CR>', { desc = "Yank full path" })
keymap.set("n", "<leader>yr", ':let @+ = expand("%")<CR>:echo "Copied: " . expand("%")<CR>', { desc = "Yank relative path" })
keymap.set("n", "<leader>yn", ':let @+ = expand("%:t")<CR>:echo "Copied: " . expand("%:t")<CR>', { desc = "Yank filename" })

-- Terminal (z = shell/terminal; keeps t for tabs/toggles/spell only)
keymap.set("n", "<leader>zt", function() require("nvim.core.terminal").toggle_horizontal() end, { desc = "Toggle terminal" })
keymap.set("t", "<leader>zt", "<C-\\><C-n>:lua require('nvim.core.terminal').toggle_horizontal()<CR>", { desc = "Toggle terminal" })
keymap.set("n", "<leader>zf", function() require("nvim.core.terminal").toggle_float() end, { desc = "Toggle floating terminal" })
keymap.set("n", "<leader>zv", function() require("nvim.core.terminal").toggle_vertical() end, { desc = "Toggle vertical terminal" })
keymap.set("n", "<leader>zx", function() require("nvim.core.terminal").close_all() end, { desc = "Shutdown all terminals" })

-- Go: run/test/build (buffer-local, <leader>G = Go)
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
		end, { buffer = true, desc = "Go: Test current package" })
		keymap.set("n", "<leader>Ga", function()
			vim.cmd("split | terminal cd " .. dir .. " && go test ./...")
		end, { buffer = true, desc = "Go: Test all packages" })
		keymap.set("n", "<leader>Gb", function()
			vim.cmd("split | terminal cd " .. dir .. " && go build .")
		end, { buffer = true, desc = "Go: Build current package" })
	end,
})

