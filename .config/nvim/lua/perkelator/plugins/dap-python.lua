return {
	"mfussenegger/nvim-dap-python",
	ft = "python",
	dependencies = {
		"mfussenegger/nvim-dap",
	},
	config = function()
		local dap_python = require("dap-python")
		
		local mason_path = vim.fn.stdpath("data") .. "/mason/packages/debugpy/venv/bin/python"
		dap_python.setup(mason_path)

		dap_python.test_runner = "pytest"

		local keymap = vim.keymap

		keymap.set("n", "<leader>dpt", dap_python.test_method, { desc = "Debug Python test method" })
		keymap.set("n", "<leader>dpc", dap_python.test_class, { desc = "Debug Python test class" })
		keymap.set("v", "<leader>dps", dap_python.debug_selection, { desc = "Debug Python selection" })
	end,
}
