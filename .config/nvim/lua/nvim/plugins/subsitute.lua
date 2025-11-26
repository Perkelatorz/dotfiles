return {
	"gbprod/substitute.nvim",
	event = { "BufReadPre", "BufNewFile" },
	config = function()
		local utils = require("nvim.core.utils")
		
		local substitute, sub_ok = utils.safe_require("substitute")
		if not sub_ok then
			return
		end

		substitute.setup()

		-- set keymaps (using 'gs' prefix to avoid overriding defaults)
		local keymap = vim.keymap -- for conciseness

		keymap.set("n", "gs", substitute.operator, { desc = "Substitute with motion" })
		keymap.set("n", "gss", substitute.line, { desc = "Substitute line" })
		keymap.set("n", "gsS", substitute.eol, { desc = "Substitute to end of line" })
		keymap.set("x", "gs", substitute.visual, { desc = "Substitute in visual mode" })
		local range, range_ok = utils.safe_require("substitute.range")
		if range_ok then
			keymap.set("n", "<leader>s", range.operator, { desc = "Substitute range operator" })
			keymap.set("x", "<leader>s", range.visual, { desc = "Substitute range visual" })
			keymap.set("n", "<leader>ss", range.word, { desc = "Substitute word" })
		end
	end,
}
