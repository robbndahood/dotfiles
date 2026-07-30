return {
  { "nvim-lua/plenary.nvim", lazy = true },
  { "nvim-tree/nvim-web-devicons", opts = { default = false }, lazy = true },

  -- dot repeat
  { "tpope/vim-repeat", event = "VeryLazy" },

  -- highlight word under cursor
  {
    "RRethy/vim-illuminate",
    event = "VeryLazy",
    keys = {
      -- illuminate's defaults are <M-n>/<M-p>, which kitty doesn't send on macOS
      { "]r", function() require("illuminate").goto_next_reference() end, desc = "Next Reference" },
      { "[r", function() require("illuminate").goto_prev_reference() end, desc = "Prev Reference" },
    },
  },

}
