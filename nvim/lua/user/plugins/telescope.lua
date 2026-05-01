local M = {
  'nvim-telescope/telescope.nvim',
  cond = function()
    local Util = require("user.utils")
    return (not Util.is_vscode()) or Util.vscode_plugin_enabled("telescope", false)
  end,
  dependencies = {
    'nvim-lua/popup.nvim',
    'nvim-lua/plenary.nvim',
    'lsp-trouble.nvim',
  },
  version = false,
  cmd = "Telescope",
  event = "BufEnter",
}

function M.config(_, opts)
  local telescope = require('telescope')
  local actions = require('telescope.actions')

  local opts = {
    defaults = {
      prompt_prefix = " ",
      selection_caret = " ",
      path_display = { "smart" },
      mappings = {
        i = {
          -- close telescope when you press escape
          ["<esc>"] = actions.close,
          ["<C-j>"] = actions.move_selection_next,
          ["<C-k>"] = actions.move_selection_previous,
          ["<Down>"] = actions.move_selection_next,
          ["<Up>"] = actions.move_selection_previous,
        },
      },
    },

    pickers = {

    },

    extensions = {
      fzf = {
        fuzzy = true,
        override_generic_sorter = true,
        override_file_sorter = true,
        case_mode = "smart_case",
      },

    },
  }

  telescope.setup(opts)
  -- load extensions
end

local extensions = {
  {
    'nvim-telescope/telescope-fzf-native.nvim',
    build = "make",
    dependencies = { "telescope.nvim" },
    config = function()
      require('telescope').load_extension('fzf')
    end,
  },
  {
    'nvim-telescope/telescope-dap.nvim',
    dependencies = {
      'telescope.nvim',
    },
    config = function()
      require('telescope').load_extension('dap')
    end,
  },
}

for _, ext in ipairs(extensions) do
  table.insert({ M }, ext)
end

return M
