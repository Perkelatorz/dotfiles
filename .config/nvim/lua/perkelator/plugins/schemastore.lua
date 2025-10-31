return {
	"b0o/schemastore.nvim",
	lazy = true,
	config = function()
		require("lspconfig").jsonls.setup({
			settings = {
				json = {
					schemas = require("schemastore").json.schemas(),
					validate = { enable = true },
				},
			},
		})

		require("lspconfig").yamlls.setup({
			settings = {
				yaml = {
					schemaStore = {
						enable = false,
						url = "",
					},
					schemas = require("schemastore").yaml.schemas(),
					validate = true,
					completion = true,
					hover = true,
					format = {
						enable = true,
					},
					customTags = {
						"!reference sequence",
						"!vault",
					},
				},
			},
		})
	end,
}
