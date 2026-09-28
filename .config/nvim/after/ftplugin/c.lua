--- C buffers: build, run, debug and read docs without leaving Nvim.
---
--- Every map below is a thin wrapper over stock Vim, so nothing here is a crutch you
--- would miss on another box: |:make| fills the quickfix list (|:copen|, |]q| / |[q|),
--- |:Termdebug| is Vim's own gdb frontend, |:Man| reads the same pages as `man 3 printf`.
---
--- Build: a Makefile next to the file → `make -C <dir>`, and the flags are yours.
--- No Makefile (exercises, one-file programs) → this file alone, with CFLAGS below.
--- The binary lands next to the source, named after it: hello.c → ./hello.
---
---   <leader>lb  build            → warnings/errors in quickfix
---   <leader>lr  build + run      → terminal split (stdin works: scanf, fgets)
---   <leader>lR  build + run with arguments (argv)
---   <leader>ld  build + debug in gdb (|:Termdebug|)
---   <leader>lv  build + run under valgrind
---   <leader>lm  man page for the word under the cursor (section 3: the C library)
---   <leader>lh  switch between foo.c and foo.h (clangd)
---   gf          on `#include <stdio.h>` opens the header itself

-- -std=c23: what Effective C (2nd ed., Seacord) teaches — nullptr, bool, constexpr, typeof,
-- <stdckdint.h>. Earlier C code still compiles; `int f()` now means "no parameters".
-- Warnings are the compiler teaching you; -Wall -Wextra -Wpedantic turns most of them on.
-- -Wconversion is the book's recommendation too: it catches `char c = getchar();` and
-- silent signed/unsigned mixing, the integer bugs its chapters on integers are about.
-- -g3 -O0: full debug info, no optimiser reordering the lines you step through in gdb.
local CFLAGS = "-std=c23 -Wall -Wextra -Wpedantic -Wconversion -Wshadow -g3 -O0 -fno-omit-frame-pointer"
-- Out-of-bounds, use-after-free, leaks, signed overflow, … reported at runtime with the
-- offending line. Left out of gdb/valgrind builds: valgrind cannot run an ASan binary,
-- and an ASan abort in gdb is harder to read than a plain segfault.
local SANITIZE = "-fsanitize=address,undefined"
local LIBS = "-lm"

local buf = vim.api.nvim_get_current_buf()

vim.cmd.compiler("gcc") -- 'errorformat' for gcc, and for make's "Entering directory"
vim.opt_local.path:append("/usr/include") -- `gf` on <stdio.h>; Nvim dropped it from the default

local function src_dir()
	return vim.fn.fnamemodify(vim.api.nvim_buf_get_name(buf), ":p:h")
end

local function binary()
	return vim.fn.fnamemodify(vim.api.nvim_buf_get_name(buf), ":p:r")
end

local function has_makefile()
	for _, name in ipairs({ "GNUmakefile", "makefile", "Makefile" }) do
		if vim.uv.fs_stat(vim.fs.joinpath(src_dir(), name)) then
			return true
		end
	end
	return false
end

local function makeprg(sanitize)
	if has_makefile() then
		return "make -C " .. vim.fn.shellescape(src_dir())
	end
	local src = vim.api.nvim_buf_get_name(buf)
	return table.concat({
		"gcc",
		CFLAGS,
		sanitize and SANITIZE or "",
		"-o",
		vim.fn.shellescape(binary()),
		vim.fn.shellescape(src),
		LIBS,
	}, " ")
end

-- Plain `:make` works too, with the sanitizer build.
vim.bo[buf].makeprg = makeprg(true)

---@return boolean ok
local function build(sanitize)
	if vim.api.nvim_buf_get_name(buf) == "" then
		vim.notify("Save the file first — the compiler needs a path.", vim.log.levels.WARN)
		return false
	end
	vim.cmd("silent update")
	vim.bo[buf].makeprg = makeprg(sanitize)
	-- `!`: fill quickfix without jumping to the first entry.
	vim.cmd("silent make!")
	local ok = vim.v.shell_error == 0
	local win = vim.api.nvim_get_current_win()
	vim.cmd("cwindow") -- opens only if there is something to read (errors *or* warnings)
	if ok then
		vim.api.nvim_set_current_win(win)
		-- Only valid entries: gcc's source-snippet and caret lines land in quickfix too.
		local n = #vim.tbl_filter(function(e)
			return e.valid == 1
		end, vim.fn.getqflist())
		vim.notify(n > 0 and "Built, with warnings — read them (quickfix)." or "Built.", vim.log.levels.INFO)
	else
		vim.notify("Build failed — errors in quickfix (]q / [q to step through).", vim.log.levels.ERROR)
	end
	return ok
end

-- Keeps the terminal open after the program exits: the TermClose autocmd in
-- |config.core.autocmds| wipes a terminal whose job exits 0, which would take the
-- output with it. Shows the exit status too — `return 1` from main is worth seeing.
local HOLD = [["$@"; s=$?; printf '\n\033[2m[exit %d · Enter closes]\033[0m' "$s"; read -r _]]

local function in_terminal(argv)
	vim.cmd("belowright 15new")
	vim.fn.jobstart(vim.list_extend({ "sh", "-c", HOLD, "_" }, argv), { term = true, cwd = src_dir() })
	vim.cmd.startinsert()
end

local function run(args)
	if not build(true) then
		return
	end
	if vim.fn.executable(binary()) ~= 1 then
		vim.notify("No executable at " .. binary() .. " — does your Makefile build it there?", vim.log.levels.WARN)
		return
	end
	in_terminal(vim.list_extend({ binary() }, args or {}))
end

local function map(lhs, rhs, desc)
	vim.keymap.set("n", lhs, rhs, { buffer = buf, desc = "C: " .. desc })
end

map("<leader>lb", function()
	build(true)
end, "build (quickfix)")

map("<leader>lr", function()
	run()
end, "build + run")

map("<leader>lR", function()
	vim.ui.input({ prompt = "Arguments: " }, function(input)
		if input then
			run(vim.split(vim.trim(input), "%s+", { trimempty = true }))
		end
	end)
end, "build + run with arguments")

map("<leader>ld", function()
	if not build(false) then
		return
	end
	vim.cmd.packadd("termdebug")
	vim.cmd("Termdebug " .. vim.fn.fnameescape(binary()))
end, "build + debug (gdb)")

map("<leader>lv", function()
	if vim.fn.executable("valgrind") ~= 1 then
		vim.notify("valgrind not installed: sudo pacman -S valgrind", vim.log.levels.WARN)
		return
	end
	if build(false) then
		in_terminal({ "valgrind", "--leak-check=full", "--show-leak-kinds=all", "--track-origins=yes", binary() })
	end
end, "build + valgrind")

map("<leader>lm", function()
	local word = vim.fn.expand("<cword>")
	-- Section 3 first (printf the C function, not printf(1) the shell command).
	if not pcall(vim.cmd.Man, { args = { "3", word } }) then
		pcall(vim.cmd.Man, word)
	end
end, "man page (section 3)")

map("<leader>lh", "<cmd>LspClangdSwitchSourceHeader<cr>", "switch source/header")
