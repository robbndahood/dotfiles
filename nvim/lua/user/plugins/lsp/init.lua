local M = {

	-- Lspconfig
	{
		"neovim/nvim-lspconfig",
		cond = function()
			return not require("user.utils").is_vscode()
		end,
		event = { "BufReadPre" },
		lazy = true,
		dependencies = {
			-- { "folke/neoconf.nvim", cmd = "Neoconf", config = true },
			{ "folke/neodev.nvim", opts = {} },
			{ "williamboman/mason.nvim" },
			{ "williamboman/mason-lspconfig.nvim" },
			{ "hrsh7th/cmp-nvim-lsp" },
		},
		-- init = function()
		-- 	require("user.plugins.lsp.apple_codelm_ls")
		-- end,
		---@class PluginLspOpts
		opts = {
			diagnostics = {
				underline = true,
				update_in_insert = false,
				virtual_text = {
					spacing = 4,
					source = "if_many",
					prefix = "●",
				},
				severity_sort = true,
				float = {
					focusable = false,
					style = "minimal",
					border = "rounded",
					source = "always",
					header = "",
					prefix = "",
					suffix = "",
				},
			},
			-- Enable this to enable the builtin LSP inlay hints on Neovim >= 0.10.0
			-- Be aware that you also will need to properly configure your LSP server to
			-- provide the inlay hints.
			inlay_hints = {
				enabled = false,
			},
			-- global capabilities
			capabilities = {},
			autoformat = true,
			format_notify = true,
			setup = {},
			servers = {
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
				gopls = {},
			},
		},

		config = function(_, opts)
			local signs = {
				{ name = "DiagnosticSignError", text = "" },
				{ name = "DiagnosticSignWarn", text = "" },
				{ name = "DiagnosticSignHint", text = "" },
				{ name = "DiagnosticSignInfo", text = "" },
			}
			local Util = require("user.utils")
			require("user.plugins.lsp.format").setup(opts)

			-- setup formatting and keymaps
			Util.on_attach(function(client, buffer)
				-- require("user.plugins.lsp.apple_codelm_ls")
				require("user.plugins.lsp.keymaps").on_attach(client, buffer)
			end)
			local register_capability = vim.lsp.handlers["client/registerCapability"]

			vim.lsp.handlers["client/registerCapability"] = function(err, res, ctx)
				local ret = register_capability(err, res, ctx)
				local client_id = ctx.client_id
				---@type lsp.Client
				local client = vim.lsp.get_client_by_id(client_id)
				local buffer = vim.api.nvim_get_current_buf()
				require("user.plugins.lsp.keymaps").on_attach(client, buffer)
				return ret
			end

			for _, sign in ipairs(signs) do
				vim.fn.sign_define(sign.name, { texthl = sign.name, text = sign.text, numhl = "" })
			end

			local inlay_hint = vim.lsp.buf.inlay_hint or vim.lsp.inlay_hint

			if opts.inlay_hints.enabled and inlay_hint then
				Util.on_attach(function(client, buffer)
					if client.server_capabilities.inlayHintProvider then
						inlay_hint(buffer, true)
					end
				end)
			end

			if type(opts.diagnostics.virtual_text) == "table" and opts.diagnostics.virtual_text.prefix == "icons" then
				opts.diagnostics.virtual_text.prefix = vim.fn.has("nvim-0.10.0") == 0 and "●"
					or function(diagnostic)
						local icons = signs
						for d, icon in pairs(icons) do
							if diagnostic.severity == vim.diagnostic.severity[d:upper()] then
								return icon
							end
						end
					end
			end

			vim.diagnostic.config(vim.deepcopy(opts.diagnostics))

			local servers = opts.servers
			local capabilities = vim.tbl_deep_extend(
				"force",
				{},
				vim.lsp.protocol.make_client_capabilities(),
				require("cmp_nvim_lsp").default_capabilities(),
				opts.capabilities or {}
			)

			local function setup(server)
				local server_opts = vim.tbl_deep_extend("force", {
					capabilities = vim.deepcopy(capabilities),
				}, servers[server] or {})

				if opts.setup[server] then
					if opts.setup[server](server, server_opts) then
						return
					end
				elseif opts.setup["*"] then
					if opts.setup["*"](server, server_opts) then
						return
					end
				end
				require("lspconfig")[server].setup(server_opts)
			end

			-- get all the servers that are available thourgh mason-lspconfig
			local have_mason, mlsp = pcall(require, "mason-lspconfig")
			local all_mslp_servers = {}
			if have_mason then
				all_mslp_servers = mlsp.get_available_servers()
			end

			local ensure_installed = {} ---@type string[]
			for server, server_opts in pairs(servers) do
				if server_opts then
					server_opts = server_opts == true and {} or server_opts
					-- run manual setup if mason=false or if this is a server that cannot be installed with mason-lspconfig
					if server_opts.mason == false or not vim.tbl_contains(all_mslp_servers, server) then
						setup(server)
					else
						ensure_installed[#ensure_installed + 1] = server
					end
				end
			end

			if have_mason then
				mlsp.setup({ ensure_installed = ensure_installed, handlers = { setup } })
			end

			if Util.lsp_get_config("denols") and Util.lsp_get_config("tsserver") then
				local is_deno = require("lspconfig.util").root_pattern("deno.json", "deno.jsonc")
				Util.lsp_disable("tsserver", is_deno)
				Util.lsp_disable("denols", function(root_dir)
					return not is_deno(root_dir)
				end)
			end
		end,
	},

	-- Mason
	{
		"williamboman/mason.nvim",
		cond = function()
			return not require("user.utils").is_vscode()
		end,
		cmd = "Mason",
		opts = {
			ui = {
				border = "none",
				icons = {
					package_installed = "◍",
					package_pending = "◍",
					package_uninstalled = "◍",
				},
			},
			log_level = vim.log.levels.INFO,
			max_concurrent_installers = 4,
		},
		config = function(_, opts)
			-- faster startup
			require("mason").setup(opts)
		end,
	},

	-- Mason LspConfig
	{
		"williamboman/mason-lspconfig.nvim",
		cond = function()
			return not require("user.utils").is_vscode()
		end,
		dependencies = {
			"williamboman/mason.nvim",
			"hrsh7th/cmp-nvim-lsp",
		},
		lazy = true,
		opts = {
			ensure_installed = vim.tbl_keys(require("user.settings.lsp").servers),
			automatic_installation = true,
		},
	},

	-- null-ls
	{
		"nvimtools/none-ls.nvim",
		cond = function()
			return not require("user.utils").is_vscode()
		end,
		dependencies = {
			"nvim-lua/plenary.nvim",
			"williamboman/mason.nvim",
		},
		event = { "BufReadPre", "BufNewFile" },
		opts = function()
			local nls = require("null-ls")
			return {
				root_dir = require("null-ls.utils").root_pattern(".null-ls-root", ".git", "pyproject.toml"),
				sources = {
					nls.builtins.formatting.prettier.with({
						extra_filetypes = { "toml" },
						extra_args = { "--no-semi", "--single-quote", "--jsx-single-quote" },
					}),

					nls.builtins.formatting.black.with({ extra_args = { "--fast" }, prefer_local = true }),
					nls.builtins.formatting.stylua,
					nls.builtins.completion.luasnip,
					nls.builtins.code_actions.gitsigns,
					nls.builtins.diagnostics.revive,
					nls.builtins.formatting.golines.with({
						extra_args = {
							"--max-len=180",
							"--base-formatter=gofumpt",
						},
					}),
				},
			}
		end,
		config = function(plugin, _)
			local nls = require("null-ls")
			local sources = plugin.opts().sources
			local gotest = require("go.null_ls").gotest()
			local gotest_codeaction = require("go.null_ls").gotest_action()
			local golangci_lint = require("go.null_ls").golangci_lint()
			table.insert(sources, gotest)
			table.insert(sources, golangci_lint)
			table.insert(sources, gotest_codeaction)
			nls.setup({ sources = sources, debounce = 1000, default_timeout = 5000 })
		end,
	},

	-- cmdline tools and lsp servers
	{

		"williamboman/mason.nvim",
		cond = function()
			return not require("user.utils").is_vscode()
		end,
		cmd = "Mason",
		keys = { { "<leader>cm", "<cmd>Mason<cr>", desc = "Mason" } },
		opts = {
			ensure_installed = {
				"stylua",
				"shfmt",
				"revive", -- Go linter used by null-ls (nls.builtins.diagnostics.revive)
				-- "flake8",
			},
		},
		---@param opts MasonSettings | {ensure_installed: string[]}
		config = function(_, opts)
			require("mason").setup(opts)
			local mr = require("mason-registry")
			local function ensure_installed()
				for _, tool in ipairs(opts.ensure_installed) do
					local p = mr.get_package(tool)
					if not p:is_installed() then
						p:install()
					end
				end
			end
			if mr.refresh then
				mr.refresh(ensure_installed)
			else
				ensure_installed()
			end
		end,
	},
}

-- require("user.plugins.lsp.apple_codelm_ls")

return M
