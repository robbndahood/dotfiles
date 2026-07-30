-- DrKJeff16/project.nvim: actively maintained fork of the (unmaintained)
-- ahmedkhalf/project.nvim. The original called vim.lsp.buf_get_clients(), which
-- was removed in Nvim 0.11+, crashing on VimEnter. This fork uses the current
-- LSP API. Requires Nvim >= 0.11 and `fd` (both present).
--
-- Config schema differs from the original:
--   detection_methods -> lsp = { enabled = ... } + patterns (pattern fallback)
--   ignore_lsp        -> lsp.ignore
--   datapath          -> history.save_dir
-- Module is now require("project") (was require("project_nvim")).
local M = {
  "DrKJeff16/project.nvim",
  cond = function()
    local Util = require("user.utils")
    return (not Util.is_vscode()) or Util.vscode_plugin_enabled("telescope", false)
  end,
  dependencies = { "nvim-telescope/telescope.nvim" },
}

M.opts = {
  -- Manual mode doesn't automatically change your root directory, so you have
  -- the option to manually do so using `:Project root` instead.
  manual_mode = false,

  -- LSP-based detection with pattern matching as a fallback (no_fallback = false),
  -- mirroring the old detection_methods = { "lsp", "pattern" } order.
  lsp = {
    enabled = true,
    ignore = {}, -- lsp clients to ignore by name, e.g. { "efm" }
    no_fallback = false, -- fall back to `patterns` when no LSP root is found
    use_pattern_matching = false, -- don't double-check LSP roots against patterns
  },

  -- Fallback root patterns (used when LSP detection finds nothing).
  patterns = {
    ".git",
    ".github",
    "_darcs",
    ".hg",
    ".bzr",
    ".svn",
    "Pipfile",
    "pyproject.toml",
    ".python-version",
    "package.json",
    "Makefile",
    "init.lua",
    ".pre-commit-config.yaml",
    ".pre-commit-config.yml",
    ".csproj",
    ".sln",
    ".nvim.lua",
    ".neoconf.json",
    "neoconf.json",
  },

  -- Don't calculate root dir on specific directories, e.g. { "~/.cargo/*" }
  exclude_dirs = {},

  -- Show hidden files in the telescope picker
  show_hidden = false,

  -- When false, you get a message when project.nvim changes your directory.
  silent_chdir = true,

  -- Change directory globally (matches the original plugin's behaviour).
  scope_chdir = "global",
}

M.config = function(_, opts)
  require("project").setup(opts)
  require("telescope").load_extension("projects")

  -- Work around a project.nvim race. The history file is one global JSON shared
  -- by every nvim instance, and write_history() truncates-then-writes it
  -- non-atomically. A second instance reading in that window sees an empty file
  -- and write_history raises "Unable to decode JSON data!" -- either out of a
  -- vim.schedule callback or synchronously in the BufEnter autocmd chain.
  -- read_history already tolerates this; only write_history re-raises. Swallow
  -- that one transient error and retry once; re-raise anything else.
  local history = require("project.util.history")
  local orig_write = history.write_history
  history.write_history = function(path)
    local ok, err = pcall(orig_write, path)
    if not ok then
      if type(err) == "string" and err:find("decode JSON", 1, true) then
        vim.defer_fn(function() pcall(orig_write, path) end, 50)
      else
        error(err)
      end
    end
  end
end

return M
