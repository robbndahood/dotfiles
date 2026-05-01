local M = {
  "ahmedkhalf/project.nvim",
  cond = function()
    local Util = require("user.utils")
    return (not Util.is_vscode()) or Util.vscode_plugin_enabled("telescope", false)
  end,
  dependencies = { "nvim-telescope/telescope.nvim" },
}

M.opts = {
  active = true,
  on_config_done = nil,
  -- Manual mode doesn't automatically change your root directory, so you have
  -- the option to manually do so using `:ProjectRoot` command.
  manual_mode = false,

  -- Methods of detecting the root directory. **"lsp"** uses the native neovim
  -- lsp, while **"pattern"** uses vim-rooter like glob pattern matching. Here
  -- order matters: if one is not detected, the other is used as fallback. You
  -- can also delete or rearangne the detection methods.
  detection_methods = { "lsp", "pattern" },

  -- All the patterns used to detect root dir, when **"pattern"** is in
  -- detection_methods
  patterns = {
    ".git",
    "pyproject.toml",
    "init.lua",
    ".python-version",
    "_darcs",
    ".hg",
    ".bzr",
    ".svn",
    "Makefile",
    "package.json",
  },

  -- Table of lsp clients to ignore by name
  -- eg: { "efm", ... }
  ignore_lsp = {},

  -- Don't calculate root dir on specific directories
  -- Ex: { "~/.cargo/*", ... }
  exclude_dirs = {},

  -- Show hidden files in telescope
  show_hidden = false,

  -- When set to false, you will get a message when project.nvim changes your
  -- directory.
  silent_chdir = true,

  -- Path where project.nvim will store the project history for use in
  -- telescope
  datapath = vim.fn.stdpath("data"),
}

-- M.init = function()
--   local tele_status_ok, telescope = pcall(require, "telescope")
--   if not tele_status_ok then
--     return
--   end
--
--   telescope.load_extension("projects")
-- end

M.config = function(_, opts)
  require("project_nvim").setup(opts)
  require("telescope").load_extension("projects")
end

return M
