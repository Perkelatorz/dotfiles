return {
	"leoluz/nvim-dap-go",
	ft = "go",
	dependencies = {
		"mfussenegger/nvim-dap",
	},
	config = function()
		local utils = require("nvim.core.utils")
		
		local dap_go, dap_go_ok = utils.safe_require("dap-go")
		if not dap_go_ok then
			return
		end

		dap_go.setup({
			dap_configurations = {
				{
					type = "go",
					name = "Attach remote",
					mode = "remote",
					request = "attach",
				},
			},
			delve = {
				path = "dlv",
				initialize_timeout_sec = 20,
				port = "${port}",
				args = {},
				build_flags = "",
				detached = true,
				cwd = nil,
			},
		})

		local keymap = vim.keymap

		keymap.set("n", "<leader>dgt", function()
			dap_go.debug_test()
		end, { desc = "Debug Go test" })

		keymap.set("n", "<leader>dgl", function()
			dap_go.debug_last_test()
		end, { desc = "Debug last Go test" })
	end,
}
