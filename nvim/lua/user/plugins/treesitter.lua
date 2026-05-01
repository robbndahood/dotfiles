local M = {
	"nvim-treesitter/nvim-treesitter",
	dependencies = {
		"JoosepAlviste/nvim-ts-context-commentstring",
		"nvim-treesitter/nvim-treesitter-textobjects",
	},
	lazy = false,
	build = ":TSUpdate",
	event = { "BufReadPost", "BufNewFile" },
	cmd = { "TSUpdateSync" },
}

M.opts = {
	ensure_installed = {
		"c",
		"bash",
		"go",
		"javascript",
		"json",
		"lua",
		"luadoc",
		"luap",
		"python",
		"regex",
		"toml",
		"vim",
		"vimdoc",
		"yaml",
		"markdown",
		"markdown_inline",
		"julia",
	},
	textobjects = {
		select = {
			lookahead = true,
			selection_modes = {
				["@parameter.outer"] = "v", -- charwise
				["@function.outer"] = "V", -- linewise
				["@class.outer"] = "<c-v>", -- blockwise
			},
			include_surrounding_whitespace = true,
		},
		move = {
			-- whether to set jumps in the jumplist
			set_jumps = true,
		},
	},
}

M.config = function(_, opts)
	-- Deduplicate and install parsers
	local added = {}
	local langs = vim.tbl_filter(function(lang)
		if added[lang] then
			return false
		end
		added[lang] = true
		return true
	end, opts.ensure_installed or {})
	if #langs > 0 then
		require("nvim-treesitter").install(langs)
	end

	-- Setup textobjects behaviour
	require("nvim-treesitter-textobjects").setup(opts.textobjects or {})

	-- Textobject keymaps (new explicit API)
	local sel = require("nvim-treesitter-textobjects.select")
	vim.keymap.set({ "x", "o" }, "af", function()
		sel.select_textobject("@function.outer", "textobjects")
	end, { desc = "Select outer function" })
	vim.keymap.set({ "x", "o" }, "if", function()
		sel.select_textobject("@function.inner", "textobjects")
	end, { desc = "Select inner function" })
	vim.keymap.set({ "x", "o" }, "ac", function()
		sel.select_textobject("@class.outer", "textobjects")
	end, { desc = "Select outer class" })
	vim.keymap.set({ "x", "o" }, "ic", function()
		sel.select_textobject("@class.inner", "textobjects")
	end, { desc = "Select inner class" })
end

return M
