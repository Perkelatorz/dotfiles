local M = {}

M.checkpoints = {}

M.session_checkpoint = {
	files = {}, -- { filepath: { lines, timestamp } }
	timestamp = nil,
}

function M.create_checkpoint(bufnr)
	bufnr = bufnr or vim.api.nvim_get_current_buf()
	
	if not vim.api.nvim_buf_is_valid(bufnr) then
		return
	end
	
	local filepath = vim.api.nvim_buf_get_name(bufnr)
	if filepath == "" then
		return
	end
	
	local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
	local cursor = vim.api.nvim_win_get_cursor(0)
	
	M.checkpoints[bufnr] = {
		filepath = filepath,
		lines = lines,
		cursor = cursor,
		timestamp = os.time(),
	}
	
	vim.notify(
		string.format("📌 Checkpoint created: %s", vim.fn.fnamemodify(filepath, ":t")),
		vim.log.levels.INFO,
		{ title = "Checkpoint", timeout = 2000 }
	)
end

function M.create_session_checkpoint()
	M.session_checkpoint.files = {}
	M.session_checkpoint.timestamp = os.time()
	
	local count = 0
	for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
		if vim.api.nvim_buf_is_valid(bufnr) and vim.api.nvim_buf_is_loaded(bufnr) then
			local filepath = vim.api.nvim_buf_get_name(bufnr)
			if filepath ~= "" and vim.bo[bufnr].buftype == "" then
				M.session_checkpoint.files[filepath] = {
					lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false),
					bufnr = bufnr,
				}
				count = count + 1
			end
		end
	end
	
	vim.notify(
		string.format("📌 Session checkpoint created (%d files)", count),
		vim.log.levels.INFO,
		{ title = "Session Checkpoint", timeout = 2000 }
	)
end

function M.create_project_checkpoint()
	M.session_checkpoint.files = {}
	M.session_checkpoint.timestamp = os.time()
	
	local files = {}
	
	local git_files = vim.fn.systemlist("git ls-files 2>/dev/null")
	if vim.v.shell_error == 0 and #git_files > 0 then
		files = git_files
	else
		local find_cmd = "find . -type f -not -path '*/node_modules/*' -not -path '*/.git/*' -not -path '*/dist/*' -not -path '*/build/*' 2>/dev/null"
		files = vim.fn.systemlist(find_cmd)
	end
	
	local count = 0
	for _, filepath in ipairs(files) do
		local abs_path = vim.fn.fnamemodify(filepath, ":p")
		
		if vim.fn.filereadable(abs_path) == 1 then
			local lines = vim.fn.readfile(abs_path)
			M.session_checkpoint.files[abs_path] = {
				lines = lines,
				bufnr = vim.fn.bufnr(abs_path), -- May be -1 if not loaded
			}
			count = count + 1
		end
		
		if count >= 500 then
			vim.notify("Limiting to first 500 files", vim.log.levels.WARN)
			break
		end
	end
	
	vim.notify(
		string.format("📌 Project checkpoint created (%d files)", count),
		vim.log.levels.INFO,
		{ title = "Project Checkpoint", timeout = 3000 }
	)
end

function M.auto_checkpoint(bufnr)
	bufnr = bufnr or vim.api.nvim_get_current_buf()
	
	local checkpoint = M.checkpoints[bufnr]
	if not checkpoint or (os.time() - checkpoint.timestamp) > 60 then
		M.create_checkpoint(bufnr)
	end
end

function M.restore_checkpoint(bufnr)
	bufnr = bufnr or vim.api.nvim_get_current_buf()
	
	local checkpoint = M.checkpoints[bufnr]
	if not checkpoint then
		vim.notify("No checkpoint found for this buffer", vim.log.levels.WARN)
		return
	end
	
	vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, checkpoint.lines)
	
	pcall(vim.api.nvim_win_set_cursor, 0, checkpoint.cursor)
	
	vim.bo[bufnr].modified = true
	
	local filename = vim.fn.fnamemodify(checkpoint.filepath, ":t")
	vim.notify(
		string.format("✅ Restored checkpoint: %s\nSave with :w to keep", filename),
		vim.log.levels.INFO,
		{ title = "Checkpoint Restored", timeout = 3000 }
	)
end

function M.restore_session_checkpoint()
	if not M.session_checkpoint.timestamp then
		vim.notify("No session checkpoint found", vim.log.levels.WARN)
		return
	end
	
	local count = 0
	local written = 0
	
	for filepath, data in pairs(M.session_checkpoint.files) do
		local bufnr = vim.fn.bufnr(filepath)
		if bufnr > 0 and vim.api.nvim_buf_is_valid(bufnr) and vim.api.nvim_buf_is_loaded(bufnr) then
			vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, data.lines)
			vim.bo[bufnr].modified = true
			count = count + 1
		else
			local ok = pcall(vim.fn.writefile, data.lines, filepath)
			if ok then
				written = written + 1
			end
		end
	end
	
	local msg = string.format("✅ Restored: %d open files", count)
	if written > 0 then
		msg = msg .. string.format(", wrote %d unopened files", written)
	end
	
	vim.notify(msg, vim.log.levels.INFO, { title = "Session Restored", timeout = 3000 })
end

function M.show_diff(bufnr)
	bufnr = bufnr or vim.api.nvim_get_current_buf()
	
	local checkpoint = M.checkpoints[bufnr]
	if not checkpoint then
		vim.notify("No checkpoint found for this buffer", vim.log.levels.WARN)
		return
	end
	
	local current_lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
	local filename = vim.fn.fnamemodify(checkpoint.filepath, ":t")
	
	local diff_buf = vim.api.nvim_create_buf(false, true)
	
	local diff_content = { "Changes made to: " .. filename }
	table.insert(diff_content, "Checkpoint: " .. os.date("%Y-%m-%d %H:%M:%S", checkpoint.timestamp))
	table.insert(diff_content, string.rep("═", 60))
	table.insert(diff_content, "")
	
	local max_show = 15
	local total_changes = 0
	local shown_changes = 0

	for i = 1, math.max(#checkpoint.lines, #current_lines) do
		local old_line = checkpoint.lines[i] or ""
		local new_line = current_lines[i] or ""
		local old_trimmed = old_line:match("^%s*(.-)%s*$") or ""
		local new_trimmed = new_line:match("^%s*(.-)%s*$") or ""

		if old_trimmed ~= new_trimmed and (old_trimmed ~= "" or new_trimmed ~= "") then
			total_changes = total_changes + 1
			if shown_changes < max_show then
				table.insert(diff_content, string.format("Line %d:", i))
				table.insert(diff_content, "  BEFORE: " .. old_line)
				table.insert(diff_content, "  AFTER:  " .. new_line)
				table.insert(diff_content, "")
				shown_changes = shown_changes + 1
			end
		end
	end

	local remaining = total_changes - shown_changes
	if remaining > 0 then
		table.insert(diff_content, string.format("... and %d more changes", remaining))
		table.insert(diff_content, "")
	end
	
	if not changes_found then
		table.insert(diff_content, "No changes detected")
	else
		table.insert(diff_content, "")
		table.insert(diff_content, "Commands:")
		table.insert(diff_content, "  <leader>vr - Restore checkpoint (undo all changes)")
		table.insert(diff_content, "  <leader>vx - Delete checkpoint")
		table.insert(diff_content, "  q - Close this window")
	end
	
	vim.api.nvim_buf_set_lines(diff_buf, 0, -1, false, diff_content)
	vim.bo[diff_buf].filetype = "diff"
	vim.bo[diff_buf].modifiable = false
	
	vim.cmd("botright split")
	local win = vim.api.nvim_get_current_win()
	vim.api.nvim_win_set_buf(win, diff_buf)
	vim.api.nvim_win_set_height(win, math.min(#diff_content + 2, 20))
	
	vim.keymap.set("n", "q", ":close<CR>", { buffer = diff_buf, silent = true })
	vim.keymap.set("n", "<leader>vr", function()
		vim.cmd("close")
		M.restore_checkpoint(bufnr)
	end, { buffer = diff_buf, silent = true, desc = "Restore checkpoint from diff" })
end

function M.show_session_diff()
	if not M.session_checkpoint.timestamp then
		vim.notify("No session checkpoint found", vim.log.levels.WARN)
		return
	end
	
	local diff_buf = vim.api.nvim_create_buf(false, true)
	local diff_content = { 
		"SESSION CHECKPOINT DIFF",
		"Created: " .. os.date("%Y-%m-%d %H:%M:%S", M.session_checkpoint.timestamp),
		string.rep("═", 80),
		""
	}
	
	local total_changes = 0
	
	for filepath, checkpoint_data in pairs(M.session_checkpoint.files) do
		local bufnr = vim.fn.bufnr(filepath)
		if bufnr > 0 and vim.api.nvim_buf_is_valid(bufnr) and vim.api.nvim_buf_is_loaded(bufnr) then
			local current_lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
			local filename = vim.fn.fnamemodify(filepath, ":t")
			
			local file_changes = 0
			local changed_lines = {}
			
			for i = 1, math.max(#checkpoint_data.lines, #current_lines) do
				local old_line = checkpoint_data.lines[i] or ""
				local new_line = current_lines[i] or ""
				
				local old_trimmed = old_line:match("^%s*(.-)%s*$") or ""
				local new_trimmed = new_line:match("^%s*(.-)%s*$") or ""
				
				if old_trimmed ~= new_trimmed and (old_trimmed ~= "" or new_trimmed ~= "") then
					file_changes = file_changes + 1
					table.insert(changed_lines, {
						line = i,
						old = old_line,
						new = new_line,
					})
				end
			end
			
			if file_changes > 0 then
				total_changes = total_changes + file_changes
				table.insert(diff_content, string.format("📄 %s (%d meaningful changes)", filename, file_changes))
				table.insert(diff_content, string.rep("─", 80))
				
					for idx, change in ipairs(changed_lines) do
					if idx <= 5 then
						table.insert(diff_content, string.format("  Line %d:", change.line))
						table.insert(diff_content, "    - " .. change.old)
						table.insert(diff_content, "    + " .. change.new)
					elseif idx == 6 then
						table.insert(diff_content, string.format("    ... and %d more changes (use <leader>zd on that file to see all)", #changed_lines - 5))
						break
					end
				end
				table.insert(diff_content, "")
			end
		end
	end
	
	if total_changes == 0 then
		table.insert(diff_content, "No changes detected")
	else
		table.insert(diff_content, string.rep("═", 80))
		table.insert(diff_content, string.format("Total: %d changes across %d files", total_changes, vim.tbl_count(M.session_checkpoint.files)))
		table.insert(diff_content, "")
		table.insert(diff_content, "Commands:")
		table.insert(diff_content, "  <leader>vR - Restore entire session (undo ALL changes)")
		table.insert(diff_content, "  <leader>vx - Delete session checkpoint")
		table.insert(diff_content, "  q - Close this window")
	end
	
	vim.api.nvim_buf_set_lines(diff_buf, 0, -1, false, diff_content)
	vim.bo[diff_buf].filetype = "diff"
	vim.bo[diff_buf].modifiable = false
	
	vim.cmd("tabnew")
	local win = vim.api.nvim_get_current_win()
	vim.api.nvim_win_set_buf(win, diff_buf)
	
	vim.keymap.set("n", "q", ":tabclose<CR>", { buffer = diff_buf, silent = true })
	vim.keymap.set("n", "<leader>vk", function()
		vim.cmd("tabclose")
		M.restore_session_checkpoint()
	end, { buffer = diff_buf, silent = true, desc = "Restore session from diff" })
end

function M.delete_checkpoint(bufnr)
	bufnr = bufnr or vim.api.nvim_get_current_buf()
	M.checkpoints[bufnr] = nil
	vim.notify("Checkpoint deleted", vim.log.levels.INFO)
end

function M.delete_session_checkpoint()
	M.session_checkpoint = { files = {}, timestamp = nil }
	vim.notify("Session checkpoint deleted", vim.log.levels.INFO)
end

vim.api.nvim_create_user_command("CheckpointCreate", function()
	M.create_checkpoint()
end, { desc = "Create checkpoint for current buffer" })

vim.api.nvim_create_user_command("CheckpointRestore", function()
	M.restore_checkpoint()
end, { desc = "Restore checkpoint for current buffer" })

vim.api.nvim_create_user_command("CheckpointDiff", function()
	M.show_diff()
end, { desc = "Show diff with checkpoint" })

vim.api.nvim_create_user_command("CheckpointDelete", function()
	M.delete_checkpoint()
end, { desc = "Delete checkpoint for current buffer" })

vim.api.nvim_create_user_command("SessionCheckpoint", function()
	M.create_session_checkpoint()
end, { desc = "Create checkpoint for all open buffers" })

vim.api.nvim_create_user_command("SessionRestore", function()
	M.restore_session_checkpoint()
end, { desc = "Restore session checkpoint (all files)" })

vim.api.nvim_create_user_command("SessionDiff", function()
	M.show_session_diff()
end, { desc = "Show diff for session checkpoint (all files)" })

vim.api.nvim_create_user_command("SessionCheckpointDelete", function()
	M.delete_session_checkpoint()
end, { desc = "Delete session checkpoint" })

vim.api.nvim_create_user_command("ProjectCheckpoint", function()
	M.create_project_checkpoint()
end, { desc = "Create checkpoint for all project files" })

return M
