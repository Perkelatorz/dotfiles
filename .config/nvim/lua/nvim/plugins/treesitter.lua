return {
	"nvim-treesitter/nvim-treesitter",
	-- Load on buffer events to be available early for plugins that need it
	-- Also load on VeryLazy to ensure it's available for lazy-loaded plugins
	event = { "BufReadPost", "BufNewFile", "VeryLazy" },
	priority = 1000, -- High priority to load before other VeryLazy plugins
	dependencies = {
		"windwp/nvim-ts-autotag",
	},
	config = function()
		local utils = require("nvim.core.utils")
		
		-- import nvim-treesitter plugin
		local treesitter, treesitter_ok = utils.safe_require("nvim-treesitter.configs")
		if not treesitter_ok then
			return
		end

		-- configure treesitter
		treesitter.setup({ -- enable syntax highlighting
			highlight = {
				enable = true,
				-- Custom highlight injections for Python class names
				additional_vim_regex_highlighting = false,
			},
			sync_install = false,

			-- enable indentation
			indent = { enable = true },
			-- ensure these language parsers are installed
			ensure_installed = {
				"json",
				"javascript",
				"typescript",
				"tsx",
				"svelte",
				"powershell",
				"yaml",
				"html",
				"css",
				"scss",
				"markdown",
				"markdown_inline",
				"bash",
				"lua",
				"vim",
				"dockerfile",
				"gitignore",
				"query",
				"vimdoc",
				"c",
				"xml",
				"terraform",
				"hcl",
				"c_sharp",
				"python",
				"go",
				"gomod",
				"gowork",
				"gosum",
			},
			incremental_selection = {
				enable = true,
				keymaps = {
					init_selection = "<C-space>",
					node_incremental = "<C-space>",
					scope_incremental = false,
					node_decremental = "<bs>",
				},
			},
			textobjects = {
				select = {
					enable = true,
					lookahead = true,
					keymaps = {
						["af"] = "@function.outer",
						["if"] = "@function.inner",
						["ac"] = "@class.outer",
						["ic"] = "@class.inner",
						["aa"] = "@parameter.outer",
						["ia"] = "@parameter.inner",
					},
				},
				move = {
					enable = true,
					set_jumps = true,
					goto_next_start = {
						["]m"] = "@function.outer",
						["]]"] = "@class.outer",
					},
					goto_next_end = {
						["]M"] = "@function.outer",
						["]["] = "@class.outer",
					},
					goto_previous_start = {
						["[m"] = "@function.outer",
						["[["] = "@class.outer",
					},
					goto_previous_end = {
						["[M"] = "@function.outer",
						["[]"] = "@class.outer",
					},
				},
			},
		})

		-- configure autotagging (w/ nvim-ts-autotag plugin)
		local autotag, autotag_ok = utils.safe_require("nvim-ts-autotag")
		if autotag_ok then
			autotag.setup()
		end
		
	end,
}
