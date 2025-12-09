return {
	"olimorris/codecompanion.nvim",
	-- Prepared for v18 - no version pin, will auto-update
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-treesitter/nvim-treesitter",
		"nvim-telescope/telescope.nvim",
	},
	config = function()
		-- Load secrets from file if it exists, otherwise use env vars
		local secrets = {}
		local secrets_path = vim.fn.stdpath("config") .. "/secrets.lua"
		if vim.fn.filereadable(secrets_path) == 1 then
			secrets = dofile(secrets_path)
		end

		-- Helper function to get API key from secrets file or env var
		local function get_api_key(key_name)
			return secrets[key_name] or os.getenv(key_name) or key_name
		end

		local utils = require("nvim.core.utils")
		
		local codecompanion, codecompanion_ok = utils.safe_require("codecompanion")
		if not codecompanion_ok then
			return
		end

		-- Configuration prepared for v18 compatibility
		-- If v18 has breaking changes, this will need updates
		local ok, result = pcall(function()
			return codecompanion.setup({
				strategies = {
					chat = {
						adapter = "anthropic",
					},
					inline = {
						adapter = "anthropic",
					},
				},
				adapters = {
					http = {
						anthropic = function()
							return require("codecompanion.adapters").extend("anthropic", {
								env = {
									api_key = get_api_key("ANTHROPIC_API_KEY"),
								},
							})
						end,
					},
				},
				display = {
					chat = {
						window = {
							layout = "vertical",
							width = 0.45,
							height = 0.8,
							relative = "editor",
							border = "rounded",
						},
					},
					inline = {
						diff = {
							enabled = true,
							close_chat_at = 240,
						},
					},
				},
				opts = {
					log_level = "ERROR",
				},
			})
		end)

		if not ok then
			vim.notify("CodeCompanion setup failed - may need v18 migration. Error: " .. tostring(result), vim.log.levels.WARN)
		end

		-- set keymaps
		local keymap = vim.keymap

		keymap.set({ "n", "v" }, "<leader>aa", "<cmd>CodeCompanionActions<cr>", { desc = "CodeCompanion actions" })
		keymap.set({ "n", "v" }, "<leader>ac", "<cmd>CodeCompanionChat Toggle<cr>", { desc = "Toggle CodeCompanion chat" })
		keymap.set("v", "<leader>ai", "<cmd>CodeCompanionChat Add<cr>", { desc = "Add selection to chat" })
		keymap.set("n", "<leader>at", "<cmd>CodeCompanionChat<cr>", { desc = "Open CodeCompanion chat" })
		keymap.set({ "n", "v" }, "<leader>ap", "<cmd>CodeCompanion<cr>", { desc = "Inline CodeCompanion prompt" })

		-- Expand 'cc' into 'CodeCompanion' in the command line
		vim.cmd([[cab cc CodeCompanion]])
	end,
}
