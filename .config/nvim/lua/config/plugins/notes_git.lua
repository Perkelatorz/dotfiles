--- Auto-commit the notes vault, like Obsidian's Git plugin.
---
--- The vault is its own git repo and `.git` is deliberately excluded from Syncthing
--- (see meta/sync), so history is a per-machine undo net rather than the transport.
--- That only works if commits actually happen, and they will not happen by hand.
---
--- DEBOUNCED, not per-save. Committing on every |BufWritePost| would produce a
--- commit per keystroke-batch -- Obsidian's plugin has the same problem and solves
--- it with an interval. Here a write starts (or restarts) a timer, and the commit
--- lands once writing has stopped for `debounce_ms`. A burst of ten saves while
--- editing one note is one commit.
---
--- Everything runs through |vim.system| with a callback, so nothing blocks the UI
--- and a slow or wedged git can never freeze the editor.
---
--- Scoped to the vault: the autocmd pattern is the vault path, so this cannot fire
--- in a code repo and surprise you with commits you did not make.

local M = {}

local uv = vim.uv or vim.loop

local config = {
	debounce_ms = 30000,
	-- Commit whatever is outstanding when Nvim exits, so closing the editor never
	-- leaves the last few minutes of writing uncommitted.
	commit_on_exit = true,
}

local vault = nil
local timer = nil
local running = false
--- Set when *this* session writes a vault file, cleared once that write is
--- committed. The exit hook consults it so that quitting an Nvim which never
--- touched the vault does not commit -- otherwise every `nvim main.go` would
--- sweep up whatever half-finished state the vault happened to be in, including
--- edits from another editor session or a Syncthing pull still in flight.
local dirty = false

--- True when the vault is a git repo we can commit to.
local function usable()
	return vault ~= nil and vim.fn.isdirectory(vault .. "/.git") == 1
end

--- Run git in the vault. `cb` receives the completed |vim.SystemCompleted|.
local function git(args, cb)
	vim.system(vim.list_extend({ "git", "-C", vault }, args), { text = true }, cb)
end

--- Stage everything and commit, if anything changed.
---
--- `git commit` is given an explicit message and --no-verify: the vault has no
--- hooks today, but a global core.hooksPath would otherwise be able to block or
--- rewrite a commit the user never asked for.
local function commit(opts)
	opts = opts or {}
	if not usable() or running then
		return
	end
	running = true

	git({ "status", "--porcelain" }, function(status)
		if status.code ~= 0 or (status.stdout or "") == "" then
			running = false -- nothing to do, or not a repo
			if opts.notify then
				vim.schedule(function()
					vim.notify("notes: nothing to commit", vim.log.levels.INFO)
				end)
			end
			return
		end

		-- A count of changed paths makes the log readable at a glance; the diff is
		-- there for anything more specific.
		local n = 0
		for _ in (status.stdout or ""):gmatch("[^\n]+") do
			n = n + 1
		end
		local msg = ("notes: autosave %s (%d file%s)"):format(os.date("%Y-%m-%d %H:%M"), n, n == 1 and "" or "s")

		git({ "add", "-A" }, function(added)
			if added.code ~= 0 then
				running = false
				vim.schedule(function()
					vim.notify("notes: git add failed\n" .. (added.stderr or ""), vim.log.levels.ERROR)
				end)
				return
			end
			git({ "commit", "--no-verify", "-m", msg }, function(done)
				running = false
				if done.code == 0 then
					dirty = false
				end
				if done.code ~= 0 then
					vim.schedule(function()
						vim.notify("notes: commit failed\n" .. (done.stderr or ""), vim.log.levels.ERROR)
					end)
				elseif opts.notify then
					vim.schedule(function()
						vim.notify(msg, vim.log.levels.INFO)
					end)
				end
			end)
		end)
	end)
end

--- Restart the debounce window. Called on every write inside the vault.
local function schedule()
	if not usable() then
		return
	end
	if timer then
		timer:stop()
		timer:close()
	end
	timer = uv.new_timer()
	timer:start(
		config.debounce_ms,
		0,
		vim.schedule_wrap(function()
			if timer then
				timer:stop()
				timer:close()
				timer = nil
			end
			commit()
		end)
	)
end

function M.setup(opts)
	config = vim.tbl_extend("force", config, opts or {})

	local raw = vim.env.NOTES
	if raw == nil or raw == "" then
		raw = "~/notes"
	end
	vault = vim.fn.resolve(vim.fn.expand(raw)):gsub("/$", "")

	if vim.fn.isdirectory(vault) == 0 then
		return -- no vault on this machine; stay silent
	end

	local group = vim.api.nvim_create_augroup("config.notes_git", { clear = true })

	vim.api.nvim_create_autocmd("BufWritePost", {
		group = group,
		pattern = vault .. "/*",
		callback = function()
			dirty = true
			schedule()
		end,
		desc = "Notes vault: schedule a debounced auto-commit",
	})

	if config.commit_on_exit then
		vim.api.nvim_create_autocmd("VimLeavePre", {
			group = group,
			callback = function()
				if timer then
					timer:stop()
					timer:close()
					timer = nil
				end
				-- Only if this session actually wrote a vault file and the debounce
				-- had not yet fired. Without the `dirty` gate every Nvim quit --
				-- including one that only ever opened a Go file -- would commit
				-- the vault's current state, whatever produced it.
				if not dirty or not usable() then
					return
				end
				-- Synchronous on purpose. The async path cannot finish here: Nvim
				-- would exit and kill the child before it committed. `wait` bounds
				-- it so a wedged git delays quit by 5s at worst.
				local ok = pcall(function()
					local st = vim.system({ "git", "-C", vault, "status", "--porcelain" }, { text = true }):wait(5000)
					if st.code ~= 0 or (st.stdout or "") == "" then
						return
					end
					vim.system({ "git", "-C", vault, "add", "-A" }, { text = true }):wait(5000)
					vim.system({
						"git",
						"-C",
						vault,
						"commit",
						"--no-verify",
						"-m",
						"notes: autosave " .. os.date("%Y-%m-%d %H:%M") .. " (on exit)",
					}, { text = true }):wait(5000)
				end)
				if not ok then
					-- Never let a failed commit block quitting.
					return
				end
			end,
			desc = "Notes vault: commit outstanding changes on exit",
		})
	end

	vim.api.nvim_create_user_command("NotesCommit", function()
		commit({ notify = true })
	end, { desc = "Notes vault: commit now instead of waiting for the debounce" })

	vim.api.nvim_create_user_command("NotesLog", function()
		if not usable() then
			vim.notify("notes: no vault repo at " .. tostring(vault), vim.log.levels.WARN)
			return
		end
		git({ "log", "--oneline", "-20" }, function(res)
			vim.schedule(function()
				vim.notify(res.stdout or res.stderr or "", vim.log.levels.INFO)
			end)
		end)
	end, { desc = "Notes vault: recent commits" })
end

return M
