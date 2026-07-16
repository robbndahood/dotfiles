-- Shorten function name
local keymap = vim.keymap.set
-- local keymap_term = vim.api.nvim_set_keymap
local opts = { noremap = true, silent = true }

-- Modes
--   normal_mode = "n",
--   insert_mode = "i",
--   visual_mode = "v",
--   visual_block_mode = "x",
--   term_mode = "t",
--   command_mode = "c",

-- Remap leader key
keymap("", "<Space>", "<Nop>", opts)
vim.g.mapleader = " "

-- Normal --

--Save
keymap("n", "<leader>w", "<cmd>w<cr>", opts)

-- Better window navigation
keymap("n", "<C-h>", "<C-w>h", opts)
keymap("n", "<C-j>", "<C-w>j", opts)
keymap("n", "<C-k>", "<C-w>k", opts)
keymap("n", "<C-l>", "<C-w>l", opts)

-- Resize with arrows
keymap("n", "<C-Up>", "<Cmd>resize +2<CR>", opts)
keymap("n", "<C-Down>", "<Cmd>resize -2<CR>", opts)
keymap("n", "<C-Left>", "<Cmd>vertical resize -2<CR>", opts)
keymap("n", "<C-Right>", "<Cmd>vertical resize +2<CR>", opts)

-- Navigate buffers
keymap("n", "<S-l>", ":bnext<CR>", opts)
keymap("n", "<S-h>", ":bprevious<CR>", opts)

-- Insert --
-- Press jk fast to enter
keymap("i", "jk", "<ESC>", opts)

-- Visual --
-- Stay in indent mode
keymap("v", "<", "<gv", opts)
keymap("v", ">", ">gv", opts)

-- Move text up/down with alt
keymap("v", "<A-j>", ":m .+1<CR>==", opts)
keymap("v", "<A-k>", ":m .-2<CR>==", opts)

-- Paste
keymap("v", "p", '"_dP', opts)

-- Visual Block --
-- Move text up and down
keymap("x", "J", ":move '>+1<CR>gv-gv", opts)
keymap("x", "K", ":move '<-2<CR>gv-gv", opts)
keymap("x", "<A-j>", ":move '>+1<CR>gv-gv", opts)
keymap("x", "<A-k>", ":move '<-2<CR>gv-gv", opts)

-- opts = {buffer = [num|bool], remap = [bool], desc}
local function add_desc(dopts, desc)
	return vim.tbl_extend("force", {}, dopts, { desc = desc })
end

-- Plugins --
-- NvimTree --
local function map_file_explorer(bufnr)
	pcall(vim.keymap.del, "n", "<leader>e", { buffer = bufnr })
	pcall(vim.keymap.del, "n", "<Space>e", { buffer = bufnr })
	vim.keymap.set("n", "<leader>e", "<cmd>NvimTreeToggle<CR>", {
		buffer = bufnr,
		desc = "File [E]xplorer",
		silent = true,
	})
end

keymap("n", "<leader>e", function()
	vim.cmd("NvimTreeToggle")
end, add_desc(opts, "File [E]xplorer"))

vim.api.nvim_create_autocmd("LspAttach", {
	desc = "Restore file explorer key after LSP default mappings",
	callback = function(args)
		vim.schedule(function()
			map_file_explorer(args.buf)
		end)
	end,
})

-- Telescope --
keymap("n", "<leader>ff", function()
	vim.cmd("Telescope find_files")
end, add_desc(opts, "[F]ind [F]iles"))
keymap("n", "<leader>fg", function()
	vim.cmd("Telescope live_grep")
end, add_desc(opts, "[F]ind String ([G]rep)"))
keymap("n", "<leader>fb", function()
	vim.cmd("Telescope buffers")
end, add_desc(opts, "[F]ind [B]uffers"))
keymap("n", "<leader>fh", function()
	vim.cmd("Telescope help_tags")
end, add_desc(opts, "[F]ind [H]elp Tags"))

-- ToggleTerm --
-- keymap("n", "<leader>tg", ":ToggleTerm help_tags<CR>", add_desc(opts, "Find Help Tags"))
