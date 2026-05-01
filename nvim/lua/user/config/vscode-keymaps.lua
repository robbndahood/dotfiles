local keymap = vim.keymap.set

local opts = { noremap = true, silent = true }

local is_vscode = require("user.utils").is_vscode()

local vscode
if is_vscode then
	local ok, vscode_module = pcall(require, "vscode")
	if ok then
		vscode = vscode_module
	end
end

keymap("", "<Space>", "<Nop>", opts)
vim.g.mapleader = " "

--Save
keymap("n", "<leader>w", function()
	vscode.action("workbench.action.files.save")
end, opts)

keymap("n", "<C-h>", function()
	vscode.action("workbench.action.focusLeftGroup")
end, opts)
keymap("n", "<C-l>", function()
	vscode.action("workbench.action.focusRightGroup")
end, opts)
keymap("n", "<C-j>", function()
	vscode.action("workbench.action.focusBelowGroup")
end, opts)
keymap("n", "<C-k>", function()
	vscode.action("workbench.action.focusAboveGroup")
end, opts)

keymap("n", "<leader>ff", function()
	vscode.action("workbench.action.quickOpen")
end, opts)
keymap("n", "<leader>fg", function()
	vscode.action("workbench.action.findInFiles")
end, opts)
keymap("n", "<leader>fb", function()
	vscode.action("workbench.action.showAllEditorsByMostRecentlyUsed")
end, opts)
keymap("n", "<leader>fh", function()
	vscode.action("workbench.action.showCommands")
end, opts)

-- keymap("n", "<leader>e", function()
-- 	vscode.action("workbench.view.explorer")
-- end, opts)

keymap("n", "<leader>e", function()
	vscode.action("workbench.action.toggleSidebarVisibility")
end, opts)

keymap("n", "<S-l>", function()
	vscode.action("workbench.action.nextEditor")
end, opts)

keymap("n", "<S-h>", function()
	vscode.action("workbench.action.previousEditor")
end, opts)
