--- Built-in |spell| tuned for prose + personal word list.
--- |mapleader| is set in |config.core.options| before this file runs so |<Leader>s| maps bind to space.
--- Personal good-words file: |zg| on a word adds it to |spellfile| (sync via yadm if you want).
--- Fixes: |z=| (which-key can show a nicer list for z=), insert |i_CTRL-X_s|.
--- First run: Neovim may prompt to download the |en_us| dictionary once (|spelllang|).

local M = {}

local prose_ft = {
	"markdown",
	"gitcommit",
	"gitrebase",
	"text",
	"typst",
	"mail",
}

function M.setup()
	local dir = vim.fn.stdpath("config") .. "/spell"
	vim.fn.mkdir(dir, "p")

	local addfile = dir .. "/en.utf-8.add"
	if vim.fn.filereadable(addfile) == 0 then
		vim.fn.writefile({}, addfile)
	end

	vim.opt.spellfile = addfile
	vim.opt.spelllang = { "en_us" }
	-- Fewer false “capitalize after .” flags (still underlines unknown words).
	vim.opt.spellcapcheck = ""

	local group = vim.api.nvim_create_augroup("config_spell", { clear = true })

	vim.api.nvim_create_autocmd("FileType", {
		group = group,
		pattern = prose_ft,
		callback = function()
			vim.opt_local.spell = true
			vim.opt_local.spelloptions:append("camel")
			vim.opt_local.complete:append("kspell")
		end,
		desc = "Enable spell for prose buffers",
	})

	vim.keymap.set("n", "<leader>ss", function()
		vim.wo.spell = not vim.wo.spell
	end, { desc = "Toggle spell (window)" })

	vim.keymap.set("n", "<leader>sz", "z=", { desc = "Spell suggestions (z=)" })
	vim.keymap.set("n", "<leader>sg", "zg", { desc = "Spell: mark good word" })
	vim.keymap.set("n", "<leader>sw", "zw", { desc = "Spell: mark bad word" })
	vim.keymap.set("n", "<leader>sn", "]s", { desc = "Next misspelled word" })
	vim.keymap.set("n", "<leader>sp", "[s", { desc = "Previous misspelled word" })
end

return M
