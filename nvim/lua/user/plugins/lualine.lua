local M = {
  "nvim-lualine/lualine.nvim",
  cond = function()
    return not require("user.utils").is_vscode()
  end,
  dependencies = { "nvim-tree/nvim-web-devicons", lazy = true },
  event = "VeryLazy",
}

M.opts = {
  options = {
    icons_enabled = true,
    theme = "auto",
    component_separators = { left = "", right = "" },
    section_separators = { left = "", right = "" },
    disabled_filetypes = { "NvimTree" },
    always_divide_middle = true,
    globalstatus = true,
  },
  sections = {
    lualine_a = { "mode" },
    lualine_b = { "branch", "diff", "diagnostics" },
    lualine_c = { "filename" },
    lualine_x = { "encoding", "fileformat", "filetype" },
    lualine_y = { "progress" },
    lualine_z = { "location" },
  },
  inactive_sections = {
    lualine_a = {},
    lualine_b = {},
    lualine_c = { "filename" },
    lualine_x = { "location" },
    lualine_y = {},
    lualine_z = {},
  },
  -- tabline = {
  --   lualine_a = {'buffers'},
  --   lualine_b = {'branch'},
  --   lualine_c = {'filename'},
  --   lualine_x = {},
  --   lualine_y = {},
  --   lualine_z = {'tabs'}
  -- },
  tabline = {},
  extensions = { "nvim-tree", "fugitive", "toggleterm" },
}

return M
