return {
	"folke/which-key.nvim",
	-- Load early so triggers are registered before user presses leader (VeryLazy was too late)
	event = "VimEnter",
	init = function()
		vim.o.timeout = true
		vim.o.timeoutlen = 500
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
			-- v3 format: trigger key + mode. Omit "t" (terminal) so Space types a space in the terminal
			triggers = {
				{ " ", mode = "nixso" },
				{ "]", mode = "n" },
				{ "[", mode = "n" },
			},
		})

		-- Keys are defined in keymaps.lua and plugin configs (with desc); we register them here so they show in which-key.
		which_key.add({
			-- Groups with consistent icons
			{ "<leader>a", group = "󰚩 AI" },
			{ "<leader>b", group = "󰓩 Buffer" },
			{ "<leader>c", group = "󰨞 Code" },
			{ "<leader>d", group = "󰔫 Diagnostics/Diff" },
			{ "<leader>e", group = "󰉋 Explorer" },
			{ "<leader>f", group = "󰱼 Find (Telescope)" },
			{ "<leader>g", group = "󰬴 Case" },
			{ "<leader>G", group = "󰟓 Go" },
			{ "<leader>Gr", desc = "󰟓 Run current file" },
			{ "<leader>Gt", desc = "󰟓 Test package" },
			{ "<leader>Ga", desc = "󰟓 Test all packages" },
			{ "<leader>Gb", desc = "󰟓 Build" },
			{ "<leader>h", group = "󰊢 Git Hunk" },
			{ "<leader>H", group = "󰖟 HTTP" },
			{ "<leader>l", group = "󰀂 Live server / LazyGit" },
			{ "<leader>m", group = "󰍍 Markdown/Format" },
			{ "<leader>n", group = "󰐊 Clear/Number" },
			{ "<leader>o", group = "󰋩 Obsidian" },
			{ "<leader>-", group = "󰏖 Oil", desc = "󰏖 Oil (floating)" },
			{ "<leader>r", group = "󰑄 Rename/Restart" },
			{ "<leader>s", group = "󰜁 Svelte" },
			{ "<leader>t", group = "󰔃 Tab/Toggle/Spell" },
			{ "<leader>z", group = "󰆍 Terminal" },
			{ "<leader>u", group = "󰔡 UI Toggle" },
			{ "<leader>v", group = "󰄳 Version/Checkpoint" },
			{ "<leader>w", group = "󰆓 Save/Window/Session", desc = "󰆓 Save file" },
			{ "<leader>x", group = "󰔫 Trouble" },
			{ "<leader>y", group = "󰆒 Yank path" },
			{ "<leader>?", desc = "󰌍 Show which-key (all keymaps)" },

			-- Core keymaps
			{ "<leader>nh", desc = "󰐊 Clear search highlights" },
			{ "<leader>+", desc = "󰎎 Increment number" },
			{ "<leader>=", desc = "󰎐 Decrement number" },
			{ "<leader>ct", desc = "󰏘 Toggle colorscheme" },
			
			-- Quick actions
			{ "<leader>ww", desc = "󰆓 Save all files" },
			{ "<leader>q", desc = "󰅙 Quit window" },
			{ "<leader>qq", desc = "󰅚 Force quit window" },
			{ "<leader>sr", desc = "󰛔 Search and replace word", mode = { "n", "v" } },
			
			-- AI (Codeium/Windsurf + Cursor Agent)
			{ "<leader>aw", desc = "󱚟 Codeium toggle" },
			{ "<leader>ac", desc = "󰭹 Codeium chat" },
			{ "<leader>aa", desc = "󰷖 Codeium auth" },
			{ "<leader>as", desc = "󰋼 Codeium status" },
			{ "<leader>al", desc = "󰚩 Cursor Agent (cwd)" },
			{ "<leader>aj", desc = "󰚩 Cursor Agent (root)" },
			{ "<leader>at", desc = "󰚩 Cursor Agent sessions" },

			-- Explorer (nvim-tree)
			{ "<leader>ee", desc = "󰉋 Toggle tree" },
			{ "<leader>ef", desc = "󰈔 Find in tree" },
			{ "<leader>ec", desc = "󰝥 Collapse tree" },
			{ "<leader>er", desc = "󰑓 Refresh tree" },

			-- Obsidian
			{ "<leader>on", desc = "󰋩 New note" },
			{ "<leader>oq", desc = "󰋩 Quick switch" },
			{ "<leader>of", desc = "󰋩 Follow link" },
			{ "<leader>ob", desc = "󰋩 Backlinks" },
			{ "<leader>ot", desc = "󰋩 Today" },
			{ "<leader>od", desc = "󰋩 Dailies" },
			{ "<leader>os", desc = "󰋩 Search vault" },
			{ "<leader>otl", desc = "󰋩 Insert template" },
			{ "<leader>oo", desc = "󰋩 Open in Obsidian app" },
			{ "<leader>oc", desc = "󰋩 Toggle checkbox", mode = { "n", "v" } },

			-- Find (telescope) with icons
			{ "<leader>ff", desc = "󰱼 Fuzzy find files in cwd" },
			{ "<leader>fr", desc = "󰄉 Fuzzy find recent files" },
			{ "<leader>fs", desc = "󰊢 Find string in cwd" },
			{ "<leader>fc", desc = "󰊢 Find string under cursor in cwd" },
			{ "<leader>ft", desc = "󰔫 Find todos" },
			{ "<leader>fb", desc = "󰈔 Open telescope buffers" },

			-- Format with icons
			{ "<leader>mp", desc = "󰨞 Format file or range" },

			-- Session (auto-session) with icons
			{ "<leader>wr", desc = "󰁯 Restore session for cwd" },
			{ "<leader>ws", desc = "󰄳 Save session for cwd" },

			-- Terminal (z = shell)
			{ "<leader>zt", desc = "󰆍 Toggle terminal" },
			{ "<leader>zf", desc = "󰆍 Floating terminal" },
			{ "<leader>zv", desc = "󰆍 Vertical terminal" },
			{ "<leader>zx", desc = "󰔌 Shutdown all terminals" },
			{ "<leader>zc", desc = "󰆍 Terminal: cd to current file dir" },

			-- Trouble with icons
			{ "<leader>xw", desc = "󰔫 Open trouble workspace diagnostics" },
			{ "<leader>xd", desc = "󰈔 Open trouble document diagnostics" },
			{ "<leader>xq", desc = "󰛨 Open trouble quickfix list" },
			{ "<leader>xl", desc = "󰦨 Open trouble location list" },
			{ "<leader>xt", desc = "󰔫 Open todos in trouble" },

			-- LSP (uses Neovim defaults: K=hover, gd=definition, gD=declaration, gi=impl, gr=refs)
			{ "gR", desc = "󰞔 References (Telescope)" },
			{ "<leader>ca", desc = "󰨞 Code action" },
			{ "<leader>rn", desc = "󰑓 Rename" },
			{ "<leader>dl", desc = "󰔫 Diagnostics (Telescope)" },
			{ "<leader>dd", desc = "󰔫 Line diagnostic (float)" },
			{ "<leader>rs", desc = "󰑄 Restart LSP" },
			
			-- UI toggles
			{ "<leader>uh", desc = "󰘨 Toggle inlay hints" },
			{ "<leader>uv", desc = "󰨞 Toggle virtual text diagnostics" },

			-- Markdown
			{ "<leader>mv", desc = "󰍔 Toggle markdown preview" },
			{ "<leader>ms", desc = "󰅙 Stop markdown preview" },


			-- Live Server
			{ "<leader>ls", desc = "󰀂 Start live server" },
			{ "<leader>lz", desc = "󰋼 Live server status" },
			{ "<leader>lc", desc = "󰅙 Stop serving directory" },
			{ "<leader>lx", desc = "󰅙 Stop all live servers" },
			{ "<leader>ll", desc = "󰌱 Live server log" },

			-- HTTP Client
			{ "<leader>Hr", desc = "󰜏 Run request" },
			{ "<leader>Ht", desc = "󰨞 Toggle view" },
			{ "<leader>H[", desc = "󰅝 Previous request" },
			{ "<leader>H]", desc = "󰅞 Next request" },
			{ "<leader>Hi", desc = "󰋼 Inspect" },
			{ "<leader>Hc", desc = "󰆒 Copy as cURL" },
			{ "<leader>Hs", desc = "󰧮 Scratchpad" },
			{ "<leader>Hq", desc = "󰅙 Close" },

			-- Git Hunks (gitsigns) with icons
			{ "<leader>hs", desc = "󰐖 Stage hunk" },
			{ "<leader>hr", desc = "󰍴 Reset hunk" },
			{ "<leader>hx", desc = "󰐖 Stage buffer" },
			{ "<leader>he", desc = "󰍴 Reset buffer" },
			{ "<leader>hu", desc = "󰑄 Undo stage hunk" },
			{ "<leader>hp", desc = "󰨞 Preview hunk" },
			{ "<leader>hb", desc = "󰊢 Blame line" },
			{ "<leader>hl", desc = "󰊢 Toggle line blame" },
			{ "<leader>hd", desc = "󰐖 Diff this" },
			{ "<leader>hy", desc = "󰐖 Diff this ~" },
			{ "[c", desc = "󰅝 Previous git hunk" },
			{ "]c", desc = "󰅞 Next git hunk" },

			-- Todo comments
			{ "[t", desc = "󰅝 Previous todo comment" },
			{ "]t", desc = "󰅞 Next todo comment" },
			
			-- Buffer navigation
			{ "[b", desc = "󰅝 Previous buffer" },
			{ "]b", desc = "󰅞 Next buffer" },
			{ "<leader>bd", desc = "󰅙 Delete buffer" },
			{ "<leader>bx", desc = "󰅙 Force delete buffer" },
			
			-- Quickfix navigation
			{ "[q", desc = "󰅝 Previous quickfix item" },
			{ "]q", desc = "󰅞 Next quickfix item" },
			{ "[Q", desc = "󰅝 First quickfix item" },
			{ "]Q", desc = "󰅞 Last quickfix item" },
			
			-- Location list navigation
			{ "[l", desc = "󰅝 Previous location item" },
			{ "]l", desc = "󰅞 Next location item" },
			{ "[L", desc = "󰅝 First location item" },
			{ "]L", desc = "󰅞 Last location item" },
			
			-- Diagnostic navigation (enhanced)
			{ "[d", desc = "󰅝 Previous diagnostic" },
			{ "]d", desc = "󰅞 Next diagnostic" },
			{ "[D", desc = "󰅝 Previous error" },
			{ "]D", desc = "󰅞 Next error" },
			
			-- Window management
			{ "<leader>w=", desc = "󰕴 Equalize windows" },
			{ "<leader>w|", desc = "󰕩 Maximize width" },
			{ "<leader>w_", desc = "󰕧 Maximize height" },
			
			-- Tab management
			{ "<leader>tn", desc = "󰎔 New tab" },
			{ "<leader>tc", desc = "󰅙 Close tab" },
			{ "<leader>to", desc = "󰅙 Close other tabs" },
			{ "<leader>tp", desc = "󰅝 Previous tab" },
			{ "<leader>tj", desc = "󰅞 Next tab" },
			{ "<leader>tm", desc = "󰅟 Move tab" },
			{ "<leader>t1", desc = "󰎤 Tab 1" },
			{ "<leader>t2", desc = "󰎧 Tab 2" },
			{ "<leader>t3", desc = "󰎪 Tab 3" },
			{ "<leader>t4", desc = "󰎭 Tab 4" },
			{ "<leader>t5", desc = "󰎱 Tab 5" },
			
			-- Toggles
			{ "<leader>tr", desc = "󰔡 Toggle relative numbers" },
			{ "<leader>tw", desc = "󰖶 Toggle wrap" },
			{ "<leader>tl", desc = "󰌑 Toggle whitespace" },
			{ "<leader>ts", desc = "󰓆 Toggle spell" },
			
			-- Spell checking
			{ "[s", desc = "󰅝 Previous misspelled" },
			{ "]s", desc = "󰅞 Next misspelled" },
			{ "z=", desc = "󰓆 Spelling suggestions" },
			{ "zg", desc = "󰐕 Add to dictionary" },
			{ "zw", desc = "󰅖 Mark as misspelled" },
			{ "zug", desc = "󰩹 Remove from dictionary" },
			
			-- Case conversion
			{ "<leader>gu", desc = "󰬴 Uppercase word", mode = { "n", "v" } },
			{ "<leader>gl", desc = "󰬲 Lowercase word", mode = { "n", "v" } },
			{ "<leader>g~", desc = "󰬱 Toggle case word", mode = { "n", "v" } },
			
			-- Number format
			{ "<leader>nx", desc = "󰘧 Convert to hex" },
			{ "<leader>nr", desc = "󰘧 Revert from hex" },
			
			-- Diff shortcuts
			{ "<leader>dt", desc = "󰒕 Diff this" },
			{ "<leader>do", desc = "󰒕 Diff off" },
			{ "<leader>du", desc = "󰒕 Diff update" },
			
			-- Quick config edit
			{ "<leader>ev", desc = "󰏫 Edit init.lua" },
			{ "<leader>sv", desc = "󰑓 Source init.lua" },
			
			-- File reload (for AI tool changes)
			{ "<leader>rr", desc = "󰑓 Reload buffers from disk" },
			{ "<leader>uu", desc = "󰕌 Undo to previous save" },
			
			-- Yank path to clipboard
			{ "<leader>yp", desc = "󰆒 Yank full path" },
			{ "<leader>yr", desc = "󰆒 Yank relative path" },
			{ "<leader>yn", desc = "󰆒 Yank filename" },
			


			-- LazyGit
			{ "<leader>lg", desc = "󰊢 Open lazy git" },

			-- CSV
			{ "<leader>cs", desc = "󰌟 Toggle CSV view" },

			-- Color highlighter (nvim-highlight-colors)
			{ "<leader>ch", desc = "󰌁 Toggle color highlighter" },
			
			-- Svelte templates
			{ "<leader>sc", desc = "󰜁 New component" },
			{ "<leader>sp", desc = "󰜁 New page" },
			{ "<leader>sl", desc = "󰜁 New layout" },
			
			-- Visual mode improvements
			{ "<", desc = "󰉵 Indent left (stay in visual)", mode = "v" },
			{ ">", desc = "󰉶 Indent right (stay in visual)", mode = "v" },
			{ "J", desc = "󰜮 Move lines down", mode = "v" },
			{ "K", desc = "󰜷 Move lines up", mode = "v" },
			{ "p", desc = "󰆒 Paste without yank", mode = "v" },
			
			-- Version/Checkpoint system (AI edit recovery)
			{ "<leader>vc", desc = "󰄳 Create checkpoint" },
			{ "<leader>vr", desc = "󰕌 Restore checkpoint" },
			{ "<leader>vd", desc = "󰒕 Diff with checkpoint" },
			{ "<leader>vx", desc = "󰩺 Delete checkpoint" },
			{ "<leader>vh", desc = "󰄳 Checkpoint open files" },
			{ "<leader>vj", desc = "󰄳 Checkpoint entire project" },
			{ "<leader>vk", desc = "󰕌 Restore all files" },
			{ "<leader>vl", desc = "󰒕 Show all changes" },

		})
	end,
}
