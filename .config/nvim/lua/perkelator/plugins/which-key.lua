return {
	"folke/which-key.nvim",
	event = "VeryLazy",
	init = function()
		vim.o.timeout = true
		vim.o.timeoutlen = 500
	end,
	config = function()
		local status_ok, which_key = pcall(require, "which-key") -- Corrected to which_key without hyphens
		if not status_ok then
			return
		end

		which_key.add({
			{ "<leader>c", group = "Code suggestions", nowait = true, remap = false },
			{ "<leader>e", group = "Explorer", nowait = true, remap = false },
			{ "<leader>f", group = "Find", nowait = true, remap = false },
			{ "<leader>h", group = "Hunk", nowait = true, remap = false },
			{ "<leader>m", group = "Format", nowait = true, remap = false },
			{ "<leader>n", group = "Search highlights", nowait = true, remap = false },
			{ "<leader>s", group = "Split", nowait = true, remap = false },
			{ "<leader>t", group = "Tab", nowait = true, remap = false },
			{ "<leader>w", group = "Session", nowait = true, remap = false },
			{ "<leader>x", group = "Trouble", nowait = true, remap = false },
		})
	end,
}
