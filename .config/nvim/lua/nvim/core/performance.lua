-- Performance monitoring and profiling helpers

local M = {}

-- Measure startup time with detailed breakdown
function M.startup_time()
	vim.cmd("StartupTime")
end

-- Profile Neovim performance
function M.profile_start()
	vim.cmd("profile start /tmp/nvim-profile.log")
	vim.cmd("profile func *")
	vim.cmd("profile file *")
	vim.notify("Profiling started. Output: /tmp/nvim-profile.log", vim.log.levels.INFO)
end

function M.profile_stop()
	vim.cmd("profile stop")
	vim.notify("Profiling stopped. Check: /tmp/nvim-profile.log", vim.log.levels.INFO)
end

-- Display current memory usage
function M.memory_usage()
	local mem = vim.fn.system("ps -o rss= -p " .. vim.fn.getpid())
	mem = tonumber(mem)
	if mem then
		local mb = mem / 1024
		vim.notify(string.format("Neovim memory usage: %.2f MB", mb), vim.log.levels.INFO)
	end
end

-- Display plugin count and load time
function M.plugin_stats()
	local lazy_ok, lazy = pcall(require, "lazy")
	if not lazy_ok then
		vim.notify("Lazy.nvim not loaded", vim.log.levels.WARN)
		return
	end
	
	local plugins = lazy.plugins()
	local loaded = 0
	for _, plugin in pairs(plugins) do
		if plugin._.loaded then
			loaded = loaded + 1
		end
	end
	
	vim.notify(
		string.format("Plugins: %d total, %d loaded", #plugins, loaded),
		vim.log.levels.INFO
	)
end

-- Check Neovim health
function M.check_health()
	vim.cmd("checkhealth")
end

-- Display startup time in a float window
function M.startup_info()
	local stats = vim.fn.execute("version")
	local lines = vim.split(stats, "\n")
	
	-- Get startup time if available
	local startup_time = vim.fn.has("vim_starting") == 0 and vim.fn.reltimestr(vim.fn.reltime(vim.g.start_time)) or "N/A"
	
	table.insert(lines, "")
	table.insert(lines, "Startup time: " .. startup_time .. "ms")
	
	-- Create floating window
	local buf = vim.api.nvim_create_buf(false, true)
	local width = 80
	local height = math.min(#lines + 2, vim.o.lines - 10)
	
	local opts = {
		relative = "editor",
		width = width,
		height = height,
		col = (vim.o.columns - width) / 2,
		row = (vim.o.lines - height) / 2,
		style = "minimal",
		border = "rounded",
	}
	
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
	vim.api.nvim_open_win(buf, true, opts)
	vim.keymap.set("n", "q", ":close<CR>", { buffer = buf, silent = true })
	vim.bo[buf].modifiable = false
end

-- Create user commands
vim.api.nvim_create_user_command("StartupTime", M.startup_info, { desc = "Show startup time" })
vim.api.nvim_create_user_command("ProfileStart", M.profile_start, { desc = "Start profiling" })
vim.api.nvim_create_user_command("ProfileStop", M.profile_stop, { desc = "Stop profiling" })
vim.api.nvim_create_user_command("MemoryUsage", M.memory_usage, { desc = "Show memory usage" })
vim.api.nvim_create_user_command("PluginStats", M.plugin_stats, { desc = "Show plugin statistics" })

return M
