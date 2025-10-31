return {
	"towolf/vim-helm",
	ft = "helm",
	config = function()
		vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
			pattern = { "*/templates/*.yaml", "*/templates/*.tpl", "*.gotmpl" },
			callback = function()
				vim.bo.filetype = "helm"
			end,
		})
	end,
}
