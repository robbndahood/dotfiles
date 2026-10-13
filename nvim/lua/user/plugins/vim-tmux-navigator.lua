-- <C-h/j/k/l> across nvim splits and tmux panes as one grid. The tmux half
-- lives in tmux/.tmux.conf; outside tmux, vim-kitty-navigator does this job.
return {
	"christoomey/vim-tmux-navigator",
	lazy = false,
	cond = function()
		return not require("user.utils").is_vscode() and vim.env.TMUX ~= nil
	end,
	init = function()
		-- The default maps include <C-\>, which is toggleterm's.
		vim.g.tmux_navigator_no_mappings = 1
		-- Stop at the outer edge instead of wrapping, like kitty's
		-- neighboring_window.
		vim.g.tmux_navigator_no_wrap = 1
		-- Don't unzoom a zoomed nvim pane by walking off the edge.
		vim.g.tmux_navigator_disable_when_zoomed = 1
	end,
	config = function()
		local opts = { silent = true }
		vim.keymap.set("n", "<C-h>", "<Cmd>TmuxNavigateLeft<CR>", opts)
		vim.keymap.set("n", "<C-j>", "<Cmd>TmuxNavigateDown<CR>", opts)
		vim.keymap.set("n", "<C-k>", "<Cmd>TmuxNavigateUp<CR>", opts)
		vim.keymap.set("n", "<C-l>", "<Cmd>TmuxNavigateRight<CR>", opts)
	end,
}
