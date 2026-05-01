return {
	"folke/lsp-trouble.nvim",
	cond = function()
		return not require("user.utils").is_vscode()
	end,
	dependencies = "nvim-tree/nvim-web-devicons",
	opts = {
		action_keys = {
			previous = "e",
			next = "n",
		},
		auto_open = false,
		auto_close = false,
		use_diagnostic_signs = true,
	},
}
