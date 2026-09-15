-- golang
return {
	"ray-x/go.nvim",
	-- Gated on the toolchain: go.nvim loads on CmdlineEnter, and its setup()
	-- runs go.install, which aborts with "'go' is not executable" when there's
	-- no Go. That broke every `:` command on a machine without it.
	cond = function()
		return not require("user.utils").is_vscode() and vim.fn.executable("go") == 1
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
		-- vim.lsp.with() and vim.lsp.handlers.* overrides were removed in Nvim 0.11+.
		-- Float borders now come from the global `winborder` option (see options.lua).
		require("go").setup({
			lsp_cfg = true,
		})
	end,
	event = { "CmdlineEnter" },
	ft = { "go", "gomod" },
	build = ':lua require("go.install").update_all_sync()',
}
