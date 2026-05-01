M = {
	"nvim-tree/nvim-tree.lua",
	cond = function()
		return not require("user.utils").is_vscode()
	end,
	dependencies = "nvim-tree/nvim-web-devicons",
	version = "*",
	event = "VimEnter",
	cmd = "NvimTreeToggle",
}

local function my_on_attach(bufnr)
	local api = require("nvim-tree.api")

	local function opts(desc)
		return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
	end

	api.config.mappings.default_on_attach(bufnr)
end

M.opts = {
	auto_reload_on_write = true,
	create_in_closed_folder = false,
	disable_netrw = false, -- default false (disabled in options.lua)
	hijack_cursor = true, -- keeps cursor on first letter of filename in the tree
	hijack_netrw = true,
	hijack_unnamed_buffer_when_opening = false,
	on_attach = my_on_attach,
	-- ignore_buffer_on_setup = false,
	-- open_on_setup = true, -- default false
	-- open_on_setup_file = false,
	--[[ open_on_tab = false, ]]
	sort_by = "case_sensitive", -- default: "name"
	-- root_dirs = {},
	-- prefer_startup_root = false,
	--[[ update_cwd = true, -- default false ]]
	sync_root_with_cwd = true, -- required for project.nvim
	reload_on_bufenter = false,
	respect_buf_cwd = true, -- req for project.nvim
	tab = {
		sync = {
			open = false,
		},
	},
	view = {
		width = 36,
		--[[ height = 30, ]]
		--hide_root_folder = false, //deprecated
		side = "left",
		preserve_window_proportions = false,
		number = false,
		relativenumber = false,
		signcolumn = "yes",
		-- mappings = {
		-- 	custom_only = false,
		-- 	list = {
		-- 		{ key = { "l", "<CR>", "o" }, cb = tree_cb("edit") },
		-- 		{ key = "h", cb = tree_cb("close_node") },
		-- 		{ key = "v", cb = tree_cb("vsplit") },
		-- 	},
		-- },
	},
	renderer = {
		add_trailing = false, -- add trailing slash to folders
		group_empty = false, -- group empty folders into parent
		highlight_git = true,
		highlight_opened_files = "icon",
		root_folder_label = ":t",
		indent_markers = {
			enable = true,
			icons = {
				corner = "└",
				edge = "│",
				item = "│",
				none = " ",
				bottom = "─",
			},
		},
		icons = {
			webdev_colors = true,
			git_placement = "before",
			padding = " ",
			show = {
				file = true,
				folder = true,
				folder_arrow = true,
				git = true,
				modified = true,
			},
			glyphs = {
				default = "",
				symlink = "",
				folder = {
					default = "",
					open = "",
					empty = "",
					empty_open = "",
					symlink = "",
				},
				git = {
					unstaged = "",
					-- staged = "S",
					staged = "✓",
					unmerged = "",
					renamed = "➜",
					deleted = "",
					untracked = "U",
					ignored = "◌",
				},
			},
		},
	},
	hijack_directories = {
		enable = true,
		auto_open = true,
	},
	update_focused_file = {
		enable = true, -- both req for project.nvim
		update_root = true,
		--[[ update_cwd = true, ]]
		ignore_list = {},
	},
	-- ignore_ft_on_setup = {
	-- 	"startify",
	-- 	"dashboard",
	-- 	"alpha",
	-- },
	system_open = {
		cmd = nil,
		args = {},
	},
	diagnostics = {
		enable = true,
		icons = {
			hint = "",
			info = "",
			warning = "",
			error = "",
		},
	},
	filters = {
		dotfiles = false,
		custom = { ".DS_Store", "__pycache__" },
		exclude = {},
	},
	filesystem_watchers = {
		enable = true,
		debounce_delay = 100,
	},
	git = {
		enable = true,
		ignore = false,
		timeout = 500,
	},
	actions = {
		use_system_clipboard = true,
		change_dir = {
			enable = true,
			global = false,
			restrict_above_cwd = false,
		},
		open_file = {
			quit_on_open = true,
			resize_window = true,
			window_picker = {
				enable = true,
				chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890",
				exclude = {
					filetype = { "notify", "qf", "diff", "fugitive", "fugitiveblame" },
					buftype = { "nofile", "terminal", "help" },
				},
			},
		},
		remove_file = {
			close_window = true, -- closes windows when removing file from the tree
		},
	},
	trash = {
		cmd = "trash -F",
		require_confirm = true,
	},
	live_filter = {
		prefix = "[FILTER]: ",
		always_show_folders = true,
	},
	log = {
		enable = true,
		truncate = false,
		types = {
			all = false,
			config = true,
			copy_paste = false,
			diagnostics = false,
			git = false,
			profile = false,
		},
	},
}
-- M.config = function(opts)
--   require("nvim-tree").setup(_, opts)
-- end

return M
