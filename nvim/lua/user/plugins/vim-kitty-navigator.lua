return {
	"knubie/vim-kitty-navigator",
	cond = function()
		return not require("user.utils").is_vscode()
	end,
}
