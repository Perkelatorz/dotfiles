--- nvim-cmp: completion menu in insert mode.
--- cmp-nvim-lsp feeds LSP suggestions into cmp; buffer suggests words from open buffers.

local M = {}

function M.setup()
	local cmp = require("cmp")

	-- LSP kind icons (Nerd Fonts / codicons-style private use area)
	local kind_icons = {
		Text = "󰉿",
		Method = "󰆧",
		Function = "󰊕",
		Constructor = "󰒓",
		Field = "󰜢",
		Variable = "󰀫",
		Class = "󰌗",
		Interface = "󰜰",
		Module = "󰏗",
		Property = "󰜢",
		Unit = "󰅐",
		Value = "󰎠",
		Enum = "󰕘",
		Keyword = "󰌋",
		Snippet = "󰃐",
		Color = "󰏘",
		File = "󰈔",
		Reference = "󰈇",
		Folder = "󰉋",
		EnumMember = "󰕘",
		Constant = "󰏿",
		Struct = "󰙅",
		Event = "󰉒",
		Operator = "󰆕",
		TypeParameter = "󰆦",
		Codeium = "󰘦",
	}

	local sources = {
		{ name = "codeium", priority = 1, max_item_count = 3 },
		{ name = "nvim_lsp", priority = 2 },
		{ name = "path" },
		{
			name = "spell",
			option = {
				keep_all_entries = true,
				enable_in_context = function()
					return vim.wo.spell
				end,
				preselect_correct_word = true,
			},
		},
		{ name = "buffer" },
	}

	cmp.setup({
		snippet = {
			expand = function(args)
				vim.snippet.expand(args.body)
			end,
		},
		formatting = {
			format = function(entry, vim_item)
				local menu = ({
					codeium = "[AI]",
					nvim_lsp = "[LSP]",
					spell = "[Spell]",
					buffer = "[Buf]",
				})[entry.source.name]
				if menu then
					vim_item.menu = menu
				end
				local icon = kind_icons[vim_item.kind] or "󰦺"
				vim_item.kind = string.format("%s %s", icon, vim_item.kind or "")
				return vim_item
			end,
		},
		window = {
			completion = cmp.config.window.bordered(),
			documentation = cmp.config.window.bordered(),
		},
		mapping = cmp.mapping.preset.insert({
			["<CR>"] = cmp.mapping.confirm({ select = true }),
		}),
		sources = cmp.config.sources(sources),
	})

	-- C: same list minus Codeium (see |config.plugins.codeium| for why).
	cmp.setup.filetype("c", {
		sources = cmp.config.sources(vim.tbl_filter(function(src)
			return src.name ~= "codeium"
		end, sources)),
	})
end

return M
