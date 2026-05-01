M = {
	"brenoprata10/nvim-highlight-colors",
	cond = function()
		return not require("user.utils").is_vscode()
	end,
	config = function()
		require("nvim-highlight-colors").setup({})
	end,
}

return M
