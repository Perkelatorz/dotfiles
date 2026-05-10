--- Third-party plugins via |vim.pack| (:help vim.pack).
--- With several machines: commit |nvim-pack-lock.json| in yadm so every host uses the same plugin revisions.

local M = {}

local function gh(repo)
	return "https://github.com/" .. repo
end

function M.setup()
	vim.pack.add(
		{
			gh("folke/which-key.nvim"),
			gh("nvim-lualine/lualine.nvim"),
			gh("folke/flash.nvim"),
			gh("nvim-tree/nvim-web-devicons"),
			gh("williamboman/mason.nvim"),
			gh("WhoIsSethDaniel/mason-tool-installer.nvim"),
			gh("williamboman/mason-lspconfig.nvim"),
			gh("neovim/nvim-lspconfig"),
			gh("nvim-treesitter/nvim-treesitter"),
			gh("nvim-treesitter/nvim-treesitter-textobjects"),
			gh("windwp/nvim-ts-autotag"),
			gh("windwp/nvim-autopairs"),
			gh("kylechui/nvim-surround"),
			gh("stevearc/conform.nvim"),
			gh("hrsh7th/nvim-cmp"),
			gh("hrsh7th/cmp-nvim-lsp"),
			gh("hrsh7th/cmp-buffer"),
			gh("hrsh7th/cmp-path"),
			gh("f3fora/cmp-spell"),
			gh("Exafunction/windsurf.nvim"),
			gh("nvim-lua/plenary.nvim"),
			gh("lewis6991/gitsigns.nvim"),
			gh("sindrets/diffview.nvim"),
			gh("j-hui/fidget.nvim"),
			gh("MunifTanjim/nui.nvim"),
			gh("nvim-telescope/telescope.nvim"),
			gh("nvim-telescope/telescope-fzf-native.nvim"),
			gh("mfussenegger/nvim-lint"),
			gh("hat0uma/csvview.nvim"),
			gh("MeanderingProgrammer/render-markdown.nvim"),
			gh("folke/trouble.nvim"),
			gh("rcarriga/nvim-notify"),
			gh("stevearc/dressing.nvim"),
			gh("lukas-reineke/indent-blankline.nvim"),
			gh("otavioschwanck/arrow.nvim"),
			gh("s1n7ax/nvim-window-picker"),
			{ src = gh("akinsho/toggleterm.nvim"), version = "v2.13.1" },
			{ src = gh("nvim-neo-tree/neo-tree.nvim"), version = vim.version.range("3") },
		},
		{ confirm = false, load = true }
	)
end

return M
