local M = {
  "akinsho/toggleterm.nvim",
  cond = function()
    return not require("user.utils").is_vscode()
  end,
  version = "*",
  cmd = "ToggleTerm",
}

M.opts = {
  function(term)
    if term.direction == "horizontal" then
      return 15
    elseif term.direction == "vertical" then
      return vim.o.columns * 0.4
    else
      return 20
    end
  end,
  open_mapping = [[<c-\>]],
  hide_numbers = true,
  shade_filetypes = {},
  shade_terminals = true,
  shading_factor = 2,
  start_in_insert = true,
  insert_mappings = true,
  persist_size = false,
  direction = "float",
  close_on_exit = true,
  shell = vim.o.shell,
  float_opts = {
    border = "curved",
    winblend = 3,
    highlights = {
      border = "Normal",
      background = "Normal",
    },
  },
}

function M.config(_, opts)
  local status_ok, toggleterm = pcall(require, "toggleterm")
  if not status_ok then
    print("toggle term exited on pcall")
    return
  end

  toggleterm.setup(opts)


  function _G.set_terminal_keymaps()
    local opts = { noremap = true, buffer = 0 }
    -- vim.api.nvim_buf_set_keymap(0, 't', '<esc>', [[<C-\><C-n>]], opts)
    -- vim.api.nvim_buf_set_keymap(0, 't', 'jk', [[<C-\><C-n>]], opts)
    vim.keymap.set("t", "<C-h>", [[<Cmd>wincmd h<CR>]], opts)
    vim.keymap.set("t", "<C-j>", [[<Cmd>wincmd j<CR>]], opts)
    vim.keymap.set("t", "<C-k>", [[<Cmd>wincmd k<CR>]], opts)
    vim.keymap.set("t", "<C-l>", [[<Cmd>wincmd l<CR>]], opts)
  end

  vim.cmd("autocmd! TermOpen term://* lua set_terminal_keymaps()")

  local Terminal = require("toggleterm.terminal").Terminal
  local lazygit = Terminal:new({ cmd = "lazygit", hidden = true })

  function _LAZYGIT_TOGGLE()
    lazygit:toggle()
  end

  -- local node = Terminal:new({ cmd = "node", hidden = true })
  --
  -- function _NODE_TOGGLE()
  -- 	node:toggle()
  -- end

  -- local ncdu = Terminal:new({ cmd = "ncdu", hidden = true })
  --
  -- function _NCDU_TOGGLE()
  -- 	ncdu:toggle()
  -- end

  local htop = Terminal:new({ cmd = "htop", hidden = true })

  function _HTOP_TOGGLE()
    htop:toggle()
  end

  local python = Terminal:new({ cmd = "python", hidden = true })

  function _PYTHON_TOGGLE()
    python:toggle()
  end

  local ipython = Terminal:new({ cmd = "ipython", hidden = true })

  function _IPYTHON_TOGGLE()
    ipython:toggle()
  end
end

return M
