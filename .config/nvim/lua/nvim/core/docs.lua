local M = {}

M.search_engine = "https://duckduckgo.com/?q=%s"

local LINES_TO_SCAN = 200

local config_array = require("nvim.core.docs-config")

M.config = {}
M.docset_overrides = {}

for _, item in ipairs(config_array) do
	if item.type == "docset_override" then
		local override = {}
		if item.official_domain then
			override.official_domain = item.official_domain
		end
		if item.official_bang then
			override.official_bang = item.official_bang
		end
		M.docset_overrides[item.docset] = override
	elseif item.alias then
		M.config[item.filetype] = item.alias
	else
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

function M.find_parent_filetype(docset)
	for ft, conf in pairs(M.config) do
		if type(conf) ~= "string" then -- Skip aliases
			if conf.zeal_rules then
				for _, rule in ipairs(conf.zeal_rules) do
					if rule[2] == docset then
						return ft
					end
				end
			end
			if conf.zeal_default == docset then
				return ft
			end
			if conf.zeal == docset then
				return ft
			end
		end
	end
	return nil
end

function M.get_docset_icon(docset)
	local docset_conf = M.config[docset]
	if docset_conf and type(docset_conf) ~= "string" and docset_conf.icon then
		return docset_conf.icon
	end

	local filetype = M.find_parent_filetype(docset)
	if filetype then
		local ft_conf = M.get_ft_config(filetype)
		if ft_conf and ft_conf.icon then
			return ft_conf.icon
		end
	end

	return M.config._default.icon
end

function M.urlencode(s)
	return (s:gsub("[^%w%-_%.~]", function(c)
		return string.format("%%%02X", string.byte(c))
	end))
end

function M.open_url(url)
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

function M.detect_context()
	local ft = (vim.bo.filetype or ""):lower()
	local lines = vim.api.nvim_buf_get_lines(0, 0, LINES_TO_SCAN, false)
	local buf_head = table.concat(lines, "\n")
	local function has(pat)
		return buf_head:find(pat) ~= nil
	end
	return ft, has
end

function M.get_ft_config(ft)
	local conf = M.config[ft]
	if type(conf) == "string" then
		return M.get_ft_config(conf)
	elseif conf then
		return conf
	else
		return M.config._default
	end
end

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

function M.get_official_url_for_docset(docset, word)
	local bang = nil
	local domain = nil

	local override = M.docset_overrides[docset]
	if override then
		bang = override.official_bang
		domain = override.official_domain
	end

	if not bang and not domain then
		local docset_conf = M.config[docset]
		if docset_conf and type(docset_conf) ~= "string" then
			bang = docset_conf.official_bang
			domain = docset_conf.official_domain
		end
	end

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

	if bang then
		local query = bang .. " " .. word
		return "https://duckduckgo.com/?q=" .. M.urlencode(query)
	elseif domain then
		local query = word .. " site:" .. domain
		return "https://duckduckgo.com/?q=" .. M.urlencode(query)
	else
		return "https://devdocs.io/#q=" .. M.urlencode(docset .. " " .. word)
	end
end

function M.get_web_search_url(word)
	local ft = M.detect_context()
	local conf = M.get_ft_config(ft)

	local bang = conf.official_bang
	local domain = conf.official_domain

	if bang then
		local query = bang .. " " .. word
		return "https://duckduckgo.com/?q=" .. M.urlencode(query)
	elseif domain then
		local query = word .. " site:" .. domain
		return "https://duckduckgo.com/?q=" .. M.urlencode(query)
	else
		return "https://devdocs.io/#q=" .. M.urlencode(word)
	end
end

function M.show_telescope_picker(service)
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

	local choices = {}
	local docsets = M.get_all_docsets() -- e.g., ["fastapi", "pydantic", "python"]

	for _, docset in ipairs(docsets) do
		local icon = M.get_docset_icon(docset)
		table.insert(choices, {
			display = icon .. " " .. docset,
			ordinal = docset, -- Clean ordinal for fuzzy search
			docset = docset,
			word = word,
		})
	end

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

	if #docsets == 0 then
		local ft_conf = M.get_ft_config(vim.bo.filetype)
		local icon = ft_conf.icon or M.config._default.icon
		table.insert(choices, {
			display = icon .. "  Official Docs",
			ordinal = "official docs",
			service = "url",
			url = M.get_web_search_url(word),
		})
	end

	table.insert(choices, {
		display = "󰖟 Web Search",
		ordinal = "web search",
		service = "url",
		url = string.format(M.search_engine, M.urlencode(word)),
	})

	table.insert(choices, {
		display = "󰷈 Search All Docsets",
		ordinal = "search all docsets",
		docset = nil, -- No docset filter
		word = word,
	})

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
			results_title = "",
			prompt_prefix = "  ",
			selection_caret = "  ",
			entry_prefix = "  ",
			attach_mappings = function(prompt_bufnr, map)
				actions.select_default:replace(function()
					actions.close(prompt_bufnr)
					local entry = action_state.get_selected_entry().value

					if entry.service == "official_url" then
						local url = M.get_official_url_for_docset(entry.docset, entry.word)
						M.open_url(url)
						return
					end

					if entry.service == "url" then
						M.open_url(entry.url)
						return
					end

					if service == "zeal" then
						local query = entry.docset and (entry.docset .. ":" .. entry.word) or entry.word
						vim.fn.jobstart({ "zeal", query }, { detach = true })
					elseif service == "devdocs" then
						local query = entry.docset and (entry.docset .. " " .. entry.word) or entry.word
						local url = "https://devdocs.io/#q=" .. M.urlencode(query)
						M.open_url(url)
					end
				end)
				return true
			end,
		})
		:find()
end

function M.setup()
	local keymap = vim.keymap

	keymap.set("n", "<leader>Dz", function()
		M.show_telescope_picker("zeal")
	end, { desc = "Zeal lookup" })

	keymap.set("n", "<leader>Dd", function()
		M.show_telescope_picker("devdocs")
	end, { desc = "DevDocs lookup" })

	keymap.set("n", "<leader>Dp", function()
		local word = vim.fn.expand("<cword>")
		if not word or word == "" then
			vim.notify("No word under cursor", vim.log.levels.WARN)
			return
		end
		vim.cmd("botright 12split | terminal python -m pydoc " .. word)
	end, { desc = "Pydoc (terminal)" })

	keymap.set("n", "<leader>Ds", function()
		local word = vim.fn.expand("<cword>")
		local query = vim.fn.input("Web Search: ", word)
		if query == nil or query == "" then
			return
		end
		local url = string.format(M.search_engine, M.urlencode(query))
		M.open_url(url)
	end, { desc = "Web search" })
end

return M
