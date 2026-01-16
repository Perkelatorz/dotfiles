return {
	"sudo-tee/opencode.nvim",
	dependencies = {
		"MunifTanjim/nui.nvim",
	},
	config = function()
		local utils = require("nvim.core.utils")
		
		local opencode, opencode_ok = utils.safe_require("opencode")
		if not opencode_ok then
			return
		end

		opencode.setup({
			-- Configuration options
			keymap_prefix = "<leader>ao",
			default_global_keymaps = false, -- We'll define our own keymaps
			window = {
				width = 0.8,
				height = 0.8,
				border = "rounded",
			},
		})

		-- Keymaps for OpenCode
		local keymap = vim.keymap
		
		-- ============================================
		-- Main OpenCode Commands
		-- ============================================
		
		-- Toggle OpenCode UI (main command)
		keymap.set("n", "<leader>ao", "<cmd>Opencode<cr>", { desc = "OpenCode" })
		
		-- Window management
		keymap.set("n", "<leader>ai", "<cmd>OpencodeInput<cr>", { desc = "OpenCode input" })
		keymap.set("n", "<leader>aO", "<cmd>OpencodeOutput<cr>", { desc = "OpenCode output" })
		keymap.set("n", "<leader>aq", "<cmd>OpencodeClose<cr>", { desc = "OpenCode close" })
		
		-- ============================================
		-- Context Management - Send Code to OpenCode
		-- ============================================
		
		-- Send current selection to OpenCode (visual mode)
		keymap.set("v", "<leader>as", function()
			-- Get the selected text
			local start_pos = vim.fn.getpos("'<")
			local end_pos = vim.fn.getpos("'>")
			local lines = vim.fn.getline(start_pos[2], end_pos[2])
			
			if #lines == 0 then
				vim.notify("No selection to send", vim.log.levels.WARN)
				return
			end
			
			-- Handle partial line selection
			if #lines == 1 then
				lines[1] = string.sub(lines[1], start_pos[3], end_pos[3])
			else
				lines[1] = string.sub(lines[1], start_pos[3])
				lines[#lines] = string.sub(lines[#lines], 1, end_pos[3])
			end
			
			local selected_text = table.concat(lines, "\n")
			local filename = vim.fn.expand("%:t")
			local filetype = vim.bo.filetype
			
			-- Open OpenCode and send the selection with context
			vim.cmd("Opencode")
			vim.defer_fn(function()
				local prompt = string.format("```%s\n-- File: %s\n%s\n```\n\n", filetype, filename, selected_text)
				vim.fn.setreg("+", prompt)
				vim.notify("Selection copied to clipboard with context", vim.log.levels.INFO)
			end, 100)
		end, { desc = "Send selection to OpenCode" })
		
		-- Send current file to OpenCode
		keymap.set("n", "<leader>af", function()
			local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
			local content = table.concat(lines, "\n")
			local filename = vim.fn.expand("%:p")
			local relative_path = vim.fn.expand("%:.")
			local filetype = vim.bo.filetype
			
			vim.cmd("Opencode")
			vim.defer_fn(function()
				local prompt = string.format("```%s\n-- File: %s\n%s\n```\n\n", filetype, relative_path, content)
				vim.fn.setreg("+", prompt)
				vim.notify("File content copied to clipboard with context", vim.log.levels.INFO)
			end, 100)
		end, { desc = "Send current file to OpenCode" })
		
		-- Send current function/block to OpenCode
		keymap.set("n", "<leader>ab", function()
			-- Use treesitter to get current function
			local ts_ok, ts_utils = pcall(require, "nvim-treesitter.ts_utils")
			if not ts_ok then
				vim.notify("Treesitter not available", vim.log.levels.WARN)
				return
			end
			
			local node = ts_utils.get_node_at_cursor()
			while node do
				local node_type = node:type()
				if node_type:match("function") or node_type:match("method") or node_type:match("class") then
					local start_row, _, end_row, _ = node:range()
					local lines = vim.api.nvim_buf_get_lines(0, start_row, end_row + 1, false)
					local content = table.concat(lines, "\n")
					local filename = vim.fn.expand("%:.")
					local filetype = vim.bo.filetype
					
					vim.cmd("Opencode")
					vim.defer_fn(function()
						local prompt = string.format("```%s\n-- File: %s (line %d-%d)\n%s\n```\n\n", 
							filetype, filename, start_row + 1, end_row + 1, content)
						vim.fn.setreg("+", prompt)
						vim.notify("Block copied to clipboard with context", vim.log.levels.INFO)
					end, 100)
					return
				end
				node = node:parent()
			end
			
			vim.notify("No function/method/class found at cursor", vim.log.levels.WARN)
		end, { desc = "Send current block to OpenCode" })
		
		-- Send diagnostics to OpenCode
		keymap.set("n", "<leader>ad", function()
			local diagnostics = vim.diagnostic.get(0)
			if #diagnostics == 0 then
				vim.notify("No diagnostics in current buffer", vim.log.levels.INFO)
				return
			end
			
			local filename = vim.fn.expand("%:.")
			local output = {"Diagnostics for " .. filename .. ":\n"}
			
			for _, diag in ipairs(diagnostics) do
				local severity = vim.diagnostic.severity[diag.severity]
				table.insert(output, string.format("[%s] Line %d: %s", severity, diag.lnum + 1, diag.message))
			end
			
			vim.cmd("Opencode")
			vim.defer_fn(function()
				local prompt = table.concat(output, "\n") .. "\n\n"
				vim.fn.setreg("+", prompt)
				vim.notify("Diagnostics copied to clipboard", vim.log.levels.INFO)
			end, 100)
		end, { desc = "Send diagnostics to OpenCode" })
		
		-- ============================================
		-- Quick Commands
		-- ============================================
		
		-- Ask about current line
		keymap.set("n", "<leader>al", function()
			local line = vim.fn.getline(".")
			local line_num = vim.fn.line(".")
			local filename = vim.fn.expand("%:.")
			local filetype = vim.bo.filetype
			
			vim.cmd("Opencode")
			vim.defer_fn(function()
				local prompt = string.format("```%s\n-- File: %s (line %d)\n%s\n```\n\nExplain this line:\n", 
					filetype, filename, line_num, line)
				vim.fn.setreg("+", prompt)
				vim.notify("Line copied to clipboard with context", vim.log.levels.INFO)
			end, 100)
		end, { desc = "Ask about current line" })
		
		-- Explain error under cursor
		keymap.set("n", "<leader>ae", function()
			local diagnostics = vim.diagnostic.get(0, { lnum = vim.fn.line(".") - 1 })
			if #diagnostics == 0 then
				vim.notify("No diagnostic at cursor", vim.log.levels.WARN)
				return
			end
			
			local diag = diagnostics[1]
			local line = vim.fn.getline(".")
			local filename = vim.fn.expand("%:.")
			
			vim.cmd("Opencode")
			vim.defer_fn(function()
				local prompt = string.format("File: %s\nLine: %s\nError: %s\n\nHelp me fix this error:\n", 
					filename, line, diag.message)
				vim.fn.setreg("+", prompt)
				vim.notify("Error copied to clipboard", vim.log.levels.INFO)
			end, 100)
		end, { desc = "Explain error under cursor" })
		
		-- Quick chat (same as main toggle)
		keymap.set("n", "<leader>ac", "<cmd>Opencode<cr>", { desc = "OpenCode chat" })
		
		-- ============================================
		-- Codebase Context - Give OpenCode Full Project Access
		-- ============================================
		
		-- Send project structure (tree view)
		keymap.set("n", "<leader>aP", function()
			local cwd = vim.fn.getcwd()
			local cmd = "find . -type f -not -path '*/\\.*' -not -path '*/node_modules/*' -not -path '*/vendor/*' -not -path '*/__pycache__/*' -not -path '*/target/*' -not -path '*/dist/*' -not -path '*/build/*' | head -500"
			
			local handle = io.popen(cmd)
			if not handle then
				vim.notify("Failed to get project structure", vim.log.levels.ERROR)
				return
			end
			
			local result = handle:read("*a")
			handle:close()
			
			vim.cmd("Opencode")
			vim.defer_fn(function()
				local prompt = string.format("Project Structure for: %s\n\n```\n%s\n```\n\n", cwd, result)
				vim.fn.setreg("+", prompt)
				vim.notify("Project structure copied (first 500 files)", vim.log.levels.INFO)
			end, 100)
		end, { desc = "Send project structure" })
		
		-- Send multiple files by glob pattern
		keymap.set("n", "<leader>aG", function()
			vim.ui.input({ prompt = "Enter glob pattern (e.g., **/*.lua, src/**/*.ts): " }, function(pattern)
				if not pattern or pattern == "" then
					return
				end
				
				local cwd = vim.fn.getcwd()
				-- Convert glob to find command
				local cmd = string.format("find . -type f -name '%s' | head -50", pattern:gsub("%*%*/", ""))
				
				local handle = io.popen(cmd)
				if not handle then
					vim.notify("Failed to find files", vim.log.levels.ERROR)
					return
				end
				
				local files = {}
				for file in handle:lines() do
					table.insert(files, file)
				end
				handle:close()
				
				if #files == 0 then
					vim.notify("No files found matching pattern: " .. pattern, vim.log.levels.WARN)
					return
				end
				
				-- Read content of all files
				local output = {string.format("Files matching pattern '%s':\n", pattern)}
				for _, file in ipairs(files) do
					local content_handle = io.open(file, "r")
					if content_handle then
						local content = content_handle:read("*a")
						content_handle:close()
						local filetype = vim.filetype.match({ filename = file }) or ""
						table.insert(output, string.format("\n```%s\n-- File: %s\n%s\n```\n", filetype, file, content))
					end
				end
				
				vim.cmd("Opencode")
				vim.defer_fn(function()
					local prompt = table.concat(output, "\n")
					vim.fn.setreg("+", prompt)
					vim.notify(string.format("Copied %d files matching '%s'", #files, pattern), vim.log.levels.INFO)
				end, 100)
			end)
		end, { desc = "Send files by pattern" })
		
		-- Send key project files (README, config, etc.)
		keymap.set("n", "<leader>aK", function()
			local cwd = vim.fn.getcwd()
			local key_files = {
				"README.md", "README.txt", "README",
				"package.json", "Cargo.toml", "go.mod", "requirements.txt", "Gemfile", "pom.xml", "build.gradle",
				"tsconfig.json", "jsconfig.json", ".eslintrc.js", ".eslintrc.json",
				"pyproject.toml", "setup.py", "Makefile", "CMakeLists.txt"
			}
			
			local output = {string.format("Key Project Files for: %s\n", cwd)}
			local found_count = 0
			
			for _, filename in ipairs(key_files) do
				local filepath = cwd .. "/" .. filename
				local file = io.open(filepath, "r")
				if file then
					local content = file:read("*a")
					file:close()
					local filetype = vim.filetype.match({ filename = filename }) or ""
					table.insert(output, string.format("\n```%s\n-- File: %s\n%s\n```\n", filetype, filename, content))
					found_count = found_count + 1
				end
			end
			
			if found_count == 0 then
				vim.notify("No key project files found", vim.log.levels.WARN)
				return
			end
			
			vim.cmd("Opencode")
			vim.defer_fn(function()
				local prompt = table.concat(output, "\n")
				vim.fn.setreg("+", prompt)
				vim.notify(string.format("Copied %d key project files", found_count), vim.log.levels.INFO)
			end, 100)
		end, { desc = "Send key project files" })
		
		-- Send directory contents (current or specified)
		keymap.set("n", "<leader>aD", function()
			vim.ui.input({ 
				prompt = "Enter directory (or leave empty for current file's dir): ",
				default = vim.fn.expand("%:h")
			}, function(dir)
				if not dir or dir == "" then
					dir = vim.fn.expand("%:h")
				end
				
				-- Get all files in directory
				local cmd = string.format("find '%s' -maxdepth 1 -type f | head -50", dir)
				local handle = io.popen(cmd)
				if not handle then
					vim.notify("Failed to read directory", vim.log.levels.ERROR)
					return
				end
				
				local files = {}
				for file in handle:lines() do
					table.insert(files, file)
				end
				handle:close()
				
				if #files == 0 then
					vim.notify("No files found in: " .. dir, vim.log.levels.WARN)
					return
				end
				
				-- Read content of all files
				local output = {string.format("Files in directory '%s':\n", dir)}
				for _, file in ipairs(files) do
					local content_handle = io.open(file, "r")
					if content_handle then
						local content = content_handle:read("*a")
						content_handle:close()
						local filetype = vim.filetype.match({ filename = file }) or ""
						local relative = file:gsub("^" .. vim.fn.getcwd() .. "/", "")
						table.insert(output, string.format("\n```%s\n-- File: %s\n%s\n```\n", filetype, relative, content))
					end
				end
				
				vim.cmd("Opencode")
				vim.defer_fn(function()
					local prompt = table.concat(output, "\n")
					vim.fn.setreg("+", prompt)
					vim.notify(string.format("Copied %d files from %s", #files, dir), vim.log.levels.INFO)
				end, 100)
			end)
		end, { desc = "Send directory contents" })
		
		-- Send git diff (uncommitted changes)
		keymap.set("n", "<leader>ag", function()
			local handle = io.popen("git diff HEAD")
			if not handle then
				vim.notify("Failed to get git diff (is this a git repo?)", vim.log.levels.ERROR)
				return
			end
			
			local diff = handle:read("*a")
			handle:close()
			
			if diff == "" then
				vim.notify("No uncommitted changes", vim.log.levels.INFO)
				return
			end
			
			vim.cmd("Opencode")
			vim.defer_fn(function()
				local prompt = string.format("Git Diff (uncommitted changes):\n\n```diff\n%s\n```\n\n", diff)
				vim.fn.setreg("+", prompt)
				vim.notify("Git diff copied to clipboard", vim.log.levels.INFO)
			end, 100)
		end, { desc = "Send git diff" })
		
		-- Send recent git changes (last N commits)
		keymap.set("n", "<leader>aL", function()
			vim.ui.input({ 
				prompt = "Number of recent commits to include: ",
				default = "5"
			}, function(input)
				if not input or input == "" then
					return
				end
				
				local count = tonumber(input) or 5
				local cmd = string.format("git log -p -n %d", count)
				local handle = io.popen(cmd)
				if not handle then
					vim.notify("Failed to get git log (is this a git repo?)", vim.log.levels.ERROR)
					return
				end
				
				local log = handle:read("*a")
				handle:close()
				
				vim.cmd("Opencode")
				vim.defer_fn(function()
					local prompt = string.format("Git Log (last %d commits):\n\n```diff\n%s\n```\n\n", count, log)
					vim.fn.setreg("+", prompt)
					vim.notify(string.format("Git log (%d commits) copied", count), vim.log.levels.INFO)
				end, 100)
			end)
		end, { desc = "Send git log with changes" })
		
		-- ============================================
		-- Additional Utilities
		-- ============================================
		
		-- Copy file path for context
		keymap.set("n", "<leader>ap", function()
			local filepath = vim.fn.expand("%:p")
			vim.fn.setreg("+", filepath)
			vim.notify("File path copied: " .. filepath, vim.log.levels.INFO)
		end, { desc = "Copy file path" })
		
		-- Show OpenCode help
		keymap.set("n", "<leader>a?", function()
			local help_text = [[
OpenCode Keybindings (all under <leader>a):
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Main:
  ao  - Toggle OpenCode
  ai  - Input window
  aO  - Output window
  aq  - Close
  ac  - Chat

Send Context (lowercase):
  as  - Selection (visual)
  af  - File
  ab  - Block/function
  ad  - Diagnostics
  al  - Line
  ae  - Error
  ag  - Git diff

Project Context (uppercase):
  aP  - Project structure
  aG  - Files by pattern
  aK  - Key files
  aD  - Directory
  aL  - Git log

Utils:
  ap  - Copy file path
  a?  - This help
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
]]
			vim.notify(help_text, vim.log.levels.INFO)
		end, { desc = "Show OpenCode help" })
	end,
}
