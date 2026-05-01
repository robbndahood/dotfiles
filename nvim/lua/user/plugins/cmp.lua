local M = {
	"hrsh7th/nvim-cmp",
	cond = function()
		return not require("user.utils").is_vscode()
	end,
	-- event = "BufReadPre",
	event = { "InsertEnter", "CmdlineEnter" },
	dependencies = {
		"neovim/nvim-lspconfig",
		"hrsh7th/cmp-nvim-lsp",
		"hrsh7th/cmp-path",
		"hrsh7th/cmp-buffer",
		"hrsh7th/cmp-cmdline",
		"saadparwaiz1/cmp_luasnip",
		"L3MON4D3/LuaSnip",
		-- lua snip
	},
	version = false,
}

local kind_icons = {
	Text = "󰉿",
	Method = "󰆧",
	Function = "󰊕",
	Constructor = "",
	Field = " ",
	Variable = "󰀫",
	Class = "󰠱",
	Interface = "",
	Module = "",
	Property = "󰜢",
	Unit = "󰑭",
	Value = "󰎠",
	Enum = "",
	Keyword = "󰌋",
	Snippet = "",
	Color = "󰏘",
	File = "󰈙",
	Reference = "",
	Folder = "󰉋",
	EnumMember = "",
	Constant = "󰏿",
	Struct = "",
	Event = "",
	Operator = "󰆕",
	TypeParameter = " ",
	Misc = " ",
}
-- find more here: https://www.nerdfonts.com/cheat-sheet

function M.opts()
	-- local has_words_before = function()
	-- 	local col = vim.fn.col(".") - 1
	-- 	return col == 0 or vim.fn.getline("."):sub(col, col):match("%s")
	-- end
	-- local has_words_before = function()
	--   unpack = unpack or table.unpack
	--   local line, col = unpack(vim.api.nvim_win_get_cursor(0))
	--   return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
	-- end

	local cmp = require("cmp")
	local defaults = require("cmp.config.default")()
	-- local luasnip = require("luasnip")
	-- require("luasnip.loaders.from_vscode").lazy_load()

	return {

		completion = {
			competeopt = "menu,menuone,noinsert",
		},

		snippet = {
			expand = function(args)
				require("luasnip").lsp_expand(args.body) -- For `luasnip` users.
			end,
		},

		mapping = cmp.mapping.preset.insert({
			["<C-k>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),
			["<C-j>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
			["<C-b>"] = cmp.mapping.scroll_docs(-4),
			["<C-f>"] = cmp.mapping.scroll_docs(4),
			["<C-Space>"] = cmp.mapping.complete(),
			["<C-y>"] = cmp.config.disable, -- Specify `cmp.config.disable` if you want to remove the default `<C-y>` mapping.
			["<C-e>"] = cmp.mapping({
				i = cmp.mapping.abort(),
				c = cmp.mapping.close(),
			}),
			-- Accept currently selected item. If none selected, `select` first item.
			-- Set `select` to `false` to only confirm explicitly selected items.
			["<CR>"] = cmp.mapping.confirm({ select = true }),

			["<S-CR>"] = cmp.mapping.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = true }),
			--super tab
			-- ["<Tab>"] = cmp.mapping(function(fallback)
			-- 	if cmp.visible() then
			-- 		cmp.select_next_item()
			-- 	-- You could replace the expand_or_jumpable() calls with expand_or_locally_jumpable()
			-- 	-- they way you will only jump inside the snippet region
			-- 	elseif luasnip.expand_or_jumpable() then
			-- 		luasnip.expand_or_jump()
			-- 	elseif has_words_before() then
			-- 		cmp.complete()
			-- 	else
			-- 		fallback()
			-- 	end
			-- end, { "i", "s" }),
			-- ["<S-Tab>"] = cmp.mapping(function(fallback)
			-- 	if cmp.visible() then
			-- 		cmp.select_prev_item()
			-- 	elseif luasnip.jumpable(-1) then
			-- 		luasnip.jump(-1)
			-- 	else
			-- 		fallback()
			-- 	end
			-- end, { "i", "s" }),
		}),

		formatting = {
			fields = { "kind", "abbr", "menu" },
			format = function(entry, vim_item)
				-- Kind icons
				vim_item.kind = kind_icons[vim_item.kind]
				-- vim_item.kind = string.format('%s %s', kind_icons[vim_item.kind], vim_item.kind) -- This concatonates the icons with the name of the item kind
				vim_item.menu = ({
					nvim_lsp = "[LSP]",
					luasnip = "[LuaSnip]",
					buffer = "[Buf]",
					path = "[Path]",
				})[entry.source.name]
				return vim_item
			end,
		},

		sources = {
			{ name = "nvim_lsp" },
			{ name = "luasnip" },
			{ name = "buffer" },
			{ name = "path" },
		},

		confirm_opts = {
			behavior = cmp.ConfirmBehavior.Replace,
			select = false,
		},

		window = {
			completion = cmp.config.window.bordered(),
			documentation = cmp.config.window.bordered(),
			-- documentation = {
			-- 	border = { "╭", "─", "╮", "│", "╯", "─", "╰", "│" },
			-- },
		},

		experimental = {
			ghost_text = false,
			native_menu = false,
		},
		sorting = defaults.sorting,
	}
end

-- M.config = function()
-- 	if vim.o.ft == "clap_input" and vim.o.ft == "guihua" and vim.o.ft == "guihua_rust" then
-- 		require("cmp").setup.buffer({ completion = { enable = false } })
-- 	end
-- end

return M
