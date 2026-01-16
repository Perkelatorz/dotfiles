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

		-- HTTP/REST client keybindings (under <leader>H - capital H for HTTP)
		keymap.set("n", "<leader>Hr", kulala.run, { desc = "Run HTTP request" })
		keymap.set("n", "<leader>Ht", kulala.toggle_view, { desc = "Toggle HTTP view" })
		keymap.set("n", "<leader>H[", kulala.jump_prev, { desc = "Previous request" })
		keymap.set("n", "<leader>H]", kulala.jump_next, { desc = "Next request" })
		keymap.set("n", "<leader>Hi", kulala.inspect, { desc = "Inspect request" })
		keymap.set("n", "<leader>Hc", kulala.copy, { desc = "Copy as cURL" })
		keymap.set("n", "<leader>Hs", kulala.scratchpad, { desc = "HTTP scratchpad" })
		keymap.set("n", "<leader>Hq", kulala.close, { desc = "Close HTTP view" })
	end,
}
