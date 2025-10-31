return {
	"nvim-neotest/neotest",
	dependencies = {
		"nvim-neotest/nvim-nio",
		"nvim-lua/plenary.nvim",
		"antoinemadec/FixCursorHold.nvim",
		"nvim-treesitter/nvim-treesitter",
		"nvim-neotest/neotest-python",
		"nvim-neotest/neotest-go",
		"nvim-neotest/neotest-jest",
		"marilari88/neotest-vitest",
	},
	config = function()
		local neotest = require("neotest")

		neotest.setup({
			adapters = {
				require("neotest-python")({
					dap = { justMyCode = false },
					args = { "--log-level", "DEBUG", "--verbose" },
					runner = "pytest",
				}),
				require("neotest-go")({
					experimental = {
						test_table = true,
					},
					args = { "-v", "-race", "-count=1" },
				}),
				require("neotest-jest")({
					jestCommand = "npm test --",
					jestConfigFile = "jest.config.js",
					env = { CI = true },
					cwd = function()
						return vim.fn.getcwd()
					end,
				}),
				require("neotest-vitest")({
					filter_dir = function(name)
						return name ~= "node_modules"
					end,
				}),
			},
			discovery = {
				enabled = true,
				concurrent = 1,
			},
			running = {
				concurrent = true,
			},
			summary = {
				enabled = true,
				expand_errors = true,
				follow = true,
				mappings = {
					attach = "a",
					expand = { "<CR>", "<2-LeftMouse>" },
					expand_all = "e",
					jumpto = "i",
					output = "o",
					run = "r",
					short = "O",
					stop = "u",
					watch = "w",
				},
			},
			output = {
				enabled = true,
				open_on_run = true,
			},
			quickfix = {
				enabled = true,
				open = false,
			},
			status = {
				enabled = true,
				virtual_text = true,
				signs = true,
			},
			icons = {
				passed = "",
				running = "",
				failed = "",
				skipped = "",
				unknown = "",
				watching = "",
			},
		})

		local keymap = vim.keymap

		keymap.set("n", "<leader>tr", function()
			neotest.run.run()
		end, { desc = "Run nearest test" })

		keymap.set("n", "<leader>tf", function()
			neotest.run.run(vim.fn.expand("%"))
		end, { desc = "Run current test file" })

		keymap.set("n", "<leader>td", function()
			neotest.run.run({ strategy = "dap" })
		end, { desc = "Debug nearest test" })

		keymap.set("n", "<leader>ts", function()
			neotest.run.stop()
		end, { desc = "Stop nearest test" })

		keymap.set("n", "<leader>ta", function()
			neotest.run.attach()
		end, { desc = "Attach to nearest test" })

		keymap.set("n", "<leader>tw", function()
			neotest.watch.toggle(vim.fn.expand("%"))
		end, { desc = "Toggle watch current file" })

		keymap.set("n", "<leader>tS", function()
			neotest.summary.toggle()
		end, { desc = "Toggle test summary" })

		keymap.set("n", "<leader>to", function()
			neotest.output.open({ enter = true, auto_close = true })
		end, { desc = "Show test output" })

		keymap.set("n", "<leader>tO", function()
			neotest.output_panel.toggle()
		end, { desc = "Toggle test output panel" })

		keymap.set("n", "[T", function()
			neotest.jump.prev({ status = "failed" })
		end, { desc = "Jump to previous failed test" })

		keymap.set("n", "]T", function()
			neotest.jump.next({ status = "failed" })
		end, { desc = "Jump to next failed test" })
	end,
}
