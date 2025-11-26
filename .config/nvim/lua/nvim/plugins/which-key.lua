return {
	"folke/which-key.nvim",
	event = "VeryLazy",
	init = function()
		vim.o.timeout = true
		vim.o.timeoutlen = 500
	end,
	config = function()
		local utils = require("nvim.core.utils")
		
		local which_key, which_key_ok = utils.safe_require("which-key")
		if not which_key_ok then
			return
		end

		-- Get theme colors
		local colors = _G.alabaster_colors or {}
		
		which_key.setup({
			plugins = {
				marks = true,
				registers = true,
				spelling = {
					enabled = true,
					suggestions = 20,
				},
				presets = {
					operators = true,
					motions = true,
					text_objects = true,
					windows = true,
					nav = true,
					z = true,
					g = true,
				},
			},
			win = {
				border = "rounded",
			},
			layout = {
				height = { min = 4, max = 25 },
				width = { min = 20, max = 50 },
				spacing = 3,
				align = "left",
			},
			show_help = true,
			triggers = { "<leader>" },
			colors = {
				bg = colors.bg0 or "#1a1520",
				fg = colors.fg1 or "#d8d8d8", -- Text color (fg1)
				border = colors.ui3 or "#404040",
				group = colors.color1 or "#5BF65B", -- Group names (colored)
				key = colors.color6 or "#FFD343", -- Key bindings (colored)
				separator = colors.ui3 or "#404040",
			},
		})

		which_key.add({
			-- Groups with icons
			{ "<leader>a", group = "󰚩 AI" },
			{ "<leader>c", group = "󰨞 Code" },
			{ "<leader>e", group = "󰉋 Explorer" },
			{ "<leader>f", group = "󰱼 Find" },
			{ "<leader>h", group = "󰊢 Git Hunk" },
			-- Note: <leader>k is used for LSP hover, HTTP commands use <leader>kr, <leader>kt, etc.
			{ "<leader>l", group = "󰒲 Lazy" },
			{ "<leader>m", group = "󰍍 Markdown/Format" },
			{ "<leader>n", group = "󰐊 Clear" },
			{ "<leader>o", group = "󰏖 Oil" },
			{ "<leader>r", group = "󰑄 Rename/Restart" },
			{ "<leader>t", group = "󰙨 Test" },
			{ "<leader>w", group = "󰁯 Session" },
			{ "<leader>x", group = "󰔫 Trouble" },

			-- Core keymaps with icons
			{ "<leader>nh", desc = "󰐊 Clear search highlights" },
			{ "<leader>+", desc = "󰎎 Increment number" },
			{ "<leader>=", desc = "󰎐 Decrement number" },
			{ "<leader>sc", desc = "󰓆 Toggle spell check" },

			-- AI (CodeCompanion) with icons
			{ "<leader>aa", desc = "󰚩 CodeCompanion actions", mode = { "n", "v" } },
			{ "<leader>ac", desc = "󰨀 Toggle CodeCompanion chat", mode = { "n", "v" } },
			{ "<leader>ai", desc = "󰆐 Add selection to chat", mode = "v" },
			{ "<leader>at", desc = "󰨀 Open CodeCompanion chat" },
			{ "<leader>ap", desc = "󰉺 Inline CodeCompanion prompt", mode = { "n", "v" } },

			-- Explorer (nvim-tree) with icons
			{ "<leader>ee", desc = "󰉋 Toggle file explorer" },
			{ "<leader>ef", desc = "󰈔 Toggle file explorer on current file" },
			{ "<leader>ec", desc = "󰝥 Collapse file explorer" },
			{ "<leader>er", desc = "󰑓 Refresh file explorer" },
			{ "<leader>eo", desc = "󰏖 Open oil file explorer" },

			-- Oil
			{ "<leader>..", desc = "Open parent directory in oil" },
			{ "<leader>.f", desc = "Open oil in floating window" },

			-- Find (telescope) with icons
			{ "<leader>ff", desc = "󰱼 Fuzzy find files in cwd" },
			{ "<leader>fr", desc = "󰄉 Fuzzy find recent files" },
			{ "<leader>fs", desc = "󰊢 Find string in cwd" },
			{ "<leader>fc", desc = "󰊢 Find string under cursor in cwd" },
			{ "<leader>ft", desc = "󰔫 Find todos" },
			{ "<leader>fb", desc = "󰈔 Open telescope buffers" },
			
			-- Search & Replace (spectre) with icons
			{ "<leader>sr", desc = "󰍉 Replace in files (Spectre)" },
			{ "<leader>sw", desc = "󰊢 Search current word (Spectre)" },
			{ "<leader>sf", desc = "󰈔 Search in current file (Spectre)" },
			
			-- Flash navigation with icons
			{ "<leader>j", desc = "󰥔 Flash jump" },
			{ "<leader>S", desc = "󰨞 Flash Treesitter" },

			-- Format with icons
			{ "<leader>mp", desc = "󰨞 Format file or range" },

			-- Session (auto-session) with icons
			{ "<leader>wr", desc = "󰁯 Restore session for cwd" },
			{ "<leader>ws", desc = "󰄳 Save session for cwd" },

			-- Trouble with icons
			{ "<leader>xw", desc = "󰔫 Open trouble workspace diagnostics" },
			{ "<leader>xd", desc = "󰈔 Open trouble document diagnostics" },
			{ "<leader>xq", desc = "󰛨 Open trouble quickfix list" },
			{ "<leader>xl", desc = "󰦨 Open trouble location list" },
			{ "<leader>xt", desc = "󰔫 Open todos in trouble" },

			-- LSP with icons (keymaps are auto-detected from lspconfig)
			{ "<leader>D", desc = "󰔫 Show buffer diagnostics" },
			{ "<leader>gd", desc = "󰞔 Show LSP definitions" },
			{ "<leader>k", desc = "󰋼 Show LSP hover documentation" },
			{ "<leader>rs", desc = "󰑄 Restart LSP" },
			{ "[d", desc = "󰅝 Go to previous diagnostic" },
			{ "]d", desc = "󰅞 Go to next diagnostic" },
			
			-- UI toggles
			{ "<leader>u", group = "󰨞 UI Toggle" },
			{ "<leader>uh", desc = "󰨞 Toggle inlay hints" },
			{ "<leader>uv", desc = "󰨞 Toggle virtual text diagnostics" },

			-- Markdown with icons
			{ "<leader>mm", group = "󰍍 Markdown" },
			{ "<leader>mv", desc = "󰍍 Toggle markdown preview" },
			{ "<leader>ms", desc = "󰐊 Stop markdown preview" },

			-- Test (neotest / test runners) with icons
			{ "<leader>tr", desc = "󰙨 Run nearest test" },
			{ "<leader>tf", desc = "󰈔 Run current test file" },
			{ "<leader>td", desc = "󰆍 Debug nearest test" },
			{ "<leader>ts", desc = "󰐊 Stop nearest test" },
			{ "<leader>ta", desc = "󰗀 Attach to nearest test" },
			{ "<leader>tw", desc = "󰔡 Toggle watch current file" },
			{ "<leader>tS", desc = "󰔫 Toggle test summary" },
			{ "<leader>to", desc = "󰨞 Show test output" },
			{ "<leader>tO", desc = "󰨞 Toggle test output panel" },
			{ "[T", desc = "󰅝 Jump to previous failed test" },
			{ "]T", desc = "󰅞 Jump to next failed test" },

			-- Debug with icons
			{ "<leader>db", desc = "󰝥 Toggle breakpoint" },
			{ "<leader>dB", desc = "󰝥 Set conditional breakpoint" },
			{ "<leader>dc", desc = "󰐊 Continue/Start debugging" },
			{ "<leader>di", desc = "󰐊 Step into" },
			{ "<leader>do", desc = "󰐊 Step over" },
			{ "<leader>dO", desc = "󰐊 Step out" },
			{ "<leader>dr", desc = "󰨞 Open REPL" },
			{ "<leader>dl", desc = "󰄉 Run last debug session" },
			{ "<leader>dt", desc = "󰐊 Terminate debug session" },
			{ "<leader>du", desc = "󰨞 Toggle debug UI" },
			{ "<leader>dh", desc = "󰋼 Debug hover" },
			{ "<leader>dp", desc = "󰨞 Debug preview" },
			{ "<leader>df", desc = "󰈔 Show frames" },
			{ "<leader>ds", desc = "󰨞 Show scopes" },
			{ "<leader>dpt", desc = "󰆍 Debug Python test method" },
			{ "<leader>dpc", desc = "󰆍 Debug Python test class" },
			{ "<leader>dps", desc = "󰆍 Debug Python selection", mode = "v" },
			{ "<leader>dgt", desc = "󰆍 Debug Go test" },
			{ "<leader>dgl", desc = "󰄉 Debug last Go test" },

			-- HTTP (rest.nvim / http.nvim etc)
			{ "<leader>kr", desc = "Run HTTP request" },
			{ "<leader>kt", desc = "Toggle HTTP view" },
			{ "<leader>kp", desc = "Jump to previous request" },
			{ "<leader>kn", desc = "Jump to next request" },
			{ "<leader>ki", desc = "Inspect HTTP request" },
			{ "<leader>kc", desc = "Copy as cURL" },
			{ "<leader>ks", desc = "Open HTTP scratchpad" },
			{ "<leader>kq", desc = "Close HTTP view" },

			-- Git Hunks (gitsigns) with icons
			{ "<leader>hs", desc = "󰐖 Stage hunk" },
			{ "<leader>hr", desc = "󰍴 Reset hunk" },
			{ "<leader>hS", desc = "󰐖 Stage buffer" },
			{ "<leader>hR", desc = "󰍴 Reset buffer" },
			{ "<leader>hu", desc = "󰑄 Undo stage hunk" },
			{ "<leader>hp", desc = "󰨞 Preview hunk" },
			{ "<leader>hb", desc = "󰊢 Blame line" },
			{ "<leader>hB", desc = "󰊢 Toggle line blame" },
			{ "<leader>hd", desc = "󰐖 Diff this" },
			{ "<leader>hD", desc = "󰐖 Diff this ~" },
			{ "[h", desc = "󰅝 Previous git hunk" },
			{ "]h", desc = "󰅞 Next git hunk" },

			-- Todo comments
			{ "[t", desc = "Previous todo comment" },
			{ "]t", desc = "Next todo comment" },

			-- Substitute (keymaps are auto-detected from substitute plugin)
			{ "<leader>ss", desc = "󰍉 Substitute word" },
			{ "gs", desc = "󰍉 Substitute with motion/visual", mode = { "n", "x" } },
			{ "gss", desc = "󰍉 Substitute line" },
			{ "gsS", desc = "󰍉 Substitute to end of line" },

			-- LazyGit
			{ "<leader>lg", desc = "Open lazy git" },

			-- CSV
			{ "<leader>cs", desc = "Toggle CSV view" },

			-- Arrow (file bookmarks)
			{ ";", desc = "Arrow bookmarks" },
			{ "m", desc = "Arrow buffer bookmarks" },
		})
	end,
}
