-- golang
return {
	"ray-x/go.nvim",
	cond = function()
		return not require("user.utils").is_vscode()
	end,
	dependencies = {
		"mfussenegger/nvim-dap", -- Debug Adapter Protocol
		"rcarriga/nvim-dap-ui",
		"theHamsta/nvim-dap-virtual-text",
		"ray-x/guihua.lua",
		"neovim/nvim-lspconfig",
		"nvim-treesitter/nvim-treesitter",
	},
	config = function()
		require("go").setup({
			lsp_cfg = {
				handlers = {
					["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { border = "double" }),
					["textDocument/signatureHelp"] = vim.lsp.with(
						vim.lsp.handlers.signature_help,
						{ border = "round" }
					),
				},
			},
		})
	end,
	event = { "CmdlineEnter" },
	ft = { "go", "gomod" },
	build = ':lua require("go.install").update_all_sync()',
}
