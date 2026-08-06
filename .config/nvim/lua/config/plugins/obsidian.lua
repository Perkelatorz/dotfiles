--- obsidian.nvim: Obsidian-vault workflow (wiki links, backlinks, dailies, tags, templates).
--- Vault lives at ~/notes and is a plain folder of Markdown files, so the Obsidian
--- desktop app can open the same directory with no conversion step.
---
--- Two deliberate hand-offs to plugins already in this config:
---   * Rendering  → |config.plugins.render_markdown| (obsidian's own `ui` is disabled below;
---                  running both fights over the same conceal/extmark ranges).
---   * Completion → obsidian.nvim ships an in-process LSP that attaches to notes inside the
---                  workspace, so the existing `nvim_lsp` cmp source picks up `[[`, `#tag`
---                  and frontmatter completion with no extra cmp source to register.
---
--- Requires `ripgrep` (present) for search/backlinks, and `wl-clipboard` or `xclip`
--- for `:Obsidian paste_img`.

local M = {}

local vault = vim.fn.expand("~/notes")

function M.setup()
	require("obsidian").setup({
		workspaces = {
			{ name = "notes", path = vault },
		},

		-- Only take over commands under the `:Obsidian <sub>` namespace. The old
		-- `:ObsidianNew`-style commands are deprecated upstream and removed in 4.0.
		legacy_commands = false,

		picker = { name = "telescope.nvim" },

		-- Obsidian's default `[[wiki]]` links, so notes stay portable to the desktop app.
		link = { style = "wiki", format = "shortest", auto_update = true },

		-- Human-readable filenames ("my-note.md") instead of the default random
		-- Zettel IDs ("1717umnq-my-note.md"), which are painful to browse outside nvim.
		note_id_func = require("obsidian.builtin").title_id,
		new_notes_location = "notes_subdir",
		notes_subdir = "notes",

		daily_notes = {
			folder = "daily",
			date_format = "%Y-%m-%d",
			template = "daily.md",
			default_tags = { "daily" },
			-- false so weekend entries get their own note rather than folding into Friday.
			workdays_only = false,
		},

		templates = {
			folder = "templates",
			date_format = "%Y-%m-%d",
			time_format = "%H:%M",
		},

		attachments = { folder = "attachments" },

		-- Disabled: render-markdown.nvim owns in-buffer presentation for this config.
		ui = { enable = false },

		-- Virtual-text line under a note with backlink/word counts.
		footer = { enabled = true },

		completion = { min_chars = 2, create_new = true },
	})

	local map = function(lhs, rhs, desc)
		vim.keymap.set("n", lhs, rhs, { desc = desc })
	end

	-- Vault-wide (work from any buffer).
	map("<leader>oo", "<cmd>Obsidian quick_switch<cr>", "Obsidian: quick switch note")
	map("<leader>of", "<cmd>Obsidian search<cr>", "Obsidian: grep vault")
	map("<leader>on", "<cmd>Obsidian new<cr>", "Obsidian: new note")
	map("<leader>oN", "<cmd>Obsidian new_from_template<cr>", "Obsidian: new note from template")
	map("<leader>ot", "<cmd>Obsidian tags<cr>", "Obsidian: browse tags")
	map("<leader>ow", "<cmd>Obsidian workspace<cr>", "Obsidian: switch workspace")

	-- Daily notes.
	map("<leader>od", "<cmd>Obsidian today<cr>", "Obsidian: today's daily note")
	map("<leader>oy", "<cmd>Obsidian yesterday<cr>", "Obsidian: yesterday's daily note")
	map("<leader>om", "<cmd>Obsidian tomorrow<cr>", "Obsidian: tomorrow's daily note")
	map("<leader>oD", "<cmd>Obsidian dailies<cr>", "Obsidian: browse dailies")

	-- Inside a note.
	map("<leader>ob", "<cmd>Obsidian backlinks<cr>", "Obsidian: backlinks to this note")
	map("<leader>ol", "<cmd>Obsidian links<cr>", "Obsidian: links in this note")
	map("<leader>oc", "<cmd>Obsidian toc<cr>", "Obsidian: table of contents")
	map("<leader>or", "<cmd>Obsidian rename<cr>", "Obsidian: rename note (updates links)")
	map("<leader>op", "<cmd>Obsidian paste_img<cr>", "Obsidian: paste image from clipboard")
	map("<leader>oT", "<cmd>Obsidian template<cr>", "Obsidian: insert template here")

	-- Visual-mode note extraction / linking.
	vim.keymap.set("x", "<leader>oe", "<cmd>Obsidian extract_note<cr>", { desc = "Obsidian: extract selection to new note" })
	vim.keymap.set("x", "<leader>ok", "<cmd>Obsidian link<cr>", { desc = "Obsidian: link selection to existing note" })
	vim.keymap.set("x", "<leader>oK", "<cmd>Obsidian link_new<cr>", { desc = "Obsidian: link selection to new note" })

	-- Buffer-local note keys: only bound inside the vault so they don't shadow
	-- anything in code buffers. `gf`-style follow + checkbox toggle are the two
	-- actions frequent enough to deserve unprefixed keys.
	vim.api.nvim_create_autocmd("User", {
		pattern = "ObsidianNoteEnter",
		group = vim.api.nvim_create_augroup("config.obsidian.note_keys", { clear = true }),
		callback = function(ev)
			local opts = { buffer = ev.buf }
			vim.keymap.set("n", "<CR>", "<cmd>Obsidian follow_link<cr>", vim.tbl_extend("force", opts, {
				desc = "Obsidian: follow link under cursor",
			}))
			vim.keymap.set("n", "<C-Space>", "<cmd>Obsidian toggle_checkbox<cr>", vim.tbl_extend("force", opts, {
				desc = "Obsidian: cycle checkbox state",
			}))
			-- Notes are prose: soft-wrap on word boundaries and move by screen line.
			vim.opt_local.wrap = true
			vim.opt_local.linebreak = true
			vim.opt_local.conceallevel = 2
			vim.keymap.set("n", "j", "gj", opts)
			vim.keymap.set("n", "k", "gk", opts)
		end,
	})
end

return M
