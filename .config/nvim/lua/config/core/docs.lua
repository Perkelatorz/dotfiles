--- Quick doc lookup: [devdocs.io](https://devdocs.io/) in the browser and [Zeal](https://zealdocs.org/) offline (Dash docsets).
---
--- Scoped `<leader>cd` / `<leader>cz` follow **language** `filetype`. For a framework, use `:Zeal docset:query`,
--- `<leader>cD` / `<leader>cZ` (all docsets), or set `vim.b.docs_devdocs_slug` / `vim.b.docs_zeal_docset`.
--- `:Docs` / `<leader>c.` opens a small menu. Project-wide presets can return later if you miss them.

local M = {}

local FT_DEVDOCS = {
	bash = "bash",
	c = "c",
	clojure = "clojure",
	cpp = "cpp",
	crystal = "crystal",
	cs = "csharp",
	css = "css",
	dart = "dart",
	dockerfile = "docker",
	elixir = "elixir",
	eelixir = "elixir",
	erlang = "erlang",
	fsharp = "fsharp",
	go = "go",
	graphql = "graphql",
	haskell = "haskell",
	html = "html",
	htmldjango = "django",
	django = "django",
	java = "java",
	javascript = "javascript",
	javascriptreact = "react",
	julia = "julia",
	kotlin = "kotlin",
	lua = "lua",
	nim = "nim",
	nix = "nix",
	ocaml = "ocaml",
	perl = "perl",
	php = "php",
	python = "python",
	r = "r",
	racket = "racket",
	ruby = "ruby",
	rust = "rust",
	scala = "scala",
	scheme = "scheme",
	sh = "bash",
	svelte = "svelte",
	sql = "postgresql",
	swift = "swift",
	typescript = "typescript",
	typescriptreact = "typescript",
	toml = "toml",
	vue = "vue",
	yaml = "yaml",
	["yaml.ansible"] = "ansible",
	["yaml.docker-compose"] = "docker",
	zig = "zig",
	zsh = "bash",
}

local FT_ZEAL_DEFAULT = {
	bash = "bash",
	c = "c",
	clojure = "clojure",
	cpp = "cpp",
	crystal = "crystal",
	cs = "csharp",
	css = "css",
	dart = "dart",
	dockerfile = "docker",
	elixir = "elixir",
	eelixir = "elixir",
	erlang = "erlang",
	fsharp = "fsharp",
	go = "go",
	graphql = "graphql",
	haskell = "haskell",
	html = "html",
	htmldjango = "django",
	django = "django",
	java = "java",
	javascript = "javascript",
	javascriptreact = "react",
	julia = "julia",
	kotlin = "kotlin",
	lua = "lua",
	nim = "nim",
	nix = "nix",
	ocaml = "ocaml",
	perl = "perl",
	php = "php",
	python = "python",
	r = "r",
	racket = "racket",
	ruby = "ruby",
	rust = "rust",
	scala = "scala",
	scheme = "scheme",
	sh = "bash",
	svelte = "svelte",
	sql = "postgresql",
	swift = "swift",
	typescript = "typescript",
	typescriptreact = "typescript",
	toml = "toml",
	vue = "vue",
	yaml = "yaml",
	["yaml.ansible"] = "ansible",
	["yaml.docker-compose"] = "docker",
	zig = "zig",
	zsh = "bash",
}

local zeal_docsets = vim.deepcopy(FT_ZEAL_DEFAULT)

local function devdocs_slug_for_buffer()
	local b = vim.b.docs_devdocs_slug
	if type(b) == "string" and vim.trim(b) ~= "" then
		return vim.trim(b)
	end
	return FT_DEVDOCS[vim.bo.filetype] or ""
end

local function zeal_docset_for_ft(ft)
	local g = vim.g.docs_zeal_docset
	if type(g) == "string" and g ~= "" then
		return g
	end
	local gmap = vim.g.docs_zeal_docsets
	if type(gmap) == "table" then
		local o = gmap[ft]
		if type(o) == "string" and o ~= "" then
			return o
		end
	end
	return zeal_docsets[ft] or ""
end

local function zeal_docset_for_buffer()
	local b = vim.b.docs_zeal_docset
	if type(b) == "string" and vim.trim(b) ~= "" then
		return vim.trim(b)
	end
	return zeal_docset_for_ft(vim.bo.filetype)
end

---@return string[]|nil argv, string|nil err
local function zeal_argv(arg)
	if type(vim.g.docs_zeal_cmd) == "string" and vim.trim(vim.g.docs_zeal_cmd) ~= "" then
		local a = vim.split(vim.trim(vim.g.docs_zeal_cmd), "%s+", { trimempty = true })
		if vim.fn.executable(a[1]) ~= 1 then
			return nil, "g:docs_zeal_cmd not executable: " .. a[1]
		end
		table.insert(a, arg)
		return a, nil
	end
	if vim.fn.executable("zeal") ~= 1 then
		return nil, "zeal not in PATH (install zeal or set g:docs_zeal_cmd)"
	end
	return { "zeal", arg }, nil
end

local function visual_text()
	local mode = vim.fn.visualmode()
	if mode == nil or mode == "" then
		mode = "v"
	end
	local t = vim.fn.getregion(vim.fn.getpos("'<"), vim.fn.getpos("'>"), { type = mode })
	if not t or #t == 0 then
		return ""
	end
	return vim.trim((table.concat(t, "\n")):gsub("%s+", " "))
end

---@param opts { all?: boolean, query?: string, visual?: boolean }
local function resolve_query(opts)
	local q = vim.trim(opts.query or "")
	if q ~= "" then
		return q
	end
	if opts.visual then
		q = visual_text()
		if q ~= "" then
			return q
		end
	end
	q = vim.trim(vim.fn.expand("<cword>"))
	if q ~= "" then
		return q
	end
	return nil
end

---@param opts { visual?: boolean }
function M.open_palette(opts)
	opts = opts or {}
	vim.ui.select({
		"DevDocs (scoped to filetype)",
		"DevDocs (all docsets)",
		"Zeal (scoped docset)",
		"Zeal (all docsets)",
	}, { prompt = "Docs" }, function(_, idx)
		if idx == nil then
			return
		end
		if idx == 1 then
			M.open_devdocs(vim.tbl_extend("force", opts, { all = false }))
		elseif idx == 2 then
			M.open_devdocs(vim.tbl_extend("force", opts, { all = true }))
		elseif idx == 3 then
			M.open_zeal(vim.tbl_extend("force", opts, { all = false }))
		elseif idx == 4 then
			M.open_zeal(vim.tbl_extend("force", opts, { all = true }))
		end
	end)
end

function M.open_devdocs(opts)
	opts = opts or {}
	local query = resolve_query(opts)
	if not query then
		vim.ui.input({ prompt = "DevDocs search: " }, function(input)
			if input and vim.trim(input) ~= "" then
				M.open_devdocs(vim.tbl_extend("force", opts, { query = vim.trim(input), visual = false }))
			end
		end)
		return
	end

	local slug = devdocs_slug_for_buffer()
	local q
	if opts.all or slug == "" then
		q = query
	else
		q = slug .. " " .. query
	end
	local enc = vim.uri_encode(q, "rfc3986")
	local url = "https://devdocs.io/#q=" .. enc
	local _, err = vim.ui.open(url)
	if err then
		vim.notify("Could not open browser: " .. tostring(err), vim.log.levels.WARN)
	end
end

---@param opts { all?: boolean, query?: string, visual?: boolean, raw?: string }
function M.open_zeal(opts)
	opts = opts or {}

	local arg
	if opts.raw and opts.raw ~= "" then
		arg = vim.trim(opts.raw)
	else
		local query = resolve_query(opts)
		if not query then
			vim.ui.input({ prompt = "Zeal search (or docset:query): " }, function(input)
				if input and vim.trim(input) ~= "" then
					local raw = vim.trim(input)
					if raw:find(":", 1, true) then
						M.open_zeal({ raw = raw })
					else
						M.open_zeal(vim.tbl_extend("force", opts, { query = raw, visual = false }))
					end
				end
			end)
			return
		end

		if opts.all then
			arg = query
		else
			local doc = zeal_docset_for_buffer()
			if doc == "" then
				arg = query
			else
				arg = doc .. ":" .. query
			end
		end
	end

	local argv, err = zeal_argv(arg)
	if not argv then
		vim.notify(err or "Zeal launch failed", vim.log.levels.WARN)
		return
	end
	vim.system(argv, { detach = true })
end

---@param opts? { zeal_docsets?: table<string, string> }
function M.setup(opts)
	opts = opts or {}
	if type(opts.zeal_docsets) == "table" then
		for k, v in pairs(opts.zeal_docsets) do
			if type(k) == "string" and type(v) == "string" then
				zeal_docsets[k] = v
			end
		end
	end

	vim.api.nvim_create_user_command("DevDocs", function(o)
		M.open_devdocs({ all = false, query = o.args })
	end, {
		nargs = "*",
		desc = "Search devdocs.io (filetype-scoped when known)",
	})
	vim.api.nvim_create_user_command("DevDocsAll", function(o)
		M.open_devdocs({ all = true, query = o.args })
	end, {
		nargs = "*",
		desc = "Search devdocs.io (all docsets)",
	})

	vim.api.nvim_create_user_command("Zeal", function(o)
		local a = vim.trim(o.args or "")
		if a:find(":", 1, true) then
			M.open_zeal({ raw = a })
		else
			M.open_zeal({ all = false, query = a })
		end
	end, {
		nargs = "*",
		desc = "Zeal: args with ':' = raw docset:query; else scoped by filetype",
	})
	vim.api.nvim_create_user_command("ZealAll", function(o)
		M.open_zeal({ all = true, query = o.args })
	end, {
		nargs = "*",
		desc = "Zeal: search all installed docsets",
	})

	vim.api.nvim_create_user_command("Docs", function()
		M.open_palette({})
	end, { desc = "Docs menu: DevDocs vs Zeal (scoped vs all)" })

	vim.keymap.set("n", "<leader>c.", function()
		M.open_palette({})
	end, { desc = "Docs menu (DevDocs / Zeal)" })
	vim.keymap.set("x", "<leader>c.", function()
		M.open_palette({ visual = true })
	end, { desc = "Docs menu (visual selection)" })

	vim.keymap.set("n", "<leader>cd", function()
		M.open_devdocs({ all = false })
	end, { desc = "DevDocs (scoped to filetype)" })
	vim.keymap.set("n", "<leader>cD", function()
		M.open_devdocs({ all = true })
	end, { desc = "DevDocs (all docsets)" })
	vim.keymap.set("x", "<leader>cd", function()
		M.open_devdocs({ all = false, visual = true })
	end, { desc = "DevDocs (visual selection)" })
	vim.keymap.set("x", "<leader>cD", function()
		M.open_devdocs({ all = true, visual = true })
	end, { desc = "DevDocs all (visual selection)" })

	vim.keymap.set("n", "<leader>cz", function()
		M.open_zeal({ all = false })
	end, { desc = "Zeal (scoped docset + word)" })
	vim.keymap.set("n", "<leader>cZ", function()
		M.open_zeal({ all = true })
	end, { desc = "Zeal (all docsets)" })
	vim.keymap.set("x", "<leader>cz", function()
		M.open_zeal({ all = false, visual = true })
	end, { desc = "Zeal (visual → docset:selection)" })
	vim.keymap.set("x", "<leader>cZ", function()
		M.open_zeal({ all = true, visual = true })
	end, { desc = "Zeal all (visual selection)" })
end

return M
