M = {
	"tpope/vim-fugitive",
	cond = function()
		return not require("user.utils").is_vscode()
	end,
	cmd = { "G", "Git", "Gdiffsplit", "Gread", "Gwrite", "Ggrep", "GMove", "GDelete", "GBrowse" },
	keys = {
		{ "<leader>gs", "<cmd>Git<cr>", desc = "Git Status" },
	},
}

return M
