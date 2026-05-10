--- Auto-pair brackets/quotes. Integrates with cmp so `(` after function name inserts pair after confirm.

local M = {}

function M.setup()
	require("nvim-autopairs").setup({
		check_ts = true,
		ts_config = {
			lua = { "string" },
			javascript = { "template_string" },
			typescript = { "template_string" },
		},
		fast_wrap = {},
	})

	local ok_cmp, cmp = pcall(require, "cmp")
	if ok_cmp then
		local ok_pair, pair = pcall(require, "nvim-autopairs.completion.cmp")
		if ok_pair then
			cmp.event:on("confirm_done", pair.on_confirm_done())
		end
	end
end

return M
