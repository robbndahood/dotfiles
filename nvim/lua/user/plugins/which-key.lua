local M = {
  "folke/which-key.nvim",
  event = "VeryLazy",
  cond = function()
    return not require("user.utils").is_vscode()
  end
}
M.opts = {}

function M.config(_, opts)
  local wk = require("which-key")
  wk.setup(opts)

  -- Register keybindings (only loaded when NOT in VSCode)
  if wk.add then
    wk.add({
      { "<leader>f",  group = "Find" },
      { "<leader>g",  group = "Git" },
      { "<leader>c",  group = "Code" },
      { "<leader>t",  group = "Toggle" },
      { "<leader>ff", desc = "Find Files" },
      { "<leader>fg", desc = "Find String" },
      { "<leader>fb", desc = "Find Buffers" },
      { "<leader>fh", desc = "Find Help Tags" },
      { "<leader>e",  desc = "File Tree" },
    })
  elseif wk.register then
    wk.register({
      ["<leader>f"] = { name = "+Find" },
      ["<leader>g"] = { name = "+Git" },
      ["<leader>c"] = { name = "+Code" },
      ["<leader>t"] = { name = "+Toggle" },
      ["<leader>ff"] = { "Find Files" },
      ["<leader>fg"] = { "Find String" },
      ["<leader>fb"] = { "Find Buffers" },
      ["<leader>fh"] = { "Find Help Tags" },
      ["<leader>e"] = { "File Tree" },
    })
  end
end

return M
