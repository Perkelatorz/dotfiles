-- set leader key to space
vim.g.mapleader = " "

local keymap = vim.keymap -- for conciseness

---------------------
-- General Keymaps -------------------

-- use jk to exit insert mode
keymap.set("i", "jk", "<ESC>", { desc = "Exit insert mode with jk" })

-- clear search highlights
keymap.set("n", "<leader>nh", ":nohl<CR>", { desc = "Clear search highlights" })

-- increment/decrement numbers
keymap.set("n", "<leader>+", "<C-a>", { desc = "Increment number" }) -- increment
keymap.set("n", "<leader>=", "<C-x>", { desc = "Decrement number" }) -- decrement

-- spelling check
keymap.set("n", "<leader>sc", ":set spell!<CR>", { desc = "Spell Check" })

-- ===== Zeal-only Docs Keymaps =====

-- Detect filetype and get buffer text
local function detect_context()
	local ft = (vim.bo.filetype or ""):lower()
	local buf = table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), "\n")
	return ft, buf
end

-- Guess Zeal docset based on filetype and simple import heuristics
local function zeal_docset_for_buffer()
	local ft, buf = detect_context()
	local function has(pat)
		return buf:find(pat) ~= nil
	end

	if ft == "python" then
		if has("fastapi") then
			return "fastapi"
		elseif has("pydantic") then
			return "pydantic"
		elseif has("starlette") then
			return "starlette"
		elseif has("numpy") or has("np%s*=") then
			return "numpy"
		elseif has("pandas") or has("pd%s*=") then
			return "pandas"
		elseif has("django") then
			return "django"
		elseif has("sqlalchemy") then
			return "sqlalchemy"
		elseif has("requests") then
			return "requests"
		elseif has("pytest") then
			return "pytest"
		else
			return "python"
		end
	elseif ft == "sh" or ft == "bash" or ft == "zsh" then
		return "bash"
	elseif ft == "lua" then
		-- Use "neovim" docset if editing Neovim/Lua configs
		if has("vim%.") or has("require%(['\"]vim") then
			return "neovim"
		else
			return "lua"
		end
	elseif ft == "go" then
		return "go"
	elseif ft == "javascript" or ft == "javascriptreact" or ft == "typescript" or ft == "typescriptreact" then
		if has("from%s+['\"]react") or has("require%(['\"]react") then
			return "react"
		elseif has("from%s+['\"]vue") or has("require%(['\"]vue") then
			return "vue"
		elseif has("from%s+['\"]svelte") or has("require%(['\"]svelte") then
			return "svelte"
		elseif has("from%s+['\"]node:") or has("require%(['\"]node:") then
			return "nodejs"
		else
			return "javascript"
		end
	elseif ft == "html" then
		return "html"
	elseif ft == "css" or ft == "scss" or ft == "less" then
		return "css"
	elseif ft == "json" then
		return "json"
	elseif ft == "yaml" or ft == "yml" then
		return "yaml"
	elseif ft == "dockerfile" then
		return "docker"
	elseif ft == "sql" then
		return "postgresql" -- change to mysql/sqlite if that’s your main DB
	elseif ft == "markdown" then
		return "markdown"
	else
		return nil -- no specific docset
	end
end

-- Primary: quick Zeal lookup
vim.keymap.set("n", "<leader>zd", function()
	local word = vim.fn.expand("<cword>")
	if not word or word == "" then
		vim.notify("No word under cursor", vim.log.levels.WARN)
		return
	end
	-- Simple: just ask Zeal; user’s last docset filter will apply
	vim.fn.jobstart({ "zeal", word }, { detach = true })
end, { desc = "Docs: Zeal for symbol" })

-- Smart docset: Zeal with docset filter like "numpy:linspace"
vim.keymap.set("n", "<leader>zD", function()
	local word = vim.fn.expand("<cword>")
	if not word or word == "" then
		vim.notify("No word under cursor", vim.log.levels.WARN)
		return
	end
	local docset = zeal_docset_for_buffer()
	local query = docset and (docset .. ":" .. word) or word
	vim.fn.jobstart({ "zeal", query }, { detach = true })
end, { desc = "Docs: Zeal (smart docset)" })

-- Optional: keep Python pydoc handy
vim.keymap.set("n", "<leader>zp", function()
	local word = vim.fn.expand("<cword>")
	if not word or word == "" then
		vim.notify("No word under cursor", vim.log.levels.WARN)
		return
	end
	vim.cmd("botright 12split | terminal python -m pydoc " .. word)
end, { desc = "Docs: pydoc (terminal split)" })

-- Helper: URL encode
local function urlencode(s)
	return (s:gsub("[^%w%-_%.~]", function(c)
		return string.format("%%%02X", string.byte(c))
	end))
end

-- Helper: cross-platform opener
local function URLViewer(url)
	if vim.ui and vim.ui.open then
		vim.ui.open(url)
		return
	end
	if vim.fn.has("mac") == 1 then
		vim.fn.jobstart({ "open", url }, { detach = true })
	elseif vim.fn.has("win32") == 1 then
		vim.fn.jobstart({ "cmd.exe", "/c", "start", "", url }, { detach = true })
	else
		vim.fn.jobstart({ "xdg-open", url }, { detach = true })
	end
end

vim.keymap.set("n", "<leader>zv", function()
	local word = vim.fn.expand("<cword>")
	if not word or word == "" then
		vim.notify("No word under cursor", vim.log.levels.WARN)
		return
	end

	local ft = (vim.bo.filetype or ""):lower()
	local url

	if ft == "python" then
		url = "https://docs.python.org/3/search.html?q=" .. urlencode(word)
	elseif
		ft == "javascript"
		or ft == "typescript"
		or ft == "javascriptreact"
		or ft == "typescriptreact"
		or ft == "html"
		or ft == "css"
		or ft == "scss"
		or ft == "less"
	then
		url = "https://developer.mozilla.org/search?q=" .. urlencode(word)
	elseif ft == "go" then
		url = "https://pkg.go.dev/search?q=" .. urlencode(word)
	elseif ft == "sh" or ft == "bash" or ft == "zsh" then
		url = "https://www.google.com/search?q=" .. urlencode("site:man7.org/linux/man-pages " .. word)
	elseif ft == "lua" then
		url = "https://devdocs.io/lua~5.4/search?q=" .. urlencode(word)
	elseif ft == "dockerfile" then
		url = "https://docs.docker.com/search/?q=" .. urlencode(word)
	elseif ft == "sql" then
		url = "https://www.postgresql.org/search/?q=" .. urlencode(word)
	else
		url = "https://devdocs.io/#q=" .. urlencode(word)
	end

	URLViewer(url)
end, { desc = "Docs: DevDocs/Docs (smart)" })
