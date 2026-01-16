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
			{ "<leader>s", group = "  Svelte" },
			{ "<leader>t", group = "󰔃 Toggle" },
			{ "<leader>w", group = "󰁯 Session" },
			{ "<leader>x", group = "󰔫 Trouble" },

			-- Core keymaps with icons
			{ "<leader>nh", desc = "󰐊 Clear search highlights" },
			{ "<leader>+", desc = "󰎎 Increment number" },
			{ "<leader>=", desc = "󰎐 Decrement number" },
			{ "<leader>ct", desc = "🎨 Toggle colorscheme" },
			{ "<leader>ts", desc = "󰓆 Toggle spell check" },
			
			-- Svelte/SvelteKit templates
			{ "<leader>sc", desc = "  New component" },
			{ "<leader>sp", desc = "  New page" },
			{ "<leader>sl", desc = "  New layout" },

		-- AI Tools (all under <leader>a)
		{ "<leader>a", group = "󰚩 AI" },
		-- OpenCode (lowercase = common, uppercase = project)
		{ "<leader>ao", desc = "󰚩 OpenCode" },
		{ "<leader>ai", desc = "󰆐 Input window" },
		{ "<leader>aO", desc = "󰨞 Output window" },
		{ "<leader>aq", desc = "󰅙 Close" },
		{ "<leader>ac", desc = "󰭻 Chat" },
		-- Send Context
		{ "<leader>as", desc = "󰒅 Send selection", mode = "v" },
		{ "<leader>af", desc = "󰈔 Send file" },
		{ "<leader>ab", desc = "󰅩 Send block" },
		{ "<leader>ad", desc = "󰔫 Send diagnostics" },
		{ "<leader>al", desc = "󰉿 Send line" },
		{ "<leader>ae", desc = "󰅚 Send error" },
		{ "<leader>ag", desc = "󰊢 Send git diff" },
		-- Project Context
		{ "<leader>aP", desc = "󰙅 Project structure" },
		{ "<leader>aG", desc = "󰱼 Files by pattern" },
		{ "<leader>aK", desc = "󰈔 Key files" },
		{ "<leader>aD", desc = "󰉋 Directory" },
		{ "<leader>aL", desc = "󰜘 Git log" },
		-- Utils
		{ "<leader>ap", desc = "󰉋 Copy file path" },
		{ "<leader>a?", desc = "󰋼 Help" },
		-- Windsurf/Codeium
		{ "<leader>aw", desc = "󱚟 Windsurf toggle" },
		{ "<leader>aC", desc = "󰭹 Windsurf chat" },
		{ "<leader>aA", desc = "󰷖 Windsurf auth" },
		{ "<leader>aS", desc = "󰋼 Windsurf status" },

			-- Explorer (nvim-tree)
			{ "<leader>ee", desc = "󰉋 Toggle tree" },
			{ "<leader>ef", desc = "󰈔 Find in tree" },
			{ "<leader>ec", desc = "󰝥 Collapse tree" },
			{ "<leader>er", desc = "󰑓 Refresh tree" },

			-- Oil (uses `-` by default for parent dir)
			{ "<leader>-", desc = "󰏖 Oil (floating)" },

			-- Find (telescope) with icons
			{ "<leader>ff", desc = "󰱼 Fuzzy find files in cwd" },
			{ "<leader>fr", desc = "󰄉 Fuzzy find recent files" },
			{ "<leader>fs", desc = "󰊢 Find string in cwd" },
			{ "<leader>fc", desc = "󰊢 Find string under cursor in cwd" },
			{ "<leader>ft", desc = "󰔫 Find todos" },
			{ "<leader>fb", desc = "󰈔 Open telescope buffers" },
			
			
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

			-- LSP (uses Neovim defaults: K=hover, gd=definition, gD=declaration, gi=impl, gr=refs)
			{ "gR", desc = "󰞔 References (Telescope)" },
			{ "<leader>ca", desc = "󰨞 Code action" },
			{ "<leader>rn", desc = "󰑓 Rename" },
			{ "<leader>D", desc = "󰔫 Diagnostics (Telescope)" },
			{ "<leader>d", desc = "󰔫 Line diagnostic" },
			{ "<leader>rs", desc = "󰑄 Restart LSP" },
			
			-- UI toggles
			{ "<leader>u", group = "󰨞 UI Toggle" },
			{ "<leader>uh", desc = "󰨞 Toggle inlay hints" },
			{ "<leader>uv", desc = "󰨞 Toggle virtual text diagnostics" },

			-- Markdown with icons
			{ "<leader>mm", group = "󰍍 Markdown" },
			{ "<leader>mv", desc = "󰍍 Toggle markdown preview" },
			{ "<leader>ms", desc = "󰐊 Stop markdown preview" },


			-- Live Server
			{ "<leader>ls", desc = "Start live server and open current file" },
			{ "<leader>lS", desc = "Show live server status" },
			{ "<leader>lc", desc = "Stop serving a directory" },
			{ "<leader>lC", desc = "Stop all live servers" },
			{ "<leader>ll", desc = "Open live server log" },

			-- HTTP Client (under <leader>H - capital H)
			{ "<leader>H", group = "󰖟 HTTP" },
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


			-- LazyGit
			{ "<leader>lg", desc = "Open lazy git" },

			-- CSV
			{ "<leader>cs", desc = "Toggle CSV view" },

			-- Arrow (file bookmarks)
			{ ";", desc = "Arrow bookmarks" },
			{ "m", desc = "Arrow buffer bookmarks" },

			-- Color highlighter (nvim-highlight-colors)
			{ "<leader>ch", desc = "󰌁 Toggle color highlighter" },

		})
	end,
}
