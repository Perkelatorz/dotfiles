return {
	"folke/which-key.nvim",
	event = "VeryLazy",
	init = function()
		vim.o.timeout = true
		vim.o.timeoutlen = 500
	end,
	config = function()
		local status_ok, which_key = pcall(require, "which-key")
		if not status_ok then
			return
		end

		which_key.add({
			-- Groups
			{ "<leader>a", group = "AI" },
			{ "<leader>c", group = "Code" },
			{ "<leader>d", group = "Debug" },
			{ "<leader>e", group = "Explorer" },
			{ "<leader>f", group = "Find" },
			{ "<leader>h", group = "Git Hunk" },
			{ "<leader>k", group = "HTTP" },
			{ "<leader>l", group = "Lazy" },
			{ "<leader>m", group = "Markdown/Format" },
			{ "<leader>n", group = "Clear" },
			{ "<leader>o", group = "Oil" },
			{ "<leader>r", group = "Rename/Restart" },
			{ "<leader>s", group = "Substitute/Session/Spell" },
			{ "<leader>t", group = "Test" },
			{ "<leader>w", group = "Session" },
			{ "<leader>x", group = "Trouble" },

			-- Core keymaps
			{ "<leader>nh", desc = "Clear search highlights" },
			{ "<leader>+", desc = "Increment number" },
			{ "<leader>=", desc = "Decrement number" },
			{ "<leader>sc", desc = "Toggle spell check" },

			-- AI (CodeCompanion)
			{ "<leader>aa", desc = "CodeCompanion actions", mode = { "n", "v" } },
			{ "<leader>ac", desc = "Toggle CodeCompanion chat", mode = { "n", "v" } },
			{ "<leader>ai", desc = "Add selection to chat", mode = "v" },
			{ "<leader>at", desc = "Open CodeCompanion chat" },
			{ "<leader>ap", desc = "Inline CodeCompanion prompt", mode = { "n", "v" } },

			-- Explorer (nvim-tree)
			{ "<leader>ee", desc = "Toggle file explorer" },
			{ "<leader>ef", desc = "Toggle file explorer on current file" },
			{ "<leader>ec", desc = "Collapse file explorer" },
			{ "<leader>er", desc = "Refresh file explorer" },
			{ "<leader>eo", desc = "Open oil file explorer" },

			-- Oil
			{ "<leader>of", desc = "Open oil in floating window" },
			{ "-", desc = "Open parent directory (oil)" },

			-- Find (telescope)
			{ "<leader>ff", desc = "Fuzzy find files in cwd" },
			{ "<leader>fr", desc = "Fuzzy find recent files" },
			{ "<leader>fs", desc = "Find string in cwd" },
			{ "<leader>fc", desc = "Find string under cursor in cwd" },
			{ "<leader>ft", desc = "Find todos" },
			{ "<leader>fb", desc = "Open telescope buffers" },

			-- Format
			{ "<leader>mp", desc = "Format file or range" },
			{ "<leader>mv", desc = "Toggle markdown preview" },
			{ "<leader>ms", desc = "Stop markdown preview" },

			-- Session (auto-session)
			{ "<leader>wr", desc = "Restore session for cwd" },
			{ "<leader>ws", desc = "Save session for cwd" },

			-- Trouble
			{ "<leader>xw", desc = "Open trouble workspace diagnostics" },
			{ "<leader>xd", desc = "Open trouble document diagnostics" },
			{ "<leader>xq", desc = "Open trouble quickfix list" },
			{ "<leader>xl", desc = "Open trouble location list" },
			{ "<leader>xt", desc = "Open todos in trouble" },

			-- LSP
			{ "<leader>D", desc = "Show buffer diagnostics" },
			{ "<leader>rs", desc = "Restart LSP" },
			{ "[d", desc = "Go to previous diagnostic" },
			{ "]d", desc = "Go to next diagnostic" },

			-- Markdown
			{ "<leader>mm", group = "Markdown" },
			{ "<leader>mv", desc = "Toggle markdown preview" },
			{ "<leader>ms", desc = "Stop markdown preview" },

			-- Test (neotest / test runners)
			{ "<leader>t", group = "Test" },
			{ "<leader>tr", desc = "Run nearest test" },
			{ "<leader>tf", desc = "Run current test file" },
			{ "<leader>td", desc = "Debug nearest test" },
			{ "<leader>ts", desc = "Stop nearest test" },
			{ "<leader>ta", desc = "Attach to nearest test" },
			{ "<leader>tw", desc = "Toggle watch current file" },
			{ "<leader>tS", desc = "Toggle test summary" },
			{ "<leader>to", desc = "Show test output" },
			{ "<leader>tO", desc = "Toggle test output panel" },
			{ "[T", desc = "Jump to previous failed test" },
			{ "]T", desc = "Jump to next failed test" },

			-- Debug
			{ "<leader>d", group = "Debug" },
			{ "<leader>db", desc = "Toggle breakpoint" },
			{ "<leader>dB", desc = "Set conditional breakpoint" },
			{ "<leader>dc", desc = "Continue/Start debugging" },
			{ "<leader>di", desc = "Step into" },
			{ "<leader>do", desc = "Step over" },
			{ "<leader>dO", desc = "Step out" },
			{ "<leader>dr", desc = "Open REPL" },
			{ "<leader>dl", desc = "Run last debug session" },
			{ "<leader>dt", desc = "Terminate debug session" },
			{ "<leader>du", desc = "Toggle debug UI" },
			{ "<leader>dh", desc = "Debug hover" },
			{ "<leader>dp", desc = "Debug preview" },
			{ "<leader>df", desc = "Show frames" },
			{ "<leader>ds", desc = "Show scopes" },
			{ "<leader>dpt", desc = "Debug Python test method" },
			{ "<leader>dpc", desc = "Debug Python test class" },
			{ "<leader>dps", desc = "Debug Python selection", mode = "v" },
			{ "<leader>dgt", desc = "Debug Go test" },
			{ "<leader>dgl", desc = "Debug last Go test" },

			-- HTTP (rest.nvim / http.nvim etc)
			{ "<leader>k", group = "HTTP" },
			{ "<leader>kr", desc = "Run HTTP request" },
			{ "<leader>kt", desc = "Toggle HTTP view" },
			{ "<leader>kp", desc = "Jump to previous request" },
			{ "<leader>kn", desc = "Jump to next request" },
			{ "<leader>ki", desc = "Inspect HTTP request" },
			{ "<leader>kc", desc = "Copy as cURL" },
			{ "<leader>ks", desc = "Open HTTP scratchpad" },
			{ "<leader>kq", desc = "Close HTTP view" },

			-- Git Hunks (gitsigns)
			{ "<leader>hs", desc = "Stage hunk" },
			{ "<leader>hr", desc = "Reset hunk" },
			{ "<leader>hS", desc = "Stage buffer" },
			{ "<leader>hR", desc = "Reset buffer" },
			{ "<leader>hu", desc = "Undo stage hunk" },
			{ "<leader>hp", desc = "Preview hunk" },
			{ "<leader>hb", desc = "Blame line" },
			{ "<leader>hB", desc = "Toggle line blame" },
			{ "<leader>hd", desc = "Diff this" },
			{ "<leader>hD", desc = "Diff this ~" },
			{ "[h", desc = "Previous git hunk" },
			{ "]h", desc = "Next git hunk" },

			-- Todo comments
			{ "[t", desc = "Previous todo comment" },
			{ "]t", desc = "Next todo comment" },

			-- Substitute
			{ "<leader>s", desc = "Substitute range operator", mode = { "n", "x" } },
			{ "<leader>ss", desc = "Substitute word" },
			{ "s", desc = "Substitute with motion/visual", mode = { "n", "x" } },
			{ "ss", desc = "Substitute line" },
			{ "S", desc = "Substitute to end of line" },

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
