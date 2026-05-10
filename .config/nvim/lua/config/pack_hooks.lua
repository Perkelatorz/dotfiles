--- Run after |PackChanged| (install/update): native builds for vim.pack plugins.

local M = {}

function M.register()
	vim.api.nvim_create_autocmd("PackChanged", {
		group = vim.api.nvim_create_augroup("config.pack_hooks", { clear = true }),
		callback = function(ev)
			local kind = ev.data.kind
			if kind ~= "install" and kind ~= "update" then
				return
			end
			local path = ev.data.path
			local name = ev.data.spec.name
			if not path or not name then
				return
			end
			if name == "telescope-fzf-native.nvim" then
				local n = (vim.uv and vim.uv.available_parallelism and vim.uv.available_parallelism()) or 4
				vim.notify("Building telescope-fzf-native (make)…", vim.log.levels.INFO)
				vim.system({ "make", "-j", tostring(n), "-C", path }, {}, function(out)
					vim.schedule(function()
						if out.code ~= 0 then
							vim.notify(
								("telescope-fzf-native build failed (exit %d)\n%s"):format(
									out.code,
									(out.stderr or ""):gsub("%s+$", "")
								),
								vim.log.levels.ERROR
							)
						else
							vim.notify("telescope-fzf-native build finished.", vim.log.levels.INFO)
						end
					end)
				end)
			end
		end,
	})
end

return M
