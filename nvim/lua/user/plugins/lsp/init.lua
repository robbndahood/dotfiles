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
				-- NOTE: under mason-lspconfig v2 every INSTALLED server is
				-- auto-enabled via vim.lsp.enable() and this file's classic
				-- per-server `setup` handler is ignored. So this table only drives
				-- ensure_installed; per-server *options* must be registered with
				-- vim.lsp.config() in config() below to actually reach the server.
				jsonls = {},
				pyright = {}, -- options in config() below (venv + disableOrganizeImports)
				ruff = {}, -- options in config() below (hover off, organize imports)
				lua_ls = {}, -- options in config() below
				ansiblels = {}, -- Ansible YAML (yaml.ansible filetype; see config/filetypes.lua)
				docker_language_server = {}, -- unified Docker LSP: Dockerfile + compose + bake
				marksman = {}, -- Markdown
				clangd = {},
				bashls = {},
				yamlls = {},
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

			-- lua_ls: settings must be registered via vim.lsp.config too (same
			-- mason-lspconfig v2 reason as pyright/ruff below).
			vim.lsp.config("lua_ls", {
				settings = {
					Lua = {
						telemetry = { enable = false },
						workspace = { checkThirdParty = false },
						completion = { callSnippet = "Replace" },
						diagnostics = {
							globals = { "vim" },
						},
					},
				},
			})

			-- Python: ruff (lint + format + imports) alongside pyright (types).
			-- mason-lspconfig v2 enables servers with vim.lsp.enable(), which reads
			-- vim.lsp.config(); the classic per-server setup handler is ignored, so
			-- these options MUST be registered here to actually reach the servers.
			vim.lsp.config("pyright", {
				settings = {
					pyright = {
						-- Let ruff organize imports instead of pyright.
						disableOrganizeImports = true,
					},
				},
				before_init = function(_, config)
					-- Point pyright at the project's own .venv so it resolves
					-- locally-installed packages (yoshi, yoshi_tests, ...). Without
					-- this pyright uses the global python on PATH, which has none of
					-- them. root_dir resolves to the project root via lspconfig's
					-- markers (pyproject.toml/.git), so each project gets its own venv.
					local root = config.root_dir
					if root then
						local venv_py = root .. "/.venv/bin/python"
						if vim.uv.fs_stat(venv_py) then
							config.settings = config.settings or {}
							config.settings.python = config.settings.python or {}
							config.settings.python.pythonPath = venv_py
						end
					end
				end,
			})
			vim.lsp.config("ruff", {
				on_attach = function(client, bufnr)
					-- pyright owns hover; ruff's hover is intentionally minimal.
					client.server_capabilities.hoverProvider = false

					-- Organize imports on save (ruff's formatter does not reorder
					-- imports). Guarded by the autoformat toggle (<leader>ct) and
					-- pcall-wrapped so an LSP API change can never hard-error on write.
					vim.api.nvim_create_autocmd("BufWritePre", {
						group = vim.api.nvim_create_augroup("RuffOrganizeImports." .. bufnr, { clear = true }),
						buffer = bufnr,
						callback = function()
							if not require("user.plugins.lsp.format").autoformat then
								return
							end
							pcall(function()
								local enc = client.offset_encoding
								local params = vim.lsp.util.make_range_params(0, enc)
								params.context = { only = { "source.organizeImports.ruff" }, diagnostics = {} }
								local resp = client:request_sync("textDocument/codeAction", params, 1000, bufnr)
								for _, action in pairs((resp and resp.result) or {}) do
									-- ruff returns organizeImports lazily (no inline
									-- edit), so resolve it before applying.
									if not action.edit and action.data then
										local r = client:request_sync("codeAction/resolve", action, 1000, bufnr)
										action = (r and r.result) or action
									end
									if action.edit then
										vim.lsp.util.apply_workspace_edit(action.edit, enc)
									elseif type(action.command) == "table" then
										client:exec_cmd(action.command, { bufnr = bufnr })
									end
								end
							end)
						end,
					})
				end,
			})

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

					-- Python formatting is handled by ruff's LSP (see the `ruff`
					-- server config above). Black is intentionally not a null-ls
					-- source: format.lua prefers null-ls formatters, so keeping
					-- black here would shadow ruff's formatter for Python.
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
