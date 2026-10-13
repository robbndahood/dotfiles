return {
	"knubie/vim-kitty-navigator",
	-- Inside tmux the neighbor of an nvim split is a tmux pane, not a kitty
	-- window, so vim-tmux-navigator takes over there.
	cond = function()
		return not require("user.utils").is_vscode() and vim.env.TMUX == nil
	end,
}
