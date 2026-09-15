-- Oceanic Next — the Lua rewrite of the fork, installed like any other plugin.
-- This used to be a `dir = ...` pointing at the local working copy, which hard
-- coded a macOS home and left every other machine without a colorscheme.
local M = {
	"robbndahood/oceanic-next",
	name = "oceanic-next",
	cond = function()
		return not require("user.utils").is_vscode()
	end,
	priority = 1000,
	lazy = false,
}

-- The fork is now a proper Lua colorscheme with native `@*` treesitter and
-- `@lsp.*` semantic-token support, so the old `fix_treesitter_highlights`
-- monkeypatch is gone. Tweak colors here via setup() hooks instead.
function M.config()
	require("oceanic-next").setup({
		-- style = nil            -- follow &background (dark by default)
		transparent = false,
		borders = true, -- frame telescope panes + brighten the nvim-tree edge (false = borderless)
		styles = {
			comments = { italic = true },
			keywords = { italic = false },
		},
		rainbow_headings = true, -- markdown h1..h6 across the accent palette
	})
	vim.cmd.colorscheme("OceanicNext")
end

return M
