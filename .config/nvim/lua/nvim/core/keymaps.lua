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

-- spelling check
keymap.set("n", "<leader>sc", ":set spell!<CR>", { desc = "Spell Check" })

-- colorscheme toggle
keymap.set("n", "<leader>ct", "<cmd>ColorschemeToggle<CR>", { desc = "Toggle colorscheme (custom/nightfox)" })

