return {
	"folke/which-key.nvim",
	event = "VimEnter",
	init = function()
		vim.o.timeout = true
	end,
	keys = {
		{ "<leader>?", "<cmd>WhichKey<cr>", desc = "Which-key (show all keymaps)" },
	},
	config = function()
		local utils = require("nvim.core.utils")

		local which_key, which_key_ok = utils.safe_require("which-key")
		if not which_key_ok then
			vim.notify("which-key.nvim failed to load", vim.log.levels.WARN)
			return
		end

		which_key.setup({
			notify = false,
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
				padding = { 1, 2 },
				title = true,
				title_pos = "center",
			},
			layout = {
				height = { min = 4, max = 25 },
				width = { min = 20, max = 50 },
				spacing = 4,
				align = "left",
			},
			show_help = true,
			show_keys = true,
			triggers = {
				{ " ", mode = "nixso" },
				{ "]", mode = "n" },
				{ "[", mode = "n" },
			},
		})

		which_key.add({
			-- Groups
			{ "<leader>a", group = "󰚩 AI" },
			{ "<leader>b", group = "󰓩 Buffer" },
			{ "<leader>c", group = "󰨞 Code" },
			{ "<leader>d", group = "󰔫 Diagnostics/Diff" },
			{ "<leader>D", group = "󰈙 Docs" },
			{ "<leader>e", group = "󰉋 Explorer" },
			{ "<leader>f", group = "󰱼 Find" },
			{ "<leader>G", group = "󰟓 Go" },
			{ "<leader>h", group = "󰊢 Git Hunk" },
			{ "<leader>H", group = "󰖟 HTTP" },
			{ "<leader>n", group = "󰘧 Hex" },
			{ "<leader>o", group = "󰋩 Obsidian" },
			{ "<leader>r", group = "󰑄 Rename/Restart" },
			{ "<leader>s", group = "󰜁 Svelte" },
			{ "<leader>t", group = "󰎔 Tab" },
			{ "<leader>u", group = "󰔡 UI Toggle" },
			{ "<leader>v", group = "󰄳 Checkpoint" },
			{ "<leader>w", group = "󰕝 Window/Session" },
			{ "<leader>x", group = "󰔫 Trouble" },
			{ "<leader>y", group = "󰆒 Yank path" },
			{ "<leader>z", group = "󰆍 Terminal" },
			{ "<leader>-", desc = "󰏖 Oil (floating)" },
			{ "<leader>?", desc = "󰌍 Show which-key" },

			-- Save (Ctrl-s)
			{ "<C-s>", desc = "󰆓 Save file" },
			{ "<C-S-s>", desc = "󰆓 Save all files" },

			-- Quit
			{ "<leader>q", desc = "󰅙 Quit window" },
			{ "<leader>Q", desc = "󰅚 Force quit" },

			-- Search/Replace
			{ "<leader>sr", desc = "󰛔 Search/replace word", mode = { "n", "v" } },

			-- AI
			{ "<leader>aw", desc = "󱚟 Codeium toggle" },
			{ "<leader>ac", desc = "󰭹 Codeium chat" },
			{ "<leader>aa", desc = "󰷖 Codeium auth" },
			{ "<leader>as", desc = "󰋼 Codeium status" },
			{ "<leader>al", desc = "󰚩 Cursor Agent (cwd)" },
			{ "<leader>aj", desc = "󰚩 Cursor Agent (root)" },
			{ "<leader>at", desc = "󰚩 Cursor Agent sessions" },

			-- Buffer
			{ "[b", desc = "󰅝 Previous buffer" },
			{ "]b", desc = "󰅞 Next buffer" },
			{ "<leader>bd", desc = "󰅙 Delete buffer" },
			{ "<leader>bx", desc = "󰅙 Force delete buffer" },

			-- Code
			{ "<leader>ca", desc = "󰨞 Code action" },
			{ "<leader>ci", desc = "󰒕 Organize imports" },
			{ "<leader>ct", desc = "󰏘 Toggle colorscheme" },
			{ "<leader>ch", desc = "󰌁 Toggle color highlighter" },
			{ "<leader>cs", desc = "󰌟 Toggle CSV view" },

			-- Diagnostics/Diff
			{ "<leader>dd", desc = "󰔫 Line diagnostic (float)" },
			{ "<leader>dl", desc = "󰔫 Diagnostics (Telescope)" },
			{ "<leader>dt", desc = "󰒕 Diff this" },
			{ "<leader>do", desc = "󰒕 Diff off" },
			{ "<leader>du", desc = "󰒕 Diff update" },
			{ "[D", desc = "󰅝 Previous error" },
			{ "]D", desc = "󰅞 Next error" },

			-- Docs
			{ "<leader>Dz", desc = "󰈙 Zeal lookup" },
			{ "<leader>Dd", desc = "󰈙 DevDocs lookup" },
			{ "<leader>Dp", desc = " Pydoc" },
			{ "<leader>Ds", desc = "󰖟 Web search" },

			-- Explorer
			{ "<leader>ee", desc = "󰉋 Toggle tree" },
			{ "<leader>ef", desc = "󰈔 Find in tree" },
			{ "<leader>ec", desc = "󰝥 Collapse tree" },
			{ "<leader>er", desc = "󰑓 Refresh tree" },

			-- Find (Telescope)
			{ "<leader>ff", desc = "󰱼 Find files" },
			{ "<leader>fr", desc = "󰄉 Recent files" },
			{ "<leader>fs", desc = "󰊢 Grep string" },
			{ "<leader>fc", desc = "󰊢 Grep word under cursor" },
			{ "<leader>ft", desc = "󰔫 Find todos" },
			{ "<leader>fb", desc = "󰈔 Buffers" },

			-- Go
			{ "<leader>Gr", desc = "󰟓 Run file" },
			{ "<leader>Gt", desc = "󰟓 Test package" },
			{ "<leader>Ga", desc = "󰟓 Test all" },
			{ "<leader>Gb", desc = "󰟓 Build" },

			-- Git Hunks
			{ "<leader>hs", desc = "󰐖 Stage hunk" },
			{ "<leader>hr", desc = "󰍴 Reset hunk" },
			{ "<leader>hx", desc = "󰐖 Stage buffer" },
			{ "<leader>he", desc = "󰍴 Reset buffer" },
			{ "<leader>hu", desc = "󰑄 Undo stage" },
			{ "<leader>hp", desc = "󰨞 Preview hunk" },
			{ "<leader>hb", desc = "󰊢 Blame line" },
			{ "<leader>hl", desc = "󰊢 Toggle line blame" },
			{ "<leader>hd", desc = "󰐖 Diff this" },
			{ "<leader>hy", desc = "󰐖 Diff this ~" },
			{ "[c", desc = "󰅝 Previous hunk" },
			{ "]c", desc = "󰅞 Next hunk" },

			-- HTTP Client
			{ "<leader>Hr", desc = "󰜏 Run request" },
			{ "<leader>Ht", desc = "󰨞 Toggle view" },
			{ "<leader>H[", desc = "󰅝 Previous request" },
			{ "<leader>H]", desc = "󰅞 Next request" },
			{ "<leader>Hi", desc = "󰋼 Inspect" },
			{ "<leader>Hc", desc = "󰆒 Copy as cURL" },
			{ "<leader>Hs", desc = "󰧮 Scratchpad" },
			{ "<leader>Hq", desc = "󰅙 Close" },

			-- Hex
			{ "<leader>nx", desc = "󰘧 Convert to hex" },
			{ "<leader>nr", desc = "󰘧 Revert from hex" },

			-- Obsidian
			{ "<leader>on", desc = "󰋩 New note" },
			{ "<leader>oq", desc = "󰋩 Quick switch" },
			{ "<leader>of", desc = "󰋩 Follow link" },
			{ "<leader>ob", desc = "󰋩 Backlinks" },
			{ "<leader>ot", desc = "󰋩 Today" },
			{ "<leader>od", desc = "󰋩 Dailies" },
			{ "<leader>os", desc = "󰋩 Search vault" },
			{ "<leader>otl", desc = "󰋩 Insert template" },
			{ "<leader>oo", desc = "󰋩 Open in app" },
			{ "<leader>oc", desc = "󰋩 Toggle checkbox", mode = { "n", "v" } },

			-- Rename/Restart
			{ "<leader>rn", desc = "󰑓 Rename symbol" },
			{ "<leader>rs", desc = "󰑄 Restart LSP" },
			{ "<leader>rr", desc = "󰑓 Reload buffers" },

			-- Svelte
			{ "<leader>sc", desc = "󰜁 New component" },
			{ "<leader>sp", desc = "󰜁 New page" },
			{ "<leader>sl", desc = "󰜁 New layout" },

			-- Tab
			{ "<leader>tn", desc = "󰎔 New tab" },
			{ "<leader>tc", desc = "󰅙 Close tab" },
			{ "<leader>to", desc = "󰅙 Close other tabs" },
			{ "<leader>tm", desc = "󰅟 Move tab" },

			-- UI Toggles
			{ "<leader>uh", desc = "󰘨 Toggle inlay hints" },
			{ "<leader>uv", desc = "󰨞 Toggle virtual text" },
			{ "<leader>us", desc = "󰓆 Toggle spell" },
			{ "<leader>ur", desc = "󰔡 Toggle relative numbers" },
			{ "<leader>uw", desc = "󰖶 Toggle wrap" },
			{ "<leader>ul", desc = "󰌑 Toggle whitespace" },
			{ "<leader>uu", desc = "󰕌 Undo to previous save" },

			-- Checkpoint
			{ "<leader>vc", desc = "󰄳 Create checkpoint" },
			{ "<leader>vr", desc = "󰕌 Restore checkpoint" },
			{ "<leader>vd", desc = "󰒕 Diff with checkpoint" },
			{ "<leader>vx", desc = "󰩺 Delete checkpoint" },
			{ "<leader>vh", desc = "󰄳 Checkpoint open files" },
			{ "<leader>vj", desc = "󰄳 Checkpoint project" },
			{ "<leader>vk", desc = "󰕌 Restore all files" },
			{ "<leader>vl", desc = "󰒕 Show all changes" },

			-- Window/Session
			{ "<leader>w=", desc = "󰕴 Equalize windows" },
			{ "<leader>w|", desc = "󰕩 Maximize width" },
			{ "<leader>w_", desc = "󰕧 Maximize height" },
			{ "<leader>wr", desc = "󰁯 Restore session" },
			{ "<leader>ws", desc = "󰄳 Save session" },

			-- Trouble
			{ "<leader>xw", desc = "󰔫 Workspace diagnostics" },
			{ "<leader>xd", desc = "󰈔 Document diagnostics" },
			{ "<leader>xq", desc = "󰛨 Quickfix list" },
			{ "<leader>xl", desc = "󰦨 Location list" },
			{ "<leader>xt", desc = "󰔫 Todos" },

			-- Yank path
			{ "<leader>yp", desc = "󰆒 Yank full path" },
			{ "<leader>yr", desc = "󰆒 Yank relative path" },
			{ "<leader>yn", desc = "󰆒 Yank filename" },

			-- Terminal
			{ "<leader>zt", desc = "󰆍 Toggle terminal" },
			{ "<leader>zf", desc = "󰆍 Floating terminal" },
			{ "<leader>zv", desc = "󰆍 Vertical terminal" },
			{ "<leader>zx", desc = "󰔌 Shutdown all terminals" },
			{ "<leader>zc", desc = "󰆍 cd to file dir" },

			-- LazyGit
			{ "<leader>lg", desc = "󰊢 LazyGit" },

			-- Format
			{ "<leader>mp", desc = "󰨞 Format file/range" },

			-- Markdown
			{ "<leader>mv", desc = "󰍔 Toggle markdown preview" },
			{ "<leader>ms", desc = "󰅙 Stop markdown preview" },

			-- Config
			{ "<leader>ev", desc = "󰏫 Edit init.lua" },

			-- LSP (defaults, just adding descriptions)
			{ "K", desc = "󰋖 Hover documentation" },
			{ "gd", desc = "󰒕 Go to definition" },
			{ "gD", desc = "󰒕 Go to declaration" },
			{ "gi", desc = "󰒕 Go to implementation" },
			{ "gR", desc = "󰞔 References (Telescope)" },

			-- Quickfix/Location
			{ "[q", desc = "󰅝 Previous quickfix" },
			{ "]q", desc = "󰅞 Next quickfix" },
			{ "[Q", desc = "󰅝 First quickfix" },
			{ "]Q", desc = "󰅞 Last quickfix" },
			{ "[l", desc = "󰅝 Previous location" },
			{ "]l", desc = "󰅞 Next location" },
			{ "[L", desc = "󰅝 First location" },
			{ "]L", desc = "󰅞 Last location" },

			-- Spell
			{ "[s", desc = "󰅝 Previous misspelled" },
			{ "]s", desc = "󰅞 Next misspelled" },
			{ "z=", desc = "󰓆 Spelling suggestions" },
			{ "zg", desc = "󰐕 Add to dictionary" },
			{ "zw", desc = "󰅖 Mark as misspelled" },

			-- Todo comments
			{ "[t", desc = "󰅝 Previous todo" },
			{ "]t", desc = "󰅞 Next todo" },

			-- Visual mode
			{ "<", desc = "󰉵 Indent left (reselect)", mode = "v" },
			{ ">", desc = "󰉶 Indent right (reselect)", mode = "v" },
			{ "J", desc = "󰜮 Move lines down", mode = "v" },
			{ "K", desc = "󰜷 Move lines up", mode = "v" },
			{ "p", desc = "󰆒 Paste without yank", mode = "v" },
		})
	end,
}
