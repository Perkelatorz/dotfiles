return {
	"gbprod/substitute.nvim",
	event = { "BufReadPre", "BufNewFile" },
	config = function()
		local substitute = require("substitute")

		substitute.setup()

		-- set keymaps
		local keymap = vim.keymap -- for conciseness

		vim.keymap.set("n", "s", substitute.operator, { desc = "Substitute with motion" })
		vim.keymap.set("n", "ss", substitute.line, { desc = "Substitute line" })
		vim.keymap.set("n", "S", substitute.eol, { desc = "Substitute to end of line" })
		vim.keymap.set("x", "s", substitute.visual, { desc = "Substitute in visual mode" })
		vim.keymap.set("n", "<leader>s", require("substitute.range").operator, { desc = "Substitute range operator" })
		vim.keymap.set("x", "<leader>s", require("substitute.range").visual, { desc = "Substitute range visual" })
		vim.keymap.set("n", "<leader>ss", require("substitute.range").word, { desc = "Substitute word" })
	end,
}
