return {
	"luukvbaal/statuscol.nvim",
	cond = function()
		return not require("user.utils").is_vscode()
	end,
	event = { "BufReadPre", "BufNewFile" },
	config = function()
		local builtin = require("statuscol.builtin")

		-- Take over 'statuscolumn' so git signs and diagnostics each get their own
		-- dedicated, fixed-width lane. With the stock signcolumn=yes:2 both sources
		-- share the sign column and are packed by priority, so a diagnostic and a
		-- git sign on the same line reflow past each other (the diagnostic "pushes"
		-- the git mark into the other cell). Separate segments pin them instead.
		--
		-- Layout, left -> right:  [fold] [diagnostics] [number] [git]
		require("statuscol").setup({
			segments = {
				-- Fold column (respects 'foldcolumn'; renders empty when it is 0).
				{ text = { builtin.foldfunc }, click = "v:lua.ScFa" },

				-- Diagnostics: own lane, to the left of the number.
				-- Neovim names the diagnostic sign namespace
				-- "nvim.<source>.diagnostic.signs"; the "." in the pattern is a Lua
				-- pattern wildcard that also matches those literal dots (statuscol
				-- matches namespaces with string.find). auto=false keeps the lane
				-- reserved even when no diagnostic is present, so nothing shifts.
				{
					sign = { namespace = { "diagnostic.signs" }, maxwidth = 1, colwidth = 1, auto = false },
					click = "v:lua.ScSa",
				},

				-- Line number.
				{ text = { builtin.lnumfunc, " " }, condition = { true, builtin.not_empty }, click = "v:lua.ScLa" },

				-- Gitsigns: own lane, immediately left of the buffer text (namespace
				-- "gitsigns_signs_", matched by the "gitsigns" pattern).
				{
					sign = { namespace = { "gitsigns" }, maxwidth = 1, colwidth = 1, auto = false },
					click = "v:lua.ScSa",
				},
				{ text = { "  " } },
			},
		})
	end,
}
