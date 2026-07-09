-- :help options

-- disable default file tree
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

local options = {
	clipboard = "unnamedplus",                    -- allows neovim to access the system clipboard
	completeopt = { "menu", "menuone", "noselect" }, -- completion menu options
	conceallevel = 0,                             -- (``) shown in markdown files
	hlsearch = true,                              -- highlight all matches of previous search pattern
	ignorecase = true,                            -- ignore case in search patterns
	smartcase = true,                             -- smart case
	smartindent = true,                           -- auto inserts indents
	splitbelow = true,                            -- sp below
	splitright = true,                            -- vsp right

	-- recommended by kitty
	mouse = "a", -- allows mouse to be used in all modes
	-- ttymouse = "sgr",
	-- balloonevalterm = true,

	showtabline = 2,     -- 0: never, 1: sometimes, 2: always show tabline at top
	cmdheight = 2,       -- vim command area height
	showmode = false,    -- see vim mode insert etc.
	timeout = true,
	timeoutlen = 500,    -- time to wait for mapped sequence to complete
	swapfile = false,    -- create swapfile
	undofile = true,     -- persistent undo
	updatetime = 300,    -- faster completion
	backup = false,      -- creates a backup file
	writebackup = false, -- make a backup before overwriting a file
	expandtab = true,    -- convert tabs to spaces
	shiftwidth = 2,      -- number of spaces for indents
	tabstop = 2,         -- number of spaces for tab
	cursorline = true,   -- highlight cursorline
	number = true,       -- numbers on the right
	numberwidth = 4,     -- set number column width
	relativenumber = false, -- relative numbers
	signcolumn = "yes:2", -- always show sign column
	wrap = false,        -- don't wrap lines
	linebreak = false,
	scrolloff = 8,
	sidescrolloff = 8,
	termguicolors = true,
	winborder = "rounded",                        -- global float border (replaces removed vim.lsp.with(..., {border=...}))
}

for k, v in pairs(options) do
	vim.opt[k] = v
end

vim.opt.shortmess:append("c")
vim.opt.iskeyword:append("-")
vim.opt.formatoptions:remove({ "c", "r", "o" })
vim.g.python3_host_prog = "$HOME/.pyenv/versions/py3nvim/bin/python"
vim.g.loaded_python_provider = 0
vim.cmd("set whichwrap+=<,>,[,],h,l")

-- kitty recommended options" --
-- Styled and colored underline support
if not require("user.utils").is_vscode() then
	vim.cmd([[let &t_AU = "\e[58:5:%dm"]])
	vim.cmd([[let &t_8u = "\e[58:2:%lu:%lu:%lum"]])
	vim.cmd([[let &t_Us = "\e[4:2m"]])
	vim.cmd([[let &t_Cs = "\e[4:3m"]])
	vim.cmd([[let &t_ds = "\e[4:4m"]])
	vim.cmd([[let &t_Ds = "\e[4:5m"]])
	vim.cmd([[let &t_Ce = "\e[4:0m"]])
	vim.cmd([[let &t_Ts = "\e[9m"]])
	vim.cmd([[let &t_Te = "\e[29m"]])
	vim.cmd([[let &t_8f = "\e[38:2:%lu:%lu:%lum"]])
	vim.cmd([[let &t_8b = "\e[48:2:%lu:%lu:%lum"]])
	vim.cmd([[let &t_RF = "\e]10;?\e\\"]])
	vim.cmd([[let &t_RB = "\e]11;?\e\\"]])
	vim.cmd([[let &t_BE = "\e[?2004h"]])
	vim.cmd([[let &t_BD = "\e[?2004l"]])
	vim.cmd([[let &t_PS = "\e[200~"]])
	vim.cmd([[let &t_PE = "\e[201~"]])
	vim.cmd([[let &t_RC = "\e[?12$p"]])
	vim.cmd([[let &t_SH = "\e[%d q"]])
	vim.cmd([[let &t_RS = "\eP$q q\e\\"]])
	vim.cmd([[let &t_SI = "\e[5 q"]])
	vim.cmd([[let &t_SR = "\e[3 q"]])
	vim.cmd([[let &t_EI = "\e[1 q"]])
	vim.cmd([[let &t_VS = "\e[?12l"]])
	vim.cmd([[let &t_fe = "\e[?1004h"]])
	vim.cmd([[let &t_fd = "\e[?1004l"]])
	vim.cmd([[let &t_ST = "\e[22;2t"]])
	vim.cmd([[let &t_RT = "\e[23;2t"]])
	vim.cmd([[let &t_ut='']])
end
-- vim.cmd([[set iskeyword+=-]])
--
--
-- vim.cmd("let g:python3_host_prog = '$HOME/.pyenv/versions/py3nvim/bin/python'")
-- vim.cmd("let g:loaded_python_provider = 0")
-- vim.cmd("let &t_ut=''") -- get around bce
-- local setPath = function()
-- 	if gitBranch() ~= "" then
-- 		return ".,"
-- 			.. table.concat(vim.fn.systemlist("fd . --type d --hidden -E .git -E .yarn"), ","):gsub("%./", "")
-- 			.. ","
-- 			.. table.concat(vim.fn.systemlist("fd --type f --max-depth 1"), ","):gsub("%./", "") -- grab both the dirs and the top level filesystem
-- 	else
-- 		return vim.o.path
-- 	end
-- end

-- vim.o.path = setPath()
