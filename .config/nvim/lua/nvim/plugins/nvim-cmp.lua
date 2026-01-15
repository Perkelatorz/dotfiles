return {
	"hrsh7th/nvim-cmp",
	event = "InsertEnter",
	dependencies = {
		"hrsh7th/cmp-buffer", -- source for text in buffer
		"hrsh7th/cmp-path", -- source for file system paths
		{
			"L3MON4D3/LuaSnip",
			-- follow latest release.
			version = "v2.*", -- Replace <CurrentMajor> by the latest released major (first number of latest release)
			-- install jsregexp (optional!).
			build = "make install_jsregexp",
		},
		"saadparwaiz1/cmp_luasnip", -- for autocompletion
		"rafamadriz/friendly-snippets", -- useful snippets
		"onsails/lspkind.nvim", -- vs-code like pictograms
		"Exafunction/codeium.nvim", -- AI completion (Windsurf/Codeium)
		"hrsh7th/cmp-nvim-lsp", -- LSP completion source
	},
	config = function()
		local utils = require("nvim.core.utils")
		
		local cmp, cmp_ok = utils.safe_require("cmp")
		if not cmp_ok then
			return
		end

		local luasnip, luasnip_ok = utils.safe_require("luasnip")
		if not luasnip_ok then
			return
		end

		local lspkind, lspkind_ok = utils.safe_require("lspkind")
		if not lspkind_ok then
			return
		end

		-- loads vscode style snippets from installed plugins (e.g. friendly-snippets)
		local vscode_loader, vscode_loader_ok = utils.safe_require("luasnip.loaders.from_vscode")
		if vscode_loader_ok and vscode_loader then
			vscode_loader.lazy_load()
		end

		cmp.setup({
			completion = {
				completeopt = "menu,menuone,preview,noselect",
			},
			snippet = { -- configure how nvim-cmp interacts with snippet engine
				expand = function(args)
					luasnip.lsp_expand(args.body)
				end,
			},
			mapping = cmp.mapping.preset.insert({
				["<C-k>"] = cmp.mapping.select_prev_item(), -- previous suggestion
				["<C-j>"] = cmp.mapping.select_next_item(), -- next suggestion
				["<C-b>"] = cmp.mapping.scroll_docs(-4),
				["<C-f>"] = cmp.mapping.scroll_docs(4),
				["<C-Space>"] = cmp.mapping.complete(), -- show completion suggestions
				["<C-e>"] = cmp.mapping.abort(), -- close completion window
				["<CR>"] = cmp.mapping.confirm({ select = false }),
			}),
		-- sources for autocompletion
		sources = cmp.config.sources({
			{ name = "codeium", priority = 1, max_item_count = 3 }, -- AI completion (highest priority, limited items)
			{ name = "nvim_lsp", priority = 2 },
			{ name = "luasnip", priority = 3 }, -- snippets
			{ name = "buffer", priority = 4 }, -- text within current buffer
			{ name = "path", priority = 5 }, -- file system paths
		}),

		-- configure lspkind for vs-code like pictograms in completion menu
		formatting = {
			format = lspkind.cmp_format({
				mode = "symbol_text",
				maxwidth = 50,
				ellipsis_char = "...",
				menu = {
					codeium = "[AI]",
					nvim_lsp = "[LSP]",
					luasnip = "[Snip]",
					buffer = "[Buf]",
					path = "[Path]",
				},
			}),
		},
		})
	end,
}
