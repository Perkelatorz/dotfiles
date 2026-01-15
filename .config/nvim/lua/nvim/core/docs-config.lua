-- Documentation configuration as an array of filetype config objects
-- This structure makes it easy to add, modify, or remove configurations

return {
	-- Filetype configurations
	{
		filetype = "python",
		icon = "",
		zeal_rules = {
			{ pattern = "fastapi", docset = "fastapi" },
			{ pattern = "pydantic", docset = "pydantic" },
			{ pattern = "starlette", docset = "starlette" },
			{ pattern = "numpy", docset = "numpy" },
			{ pattern = "np%s*=", docset = "numpy" },
			{ pattern = "pandas", docset = "pandas" },
			{ pattern = "pd%s*=", docset = "pandas" },
			{ pattern = "django", docset = "django" },
			{ pattern = "sqlalchemy", docset = "sqlalchemy" },
			{ pattern = "requests", docset = "requests" },
			{ pattern = "pytest", docset = "pytest" },
		},
		zeal_default = "python",
		official_domain = "docs.python.org",
	},
	{
		filetype = "javascript",
		icon = "",
		zeal_rules = {
			{ pattern = "from%s+['\"]react", docset = "react" },
			{ pattern = "require%(['\"]react", docset = "react" },
			{ pattern = "from%s+['\"]vue", docset = "vue" },
			{ pattern = "require%(['\"]vue", docset = "vue" },
			{ pattern = "from%s+['\"]svelte", docset = "svelte" },
			{ pattern = "require%(['\"]svelte", docset = "svelte" },
			{ pattern = "from%s+['\"]node:", docset = "nodejs" },
			{ pattern = "require%(['\"]node:", docset = "nodejs" },
		},
		zeal_default = "javascript",
		official_bang = "!mdn",
	},
	{
		filetype = "typescript",
		icon = "",
		zeal_default = "typescript",
		official_domain = "typescriptlang.org",
	},
	{
		filetype = "cs",
		icon = "",
		zeal_rules = {
			{ pattern = "using%s+Microsoft%.AspNetCore", docset = "aspnetcore" },
			{ pattern = "using%s+Microsoft%.EntityFrameworkCore", docset = "entityframeworkcore" },
		},
		zeal_default = "csharp",
		official_domain = "learn.microsoft.com",
	},
	{
		filetype = "powershell",
		icon = "󰨊",
		zeal = "powershell",
		official_domain = "learn.microsoft.com",
	},
	{
		filetype = "lua",
		icon = "",
		zeal_rules = {
			{ pattern = "vim%.", docset = "neovim" },
			{ pattern = "require%(['\"]vim", docset = "neovim" },
		},
		zeal_default = "lua",
		official_domain = "lua.org",
	},
	{
		filetype = "bash",
		icon = "",
		zeal = "bash",
		official_domain = "man7.org",
	},
	{
		filetype = "go",
		icon = "󰟓",
		zeal_default = "go",
		official_bang = "!golang",
	},
	{
		filetype = "rust",
		icon = "",
		zeal_default = "rust",
		official_domain = "doc.rust-lang.org",
	},
	{
		filetype = "ruby",
		icon = "",
		zeal_default = "ruby",
		official_domain = "ruby-doc.org",
	},
	{
		filetype = "php",
		icon = "",
		zeal_default = "php",
		official_bang = "!php",
	},
	{
		filetype = "java",
		icon = "",
		zeal_default = "java",
		official_domain = "docs.oracle.com",
	},
	{
		filetype = "cpp",
		icon = "",
		zeal_default = "cpp",
		official_domain = "cppreference.com",
	},
	{
		filetype = "c",
		icon = "",
		zeal_default = "c",
		official_domain = "cppreference.com",
	},
	{
		filetype = "html",
		icon = "",
		zeal_default = "html",
		official_bang = "!mdn",
	},
	{
		filetype = "css",
		icon = "",
		zeal_default = "css",
		official_bang = "!mdn",
	},
	{
		filetype = "svelte",
		icon = "",
		zeal_default = "svelte",
		official_domain = "svelte.dev",
		official_bang = "!svelte",
	},
	{
		filetype = "dockerfile",
		icon = "",
		zeal_default = "docker",
		official_bang = "!docker",
	},
	{
		filetype = "sql",
		icon = "",
		zeal_default = "postgresql",
		official_domain = "postgresql.org",
	},
	{
		filetype = "json",
		icon = "",
		zeal_default = "json",
	},
	{
		filetype = "yaml",
		icon = "",
		zeal_default = "yaml",
	},
	{
		filetype = "markdown",
		icon = "",
		zeal_default = "markdown",
	},
	{
		filetype = "xml",
		icon = "󰗀",
		zeal_default = "xml",
	},
	{
		filetype = "git",
		icon = "󰊢",
		zeal_default = "git",
		official_domain = "git-scm.com",
	},
	{
		filetype = "vim",
		icon = "",
		zeal_default = "vim",
		official_bang = "!vim",
	},
	-- Filetype aliases
	{
		filetype = "sh",
		alias = "bash",
	},
	{
		filetype = "zsh",
		alias = "bash",
	},
	{
		filetype = "javascriptreact",
		alias = "javascript",
	},
	{
		filetype = "typescriptreact",
		alias = "javascript",
	},
	{
		filetype = "scss",
		alias = "css",
	},
	{
		filetype = "less",
		alias = "css",
	},
	{
		filetype = "yml",
		alias = "yaml",
	},
	-- Default fallback
	{
		filetype = "_default",
		icon = "󰖟",
		zeal_default = nil,
	},
	-- Docset-specific overrides for official docs
	{
		type = "docset_override",
		docset = "fastapi",
		official_domain = "fastapi.tiangolo.com",
	},
	{
		type = "docset_override",
		docset = "pydantic",
		official_domain = "docs.pydantic.dev",
	},
	{
		type = "docset_override",
		docset = "django",
		official_bang = "!django",
	},
	{
		type = "docset_override",
		docset = "flask",
		official_domain = "flask.palletsprojects.com",
	},
	{
		type = "docset_override",
		docset = "numpy",
		official_domain = "numpy.org",
	},
	{
		type = "docset_override",
		docset = "pandas",
		official_domain = "pandas.pydata.org",
	},
	{
		type = "docset_override",
		docset = "pytest",
		official_domain = "docs.pytest.org",
	},
	{
		type = "docset_override",
		docset = "react",
		official_bang = "!react",
	},
	{
		type = "docset_override",
		docset = "vue",
		official_bang = "!vue",
	},
	{
		type = "docset_override",
		docset = "nodejs",
		official_bang = "!nodejs",
	},
	{
		type = "docset_override",
		docset = "svelte",
		official_domain = "svelte.dev",
		official_bang = "!svelte",
	},
	{
		type = "docset_override",
		docset = "neovim",
		official_domain = "neovim.io",
	},
}
