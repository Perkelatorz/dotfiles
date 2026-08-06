--- Keymap discovery — a browser for keys which-key structurally cannot pop up for.
---
--- which-key only appears for *prefixes*: you press `<leader>`, it waits `delay` ms, then
--- lists what may follow. A single-keypress mapping like `<C-s>` or `<C-d>` is not a
--- prefix — it fires the instant you hit it, so there is nothing to disambiguate and no
--- popup ever appears. That is by design, and no which-key setting changes it.
---
--- This module fills that gap with searchable pickers (Telescope's `keymaps` builtin,
--- which reads live from |nvim_get_keymap| so it can never drift from reality) plus
--- explicit which-key roots per mode.
---
--- Everything lives under `<leader>k`. Start with `<leader>kc` for the Ctrl list.

local M = {}

--- Telescope's keymaps picker defaults to { n, i, c, x } — that silently drops
--- visual, select, operator-pending and terminal maps. List every mode instead.
local ALL_MODES = { "n", "i", "v", "x", "s", "o", "t", "c" }

--- Open the keymaps picker with a title and optional lhs predicate.
---@param title string
---@param lhs_filter? fun(lhs: string): boolean
local function picker(title, lhs_filter)
	return function()
		require("telescope.builtin").keymaps({
			prompt_title = title,
			modes = ALL_MODES,
			lhs_filter = lhs_filter,
			-- <Plug> maps are plumbing, not something you press.
			show_plug = false,
		})
	end
end

--- which-key's root popup for a mode. Unlike the automatic popup this is explicit, so it
--- lists *every* top-level key in that mode — Ctrl combos included.
---@param mode string
local function wk_root(mode)
	return function()
		require("which-key").show({ mode = mode, keys = "" })
	end
end

function M.setup()
	local map = function(lhs, rhs, desc)
		vim.keymap.set("n", lhs, rhs, { desc = desc })
	end

	-- Searchable pickers (fuzzy-filter by lhs or description).
	map("<leader>kk", picker("All keymaps"), "Keys: all keymaps (searchable)")
	map(
		"<leader>kc",
		picker("Ctrl keymaps", function(lhs)
			return lhs:find("<C%-") ~= nil
		end),
		"Keys: Ctrl combos"
	)
	map(
		"<leader>ka",
		picker("Alt/Meta keymaps", function(lhs)
			return lhs:find("<M%-") ~= nil or lhs:find("<A%-") ~= nil
		end),
		"Keys: Alt/Meta combos"
	)
	map(
		"<leader>kl",
		picker("Leader keymaps", function(lhs)
			-- mapleader is a literal space in the stored lhs.
			return lhs:sub(1, 1) == " "
		end),
		"Keys: leader maps"
	)
	map(
		"<leader>kf",
		picker("Function-key maps", function(lhs)
			return lhs:find("<F%d") ~= nil
		end),
		"Keys: function keys"
	)

	-- which-key roots — the same UI as the popup, shown on demand.
	map("<leader>kn", wk_root("n"), "Keys: which-key root (normal)")
	map("<leader>ki", wk_root("i"), "Keys: which-key root (insert)")
	map("<leader>kx", wk_root("x"), "Keys: which-key root (visual)")
	map("<leader>kt", wk_root("t"), "Keys: which-key root (terminal)")
	map("<leader>kb", function()
		require("which-key").show({ global = false })
	end, "Keys: buffer-local only")

	-- :Keys [filter] — same lists without leaving the command line.
	-- :Keys           all
	-- :Keys ctrl      Ctrl combos      :Keys alt     Alt/Meta combos
	-- :Keys leader    leader maps      :Keys fn      function keys
	vim.api.nvim_create_user_command("Keys", function(cmd)
		local what = (cmd.args or ""):lower()
		local filters = {
			ctrl = { "Ctrl keymaps", function(l) return l:find("<C%-") ~= nil end },
			alt = { "Alt/Meta keymaps", function(l) return l:find("<M%-") ~= nil or l:find("<A%-") ~= nil end },
			leader = { "Leader keymaps", function(l) return l:sub(1, 1) == " " end },
			fn = { "Function-key maps", function(l) return l:find("<F%d") ~= nil end },
		}
		local f = filters[what]
		if what ~= "" and not f then
			vim.notify(
				("Keys: unknown filter %q (try: ctrl, alt, leader, fn, or no argument)"):format(cmd.args),
				vim.log.levels.WARN
			)
			return
		end
		if f then
			picker(f[1], f[2])()
		else
			picker("All keymaps")()
		end
	end, {
		nargs = "?",
		complete = function(lead)
			return vim.tbl_filter(function(c)
				return c:find(lead, 1, true) == 1
			end, { "ctrl", "alt", "leader", "fn" })
		end,
		desc = "Browse keymaps (optionally filtered)",
	})
end

return M
