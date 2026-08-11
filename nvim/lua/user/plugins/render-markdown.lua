-- In-buffer markdown preview: restyles headings, code blocks, tables, lists and
-- callouts in place instead of opening a browser or a second window.
--
-- It starts off (`enabled = false`) and is bound to `<leader>tm`, so markdown
-- files still open as plain text and preview is something you switch on. Flip
-- `enabled` to true below to render every markdown buffer by default.
--
-- Icons are Nerd Font glyphs; kitty gets those from CoreText fallback, so the
-- base `font_family` stays plain Fira Code (see kitty/kitty.conf).
local M = {
	"MeanderingProgrammer/render-markdown.nvim",
	ft = { "markdown" },
	dependencies = {
		"nvim-treesitter/nvim-treesitter",
		"nvim-tree/nvim-web-devicons",
	},
	-- VSCode renders its own markdown preview.
	cond = function()
		return not require("user.utils").is_vscode()
	end,
	keys = {
		{
			"<leader>tm",
			function()
				require("render-markdown").toggle()
			end,
			desc = "Toggle [M]arkdown Preview",
		},
	},
}

M.opts = {
	-- Preview is opt-in; `<leader>tm` turns it on.
	enabled = false,
	-- Raw text comes back on the cursor line so the buffer stays editable.
	anti_conceal = { enabled = true },
	heading = {
		-- statuscol owns the sign column; keep headings out of it.
		sign = false,
		-- Icon sits in the line rather than shifting text into the gutter.
		position = "inline",
	},
	code = {
		sign = false,
		-- Full-width bordered block with the language name in the top border.
		width = "block",
		min_width = 60,
		right_pad = 2,
		border = "thick",
		language_name = true,
	},
	-- Needs the `latex` treesitter parser plus latex2text/utftex, none of which
	-- are installed -- off to avoid the startup warning.
	latex = { enabled = false },
}

return M
