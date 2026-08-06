--- live-preview.nvim: browser preview for Markdown with live updates as you type.
--- Pure Lua (no NodeJS/Python runtime and no build step, unlike markdown-preview.nvim),
--- and it renders mermaid diagrams + KaTeX math, which |render-markdown| cannot show
--- in-buffer.
---
--- This module owns the two *out-of-buffer* previews. Three weights in total:
---   <leader>mt  render-markdown  — in-buffer conceal rendering (|config.plugins.render_markdown|)
---   <leader>mp  glow            — read-only pager in a plain |:terminal| split (below)
---   <leader>mb  live-preview    — real browser, live-updating, mermaid/KaTeX/images
---
--- `dynamic_root` is left off so the server root stays |current-directory|: with cwd at
--- the vault root, `attachments/…` image paths in a note resolve correctly.

local M = {}

function M.setup()
	require("livepreview.config").set({
		port = 5500,
		browser = "default",
		dynamic_root = false,
		sync_scroll = true,
		picker = "telescope",
		address = "127.0.0.1",
	})

	vim.keymap.set("n", "<leader>mb", "<cmd>LivePreview start<cr>", { desc = "Live preview: open in browser" })
	vim.keymap.set("n", "<leader>mB", "<cmd>LivePreview close<cr>", { desc = "Live preview: stop server" })
	vim.keymap.set("n", "<leader>mf", "<cmd>LivePreview pick<cr>", { desc = "Live preview: pick a file" })

	-- Glow (installed by Mason, see |config.plugins.mason|): read-only pager for a saved
	-- Markdown file. Uses a plain |:terminal| split — this config has no terminal plugin;
	-- interactive shells are the window manager's job.
	vim.keymap.set("n", "<leader>mp", function()
		local path = vim.api.nvim_buf_get_name(0)
		if path == "" then
			vim.notify("Save the buffer first — Glow needs a file path.", vim.log.levels.WARN)
			return
		end
		if vim.bo.filetype ~= "markdown" and not path:lower():match("%.md$") and not path:lower():match("%.markdown$") then
			vim.notify("Glow preview is meant for Markdown buffers.", vim.log.levels.WARN)
			return
		end
		vim.cmd("belowright 18split | terminal glow " .. vim.fn.shellescape(path))
	end, { desc = "Glow markdown preview (split terminal)" })
end

return M
