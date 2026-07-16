-- lsp servers
local M = {}

-- This table only drives mason-lspconfig's ensure_installed (server keys ->
-- Mason packages). Under mason-lspconfig v2 the per-server option values here
-- are NOT applied; real per-server config lives in
-- lua/user/plugins/lsp/init.lua via vim.lsp.config().
M.servers = {
	jsonls = {},

	pyright = {},

	ruff = {},

	lua_ls = {},

	-- Ansible language server; attaches to the `yaml.ansible` filetype only.
	-- Ansible file detection lives in lua/user/config/filetypes.lua.
	ansiblels = {},

	-- Unified Docker LSP (Dockerfile + Compose + Bake). Replaces the older
	-- dockerls + docker-compose-language-service pair.
	docker_language_server = {},

	-- Markdown language server.
	marksman = {},

	clangd = {},

	bashls = {},

	yamlls = {},

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
