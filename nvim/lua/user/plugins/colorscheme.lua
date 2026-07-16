-- Oceanic Next — loaded from the local fork while it's under active development.
-- TODO: once the Lua rewrite is pushed, switch `dir = ...` back to
--   "robbndahood/oceanic-next" (a normal remote plugin spec) so it installs like
--   any other plugin instead of pointing at this working copy.
local M = {
	dir = "/Users/robert.leon/code/repos/github.com/robbndahood/oceanic-next",
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
		styles = {
			comments = { italic = true },
			keywords = { italic = false },
		},
		rainbow_headings = true, -- markdown h1..h6 across the accent palette
	})
	vim.cmd.colorscheme("OceanicNext")
end

return M
