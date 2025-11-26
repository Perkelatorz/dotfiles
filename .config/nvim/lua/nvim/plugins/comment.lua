return {
	"numToStr/Comment.nvim",
	event = { "BufReadPre", "BufNewFile" },
	dependencies = {
		"JoosepAlviste/nvim-ts-context-commentstring",
	},
	config = function()
		local utils = require("nvim.core.utils")
		
		-- import comment plugin safely
		local comment, comment_ok = utils.safe_require("Comment")
		if not comment_ok then
			return
		end

		local ts_context_commentstring, ts_ok = utils.safe_require("ts_context_commentstring.integrations.comment_nvim")
		
		-- enable comment
		local opts = {}
		if ts_ok then
			opts.pre_hook = ts_context_commentstring.create_pre_hook()
		end
		
		comment.setup(opts)
	end,
}
