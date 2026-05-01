local M = {
	"windwp/nvim-autopairs",
	cond = function()
		return not require("user.utils").is_vscode()
	end,
}

M.opts = {
	check_ts = true,
	disable_filetype = { "TelescopePrompt", "guihua", "guihua_rust" },
	--[[ enable_check_bracket_line = false, -- ignored if next char is a close pair and it doesn't have an open pair in same line ]]
	--[[ ignored_next_char = "[%w%.]", -- ignores if the next char is alphanumeric ]]
	ts_config = {
		lua = { "string", "source" },
		javascript = { "string", "template_string" },
		java = false,
	},
	fast_wrap = {
		map = "<M-e>",
		chars = { "{", "[", "(", '"', "'" },
		pattern = string.gsub([[ [%'%"%)%>%]%)%}%,] ]], "%s+", ""),
		offset = 0, -- Offset from pattern match
		end_key = "$",
		keys = "qwertyuiopzxcvbnmasdfghjkl",
		check_comma = true,
		highlight = "PmenuSel",
		highlight_grey = "LineNr",
	},
}

M.dependencies = {

	"hrsh7th/nvim-cmp",
}

M.config = function(_, opts)
	local autopairs = require("nvim-autopairs")
	autopairs.setup(opts)
	local cmp_autopairs = require("nvim-autopairs.completion.cmp")
	local cmp_status_ok, cmp = pcall(require, "cmp")
	if not cmp_status_ok then
		print("nvim-cmp not set up before autopairs")
		return
	end
	cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
end

return M
