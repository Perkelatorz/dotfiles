return {
	"mistweaverco/kulala.nvim",
	ft = "http",
	config = function()
		local utils = require("nvim.core.utils")
		
		local kulala, kulala_ok = utils.safe_require("kulala")
		if not kulala_ok then
			return
		end

		kulala.setup({
			default_view = "body",
			default_env = "dev",
			debug = false,
			contenttypes = {
				["application/json"] = {
					ft = "json",
					formatter = { "jq", "." },
				},
				["application/xml"] = {
					ft = "xml",
					formatter = { "xmllint", "--format", "-" },
				},
				["text/html"] = {
					ft = "html",
					formatter = { "xmllint", "--format", "--html", "-" },
				},
			},
			show_icons = "on_request",
			icons = {
				inlay = {
					loading = "⏳",
					done = "✅",
					error = "❌",
				},
				lualine = "🐼",
			},
			additional_curl_options = {},
			scratchpad_default_contents = {
				"@MY_TOKEN_NAME=my_token_value",
				"",
				"# @name scratchpad",
				"POST https://httpbin.org/post HTTP/1.1",
				"accept: application/json",
				"content-type: application/json",
				"",
				"{",
				'  "foo": "bar"',
				"}",
			},
			winbar = false,
			default_winbar_panes = { "body", "headers", "headers_body" },
		})

		local keymap = vim.keymap

		keymap.set("n", "<leader>kr", kulala.run, { desc = "Run HTTP request" })
		keymap.set("n", "<leader>kt", kulala.toggle_view, { desc = "Toggle HTTP view" })
		keymap.set("n", "<leader>kp", kulala.jump_prev, { desc = "Jump to previous request" })
		keymap.set("n", "<leader>kn", kulala.jump_next, { desc = "Jump to next request" })
		keymap.set("n", "<leader>ki", kulala.inspect, { desc = "Inspect HTTP request" })
		keymap.set("n", "<leader>kc", kulala.copy, { desc = "Copy as cURL" })
		keymap.set("n", "<leader>ks", kulala.scratchpad, { desc = "Open HTTP scratchpad" })
		keymap.set("n", "<leader>kq", kulala.close, { desc = "Close HTTP view" })
	end,
}
