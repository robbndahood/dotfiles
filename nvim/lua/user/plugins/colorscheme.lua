local M = {
	"mhartington/oceanic-next",
	cond = function()
		return not require("user.utils").is_vscode()
	end,
	priority = 1000,
	lazy = false,
	init = function()
		vim.g.oceanic_next_terminal_italic = 1
		vim.g.oceanic_next_terminal_bold = 1
	end,
}

M.name = "OceanicNext"

function M.config()
	vim.cmd.colorscheme(M.name)
	vim.api.nvim_set_hl(0, "EndOfBuffer", { fg = "bg", ctermfg = 0 })
end

return M

-- vim.cmd([[
-- try
--   let g:oceanic_next_terminal_bold = 1
--   let g:oceanic_next_terminal_italic = 1
--   colorscheme OceanicNext
--   hi EndOfBuffer guifg=bg ctermfg=0
-- catch /^Vim\%((\a\+)\)\=:E185/
--   colorscheme default
--   set background=dark
-- endtry
-- ]])

-- loca
--
-- M.setup = function()
-- 	if vim.fn.exists("syntax_on") then
-- 		vim.cmd("syntax reset")
-- 	end
-- 	vim.o.termguicolors = true
--   vim.g.oceanic_next_terminal_bold = 1
--   vim.g.oceanic_next_terminal_italic = 1
-- 	set_namespace(namespace)
-- end
--
-- return M
-- nvim_set_hl(0, "EndOfBuffer", {'ctermfg': 0, 'fg'=bg})
--
-- local colorscheme = "OceanicNext"
-- local status_ok, _ = pcall(vim.cmd, "colorscheme " .. colorscheme)
-- if not status_ok then
--  vim.notify("colorscheme " .. colorscheme .. " not found!")
--  return
-- end
