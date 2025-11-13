-- This is our "docs" module, now with two smart Telescope pickers
local M = {}

---
-- @const: Your preferred search engine.
M.search_engine = "https://www.google.com/search?q=%s"
-- M.search_engine = "https://duckduckgo.com/?q=%s"

---
-- @const: How many lines to scan for context.
local LINES_TO_SCAN = 200

---
-- Configuration table: All filetype-specific logic lives here.
M.config = {
	python = {
		zeal_rules = {
			{ "fastapi", "fastapi" },
			{ "pydantic", "pydantic" },
			{ "starlette", "starlette" },
			{ "numpy", "numpy" },
			{ "np%s*=", "numpy" },
			{ "pandas", "pandas" },
			{ "pd%s*=", "pandas" },
			{ "django", "django" },
			{ "sqlalchemy", "sqlalchemy" },
			{ "requests", "requests" },
			{ "pytest", "pytest" },
		},
		zeal_default = "python", -- The fallback
		web_url = "https://docs.python.org/3/search.html?q=%s",
	},
	javascript = {
		zeal_rules = {
			{ "from%s+['\"]react", "react" },
			{ "require%(['\"]react", "react" },
			{ "from%s+['\"]vue", "vue" },
			{ "require%(['\"]vue", "vue" },
			{ "from%s+['\"]svelte", "svelte" },
			{ "require%(['\"]svelte", "svelte" },
			{ "from%s+['\"]node:", "nodejs" },
			{ "require%(['\"]node:", "nodejs" },
		},
		zeal_default = "javascript",
		web_url = "https://developer.mozilla.org/search?q=%s",
	},
	cs = {
		zeal_rules = {
			{ "using%s+Microsoft%.AspNetCore", "aspnetcore" },
			{ "using%s+Microsoft%.EntityFrameworkCore", "entityframeworkcore" },
		},
		zeal_default = "csharp",
		web_url = "https://learn.microsoft.com/en-us/search/?terms=%s",
	},
	powershell = {
		zeal = "powershell",
		web_query = "powershell %s",
		web_url = "https://learn.microsoft.com/en-us/search/?terms=%s",
	},
	lua = {
		zeal_rules = {
			{ "vim%.", "neovim" },
			{ "require%(['\"]vim", "neovim" },
		},
		zeal_default = "lua",
		web_url = function(has)
			if has("vim%.") or has("require%(['\"]vim") then
				return "https://neovim.io/doc/user/search.html?q=%s"
			end
			return "https://devdocs.io/lua~5.4/search?q=%s"
		end,
	},
	bash = {
		zeal = "bash",
		web_query = "site:man7.org/linux/man-pages %s",
		web_url = "https://www.google.com/search?q=%s",
	},
	-- Simplified entries
	go = { zeal_default = "go", web_url = "https://pkg.go.dev/search?q=%s" },
	html = { zeal_default = "html", web_url = "https://developer.mozilla.org/search?q=%s" },
	css = { zeal_default = "css", web_url = "https://developer.mozilla.org/search?q=%s" },
	dockerfile = { zeal_default = "docker", web_url = "https://docs.docker.com/search/?q=%s" },
	sql = { zeal_default = "postgresql", web_url = "https://www.postgresql.org/search/?q=%s" },
	json = { zeal_default = "json" },
	yaml = { zeal_default = "yaml" },
	markdown = { zeal_default = "markdown" },
	-- Aliases
	sh = "bash",
	zsh = "bash",
	typescript = "javascript",
	javascriptreact = "javascript",
	typescriptreact = "javascript",
	scss = "css",
	less = "css",
	yml = "yaml",
	-- Fallback
	_default = {
		zeal_default = nil,
		web_url = "https://devdocs.io/#q=%s",
	},
}

---
-- Helper: URL encode
function M.urlencode(s)
	return (s:gsub("[^%w%-_%.~]", function(c)
		return string.format("%%%02X", string.byte(c))
	end))
end

---
-- Helper: cross-platform opener
function M.URLViewer(url)
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

---
-- Helper: De-duplicate a list of strings
function M.dedupe_list(list)
	local seen = {}
	local result = {}
	for _, item in ipairs(list) do
		if not seen[item] then
			table.insert(result, item)
			seen[item] = true
		end
	end
	return result
end

---
-- Helper: cross-platform opener
function M.URLViewer(url)
    -- ADD THIS LINE FOR TROUBLESHOOTING
    vim.notify("Opening URL: " .. url)
    
    if vim.ui and vim.ui.open then
        vim.ui.open(url)
        return
      end
end
---
-- *Fast* context detector
function M.detect_context()
	local ft = (vim.bo.filetype or ""):lower()
	local lines = vim.api.nvim_buf_get_lines(0, 0, LINES_TO_SCAN, false)
	local buf_head = table.concat(lines, "\n")
	local function has(pat)
		return buf_head:find(pat) ~= nil
	end
	return ft, has
end

---
-- Gets *all* matching docsets for the current buffer
function M.get_all_docsets()
	local ft, has = M.detect_context()
	local conf = M.get_ft_config(ft)
	local docsets = {}
	if conf.zeal_rules then
		for _, rule in ipairs(conf.zeal_rules) do
			local pattern, docset = rule[1], rule[2]
			if has(pattern) then
				table.insert(docsets, docset)
			end
		end
	elseif type(conf.zeal) == "string" then
		table.insert(docsets, conf.zeal)
	end
	if conf.zeal_default then
		table.insert(docsets, conf.zeal_default)
	end
	return M.dedupe_list(docsets)
end

---
-- Gets the final web search URL (for Official Docs)
function M.get_web_search_url(word)
	local ft, has = M.detect_context()
	local conf = M.get_ft_config(ft)
	local url_template
	if type(conf.web_url) == "function" then
		url_template = conf.web_url(has)
	else
		url_template = conf.web_url
	end
	url_template = url_template or M.config._default.web_url
	local query_template = conf.web_query or "%s"
	local query = string.format(query_template, word)
	return string.format(url_template, M.urlencode(query))
end

---
-- TELESCOPE PICKER "ENGINE"
---
function M.show_telescope_picker(service)
	-- Telescope components
	local pickers = require("telescope.pickers")
	local finders = require("telescope.finders")
	local actions = require("telescope.actions")
	local action_state = require("telescope.actions.state")

	local word = vim.fn.expand("<cword>")
	if not word or word == "" then
		vim.notify("No word under cursor", vim.log.levels.WARN)
		return
	end

	-- 1. Build the list of choices
	local choices = {}
	local docsets = M.get_all_docsets() -- e.g., ["fastapi", "pydantic", "python"]

	-- Add all smart-detected docsets
	for _, docset in ipairs(docsets) do
		table.insert(choices, {
			display = docset, -- The display is now simple, e.g., "fastapi"
			docset = docset,
			word = word,
		})
	end

	-- Add our default "always-on" options
	table.insert(choices, {
		display = "Official Docs",
		service = "url", -- Special service type
		url = M.get_web_search_url(word),
	})
	table.insert(choices, {
		display = "Web Search",
		service = "url", -- Special service type
		url = string.format(M.search_engine, M.urlencode(word)),
	})

	-- Add simple (no docset) search
	table.insert(choices, {
		display = "(simple search)",
		docset = nil, -- No docset
		word = word,
	})

	-- 2. Create the picker
	local title = (service == "zeal") and "Zeal" or "DevDocs"
	pickers
		.new({}, {
			prompt_title = title .. " Search for '" .. word .. "'",
			finder = finders.new_table({
				results = choices,
				entry_maker = function(entry)
					return { value = entry, display = entry.display, ordinal = entry.display }
				end,
			}),
			attach_mappings = function(prompt_bufnr, map)
				actions.select_default:replace(function()
					actions.close(prompt_bufnr)
					local entry = action_state.get_selected_entry().value

					-- Handle our special "url" services
					if entry.service == "url" then
						M.URLViewer(entry.url)
						return
					end

					-- All other entries are for Zeal/DevDocs
					if service == "zeal" then
						-- Zeal needs the colon format
						local query = entry.docset and (entry.docset .. ":" .. entry.word) or entry.word
						vim.fn.jobstart({ "zeal", query }, { detach = true })
					elseif service == "devdocs" then
						-- ===== THIS IS THE FIX YOU FOUND =====
						-- DevDocs needs the space format
						local query = entry.docset and (entry.docset .. " " .. entry.word) or entry.word
						local url = "https://devdocs.io/#q=" .. M.urlencode(query)
						M.URLViewer(url)
						-- ===== END OF FIX =====
					end
				end)
				return true
			end,
		})
		:find()
end

---
-- This function sets up all the keymaps
function M.setup()
	local keymap = vim.keymap

	-- Keymap 1: ZEAL (now <leader>zd)
	keymap.set("n", "<leader>zd", function()
		M.show_telescope_picker("zeal")
	end, { desc = "Docs: Zeal (Telescope)" })

	-- Keymap 2: DEVDOCS
	keymap.set("n", "<leader>zv", function()
		M.show_telescope_picker("devdocs")
	end, { desc = "Docs: DevDocs (Telescope)" })

	-- Keymap 3: PYDOC
	keymap.set("n", "<leader>zp", function()
		local word = vim.fn.expand("<cword>")
		if not word or word == "" then
			vim.notify("No word under cursor", vim.log.levels.WARN)
			return
		end
		vim.cmd("botright 12split | terminal python -m pydoc " .. word)
	end, { desc = "Docs: pydoc (terminal split)" })

	-- Keymap 4: EDITABLE SEARCH (now <leader>zs)
	keymap.set("n", "<leader>zs", function() -- 'zs' for "Search"
		local word = vim.fn.expand("<cword>")
		local query = vim.fn.input("Web Search: ", word)

		if query == nil or query == "" then
			vim.notify("Search cancelled", vim.log.levels.INFO)
			return
		end

		local url = string.format(M.search_engine, M.urlencode(query))
		M.URLViewer(url)
	end, { desc = "Docs: Web Search (editable)" })
end

-- Return the module table
return M
---
