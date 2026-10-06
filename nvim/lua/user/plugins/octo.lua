return {
	"pwntester/octo.nvim",
	cond = function()
		return not require("user.utils").is_vscode()
	end,
	cmd = "Octo",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-telescope/telescope.nvim",
		"nvim-tree/nvim-web-devicons",
	},
	keys = {
		{ "<leader>gop", "<cmd>Octo pr list<cr>", desc = "List PRs" },
		{ "<leader>goi", "<cmd>Octo issue list<cr>", desc = "List Issues" },
		{ "<leader>gos", "<cmd>Octo search<cr>", desc = "Search GitHub" },
	},
	opts = {
		picker = "telescope",
		enable_builtin = true,
	},
}
