M = {}

function M.lazy_setup()
	local fn = vim.fn
	local Util = require("user.utils")
	local is_vscode = Util.is_vscode()
	local lazypath = fn.stdpath("data") .. "/lazy/lazy.nvim"
	if not vim.loop.fs_stat(lazypath) then
		fn.system({
			"git",
			"clone",
			"--filter=blob:none",
			"https://github.com/folke/lazy.nvim.git",
			"--branch=stable", -- latest stable release
			lazypath,
		})
		if vim.v.shell_error ~= 0 then
			print("Error: Failed to close lazy.nvim")
			return
		end
	end
	vim.opt.rtp:prepend(lazypath)

	vim.g.mapleader = " "

	local lazy_opts = {
		-- defaults = { lazy = false },
		install = {
			colorscheme = is_vscode and {} or { require("user.plugins.colorscheme").name },
		},
		-- defaults = { lazy = true },
		ui = { wrap = "true" },
		change_detection = { enabled = true },
		performance = {
			rtp = {
				disabled_plugins = {},
			},
		},
	}

	require("lazy").setup("user.plugins", lazy_opts)
end

function M.setup()
	local safe_require = require("user.utils").safe_require
	local is_vscode = require("user.utils").is_vscode()
	safe_require("user.config.options")
	if not is_vscode then
		safe_require("user.config.keymaps")
	end
	if is_vscode then
		safe_require("user.config.vscode-keymaps")
	end
	M.lazy_setup()
end

return M
