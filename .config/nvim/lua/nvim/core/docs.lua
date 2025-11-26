-- This is our "docs" module, now with two smart Telescope pickers
local M = {}

---
-- @const: Your preferred search engine.
-- M.search_engine = "https://www.google.com/search?q=%s"
M.search_engine = "https://duckduckgo.com/?q=%s"

---
-- @const: How many lines to scan for context.
local LINES_TO_SCAN = 200

---
-- Load configuration from external file
local config_array = require("nvim.core.docs-config")

---
-- Build configuration tables from array format
M.config = {}
M.docset_overrides = {}

for _, item in ipairs(config_array) do
	if item.type == "docset_override" then
		-- Handle docset overrides
		local override = {}
		if item.official_domain then
			override.official_domain = item.official_domain
		end
		if item.official_bang then
			override.official_bang = item.official_bang
		end
		M.docset_overrides[item.docset] = override
	elseif item.alias then
		-- Handle filetype aliases
		M.config[item.filetype] = item.alias
	else
		-- Handle regular filetype configs
		local config = {}
		if item.icon then
			config.icon = item.icon
		end
		if item.zeal then
			config.zeal = item.zeal
		end
		if item.zeal_default then
			config.zeal_default = item.zeal_default
		end
		if item.zeal_rules then
			-- Convert array format to old format for compatibility
			config.zeal_rules = {}
			for _, rule in ipairs(item.zeal_rules) do
				table.insert(config.zeal_rules, { rule.pattern, rule.docset })
			end
		end
		if item.official_domain then
			config.official_domain = item.official_domain
		end
		if item.official_bang then
			config.official_bang = item.official_bang
		end
		M.config[item.filetype] = config
	end
end

---
-- Helper: Find which filetype config contains this docset
function M.find_parent_filetype(docset)
	-- Search through all configs to find which one has this docset
	for ft, conf in pairs(M.config) do
		if type(conf) ~= "string" then -- Skip aliases
			-- Check zeal_rules
			if conf.zeal_rules then
				for _, rule in ipairs(conf.zeal_rules) do
					if rule[2] == docset then
						return ft
					end
				end
			end
			-- Check zeal_default
			if conf.zeal_default == docset then
				return ft
			end
			-- Check zeal
			if conf.zeal == docset then
				return ft
			end
		end
	end
	return nil
end

---
-- Helper: Get icon for a docset
function M.get_docset_icon(docset)
	-- First try to get the icon from the docset's own config
	local docset_conf = M.config[docset]
	if docset_conf and type(docset_conf) ~= "string" and docset_conf.icon then
		return docset_conf.icon
	end

	-- Otherwise, find the parent filetype and get its icon
	local filetype = M.find_parent_filetype(docset)
	if filetype then
		local ft_conf = M.get_ft_config(filetype)
		if ft_conf and ft_conf.icon then
			return ft_conf.icon
		end
	end

	-- Fall back to default icon
	return M.config._default.icon
end

---
-- Helper: URL encode
function M.urlencode(s)
	return (s:gsub("[^%w%-_%.~]", function(c)
		return string.format("%%%02X", string.byte(c))
	end))
end

---
-- Helper: cross-platform opener (single definition)
function M.URLViewer(url)
	-- Troubleshooting notification
	vim.notify("Opening URL: " .. url)

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
-- Helper: Get filetype config with alias support
function M.get_ft_config(ft)
	local conf = M.config[ft]
	if type(conf) == "string" then
		-- Handle aliases by resolving them recursively
		return M.get_ft_config(conf)
	elseif conf then
		return conf
	else
		-- Return default config if no match found
		return M.config._default
	end
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
-- Gets the official docs URL for a specific docset using DuckDuckGo bangs or site search
function M.get_official_url_for_docset(docset, word)
	local bang = nil
	local domain = nil

	-- Check for docset-specific overrides first
	local override = M.docset_overrides[docset]
	if override then
		bang = override.official_bang
		domain = override.official_domain
	end

	-- If no override, try to get from the docset's own config
	if not bang and not domain then
		local docset_conf = M.config[docset]
		if docset_conf and type(docset_conf) ~= "string" then
			bang = docset_conf.official_bang
			domain = docset_conf.official_domain
		end
	end

	-- If still nothing, fall back to parent filetype config
	if not bang and not domain then
		local filetype = M.find_parent_filetype(docset)
		if filetype then
			local ft_conf = M.get_ft_config(filetype)
			if ft_conf then
				bang = ft_conf.official_bang
				domain = ft_conf.official_domain
			end
		end
	end

	-- Build the search URL
	if bang then
		-- Use DuckDuckGo bang
		local query = bang .. " " .. word
		return "https://duckduckgo.com/?q=" .. M.urlencode(query)
	elseif domain then
		-- Use site-specific search via DuckDuckGo
		local query = word .. " site:" .. domain
		return "https://duckduckgo.com/?q=" .. M.urlencode(query)
	else
		-- Fall back to DevDocs
		return "https://devdocs.io/#q=" .. M.urlencode(docset .. " " .. word)
	end
end

---
-- Gets the final web search URL (for generic web search)
function M.get_Web_Search_url(word)
	local ft, has = M.detect_context()
	local conf = M.get_ft_config(ft)

	-- Check if there's a bang or domain for this filetype
	local bang = conf.official_bang
	local domain = conf.official_domain

	if bang then
		local query = bang .. " " .. word
		return "https://duckduckgo.com/?q=" .. M.urlencode(query)
	elseif domain then
		local query = word .. " site:" .. domain
		return "https://duckduckgo.com/?q=" .. M.urlencode(query)
	else
		-- Fall back to DevDocs
		return "https://devdocs.io/#q=" .. M.urlencode(word)
	end
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
	local conf = require("telescope.config").values

	local word = vim.fn.expand("<cword>")
	if not word or word == "" then
		vim.notify("No word under cursor", vim.log.levels.WARN)
		return
	end

	-- 1. Build the list of choices
	local choices = {}
	local docsets = M.get_all_docsets() -- e.g., ["fastapi", "pydantic", "python"]

	-- Add all smart-detected docsets for direct search
	for _, docset in ipairs(docsets) do
		local icon = M.get_docset_icon(docset)
		table.insert(choices, {
			display = icon .. " " .. docset,
			ordinal = docset, -- Clean ordinal for fuzzy search
			docset = docset,
			word = word,
		})
	end

	-- Add Official Docs entries per detected docset
	for _, docset in ipairs(docsets) do
		local icon = M.get_docset_icon(docset)
		table.insert(choices, {
			display = icon .. "  Official Docs - " .. docset,
			ordinal = "official docs " .. docset, -- Clean ordinal for fuzzy search
			service = "official_url",
			docset = docset,
			word = word,
		})
	end

	-- If there were no docsets detected, still offer the generic Official Docs
	if #docsets == 0 then
		local ft_conf = M.get_ft_config(vim.bo.filetype)
		local icon = ft_conf.icon or M.config._default.icon
		table.insert(choices, {
			display = icon .. "  Official Docs",
			ordinal = "official docs",
			service = "url",
			url = M.get_Web_Search_url(word),
		})
	end

	-- Keep the global Web Search entry
	table.insert(choices, {
		display = "󰖟 Web Search",
		ordinal = "web search",
		service = "url",
		url = string.format(M.search_engine, M.urlencode(word)),
	})

	-- Add "all docsets" search (no filter)
	table.insert(choices, {
		display = "󰷈 Search All Docsets",
		ordinal = "search all docsets",
		docset = nil, -- No docset filter
		word = word,
	})

	-- 2. Create the picker (uses theme colors from colorscheme.lua)
	local title = (service == "zeal") and "Zeal" or "DevDocs"
	pickers
		.new({}, {
			prompt_title = title .. " Search for '" .. word .. "'",
			finder = finders.new_table({
				results = choices,
				entry_maker = function(entry)
					return {
						value = entry,
						display = entry.display,
						ordinal = entry.ordinal, -- Use the clean ordinal for searching
					}
				end,
			}),
			sorter = conf.generic_sorter({}), -- Enable fuzzy sorting
			-- Use theme colors (highlight groups are already set in colorscheme.lua)
			results_title = "",
			prompt_prefix = "  ",
			selection_caret = "  ",
			entry_prefix = "  ",
			attach_mappings = function(prompt_bufnr, map)
				actions.select_default:replace(function()
					actions.close(prompt_bufnr)
					local entry = action_state.get_selected_entry().value

					-- Handle official docs URL (uses DuckDuckGo bangs or site search)
					if entry.service == "official_url" then
						local url = M.get_official_url_for_docset(entry.docset, entry.word)
						M.URLViewer(url)
						return
					end

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
						-- DevDocs needs the space format
						local query = entry.docset and (entry.docset .. " " .. entry.word) or entry.word
						local url = "https://devdocs.io/#q=" .. M.urlencode(query)
						M.URLViewer(url)
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
