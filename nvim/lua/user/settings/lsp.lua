-- lsp servers
local M = {}

M.servers = {
	jsonls = {},

	pyright = {},

	lua_ls = {
		settings = {
			Lua = {
				telemetry = {
					enable = false,
				},
				workspace = {
					checkThirdParty = false,
				},
				completion = {
					callSnippet = "Replace",
				},
			},
		},
	},

	clangd = {},

	bashls = {},

	yamlls = {},

	dockerls = {},

	html = {},

	sqlls = {},

	taplo = {},

	--	gopls = function()
	--		return require("go.pls").config()
	--	end,
	gopls = {},
}

M.setup = {}

return M
