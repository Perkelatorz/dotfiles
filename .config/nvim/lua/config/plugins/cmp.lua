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
		sources = cmp.config.sources({
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
		}),
	})
end

return M
