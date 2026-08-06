--- vim-table-mode: type `|` and the table re-aligns itself. Solves the usual Markdown
--- table pain — hand-padding cells and re-padding every column after one edit.
---
--- LOAD ORDER (important): this is a Vimscript plugin. Its `plugin/table-mode.vim`
--- reads `g:table_mode_*` and creates its mappings the moment it is sourced, which
--- |vim.pack| does inside |config.pack|.setup() — *before* |config.plugins|.setup()
--- runs. So the mapping options live in `M.prelude()`, which |init.lua| calls ahead of
--- `config.pack`. Setting them in `M.setup()` silently does nothing: the maps are
--- already bound by then.
---
--- Two things must be configured or this plugin misbehaves in this config:
---
--- 1. Corner chars. The default `+` produces reStructuredText-style borders
---    (`+---+---+`), which is NOT valid GitHub/Obsidian Markdown. Setting corner and
---    corner-corner to `|` yields the `|---|---|` separator those renderers expect.
---
--- 2. Mapping prefix. Every sub-map is derived from `g:table_mode_map_prefix` at source
---    time, so setting the prefix moves all eleven at once — the one exception is
---    `tableize_d_map`, hardcoded to `<Leader>T` rather than derived.

local M = {}

--- Must run BEFORE vim.pack sources the plugin. Called from |init.lua|.
function M.prelude()
	-- GitHub-Flavored Markdown compatible borders.
	vim.g.table_mode_corner = "|"
	vim.g.table_mode_corner_corner = "|"
	vim.g.table_mode_fillchar = "-"
	vim.g.table_mode_header_fillchar = "-"
	vim.g.table_mode_align_char = ":"

	-- Upstream's own default prefix is <Leader>t, which is free again now that this config
	-- has no terminal plugin (shells are the window manager's job). Set explicitly rather
	-- than relied on, so a future <Leader>t squatter is an obvious conflict here.
	-- Toggle lands on <leader>tm; realign <leader>tr; delete row/col <leader>tdd/<leader>tdc;
	-- insert col <leader>tiC/<leader>tic; formulas <leader>tfa/<leader>tfe;
	-- sort <leader>ts; tableize <leader>tt; echo cell <leader>t?.
	vim.g.table_mode_map_prefix = "<leader>t"
	-- Sole map not derived from the prefix (visual-mode tableize-with-delimiter). Upstream
	-- puts it on <Leader>T; kept under the same prefix as everything else instead.
	vim.g.table_mode_tableize_d_map = "<leader>tT"

	-- Cell motions/text objects keep their `|` defaults: they are buffer-scoped and
	-- collide with nothing. [| ]| {| }| move between cells, `ci|` changes a cell.
end

function M.setup()
	-- Turn table mode on automatically where tables are actually written, so `|` starts
	-- aligning without a toggle first. Left off elsewhere — auto-aligning `|` in code
	-- buffers would be hostile (it is a pipe/or operator there).
	vim.api.nvim_create_autocmd("FileType", {
		pattern = { "markdown", "markdown.mdx", "text", "gitcommit" },
		group = vim.api.nvim_create_augroup("config.table_mode", { clear = true }),
		callback = function()
			-- silent: the plugin echoes "Table Mode Enabled" on every markdown buffer.
			vim.cmd("silent TableModeEnable")
		end,
	})
end

return M
