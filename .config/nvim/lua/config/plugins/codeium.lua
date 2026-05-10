--- Windsurf / Codeium: cmp + inline ghost text (matches prior Lazy setup).
--- First auth: |:Codeium Auth| · |<Leader>aw| toggle · |<Leader>ac| chat · |<Leader>aa| auth · |<Leader>as| status.
--- Browser: use **global** defaults — |$BROWSER| (see |~/.config/environment.d/browser.conf|), |xdg-mime| in yadm bootstrap, |export BROWSER=firefox| in |~/.config/zsh/.zprofile|.
--- Auth URLs: detached |xdg-open| (respects XDG default; avoids Plenary 1s sync timeout). Flatpak Firefox: set |xdg-mime| / default app, or override |tools["xdg-open"]| here.

local M = {}

function M.setup()
	require("codeium").setup({
		-- Detached so Plenary does not wait on the browser; uses system http(s) handler (xdg-mime).
		tools = {
			["xdg-open"] = {
				"sh",
				"-c",
				'xdg-open "$1" </dev/null >/dev/null 2>&1 &',
				"_",
			},
		},
		enable_cmp_source = true,
		enable_chat = true,
		virtual_text = {
			enabled = true,
			manual = false,
			idle_delay = 75,
			filetypes = {},
			default_filetype_enabled = true,
			map_keys = true,
			key_bindings = {
				accept = "<M-y>",
				accept_word = "<M-w>",
				accept_line = "<M-l>",
				clear = "<C-]>",
				next = "<M-]>",
				prev = "<M-[>",
			},
		},
		workspace_root = {
			use_lsp = true,
			find_root = nil,
			paths = {
				".bzr",
				".git",
				".hg",
				".svn",
				"_FOSSIL_",
				"package.json",
			},
		},
	})

	local keymap = vim.keymap.set
	keymap("n", "<leader>aw", "<cmd>Codeium Toggle<cr>", { desc = "Codeium toggle" })
	keymap("n", "<leader>ac", "<cmd>Codeium Chat<cr>", { desc = "Codeium chat (browser)" })
	keymap("n", "<leader>aa", "<cmd>Codeium Auth<cr>", { desc = "Codeium auth" })
	keymap("n", "<leader>as", function()
		local status = require("codeium.virtual_text").status()
		local msg = "Codeium: "
		if status.state == "idle" then
			msg = msg .. "Idle"
		elseif status.state == "waiting" then
			msg = msg .. "Waiting for suggestions…"
		elseif status.state == "completions" and status.total > 0 then
			msg = msg .. string.format("Suggestion %d/%d", status.current, status.total)
		else
			msg = msg .. "No suggestions"
		end
		vim.notify(msg, vim.log.levels.INFO)
	end, { desc = "Codeium status" })
end

return M
