-- Markdown preview in a kitty split, rendered by mdfried.
--
-- mdfried draws oversized headers with kitty's text-sizing protocol and real
-- images with the graphics protocol -- neither of which an nvim buffer can do,
-- since a buffer is a uniform grid of same-size cells.
--
-- nvim runs inside a kitty window, so kitty's remote control puts the preview
-- in a split beside it. kitty.conf sets `allow_remote_control yes` and
-- `listen_on unix:/tmp/mykitty`; kitty appends its pid to that path and exports
-- the result as KITTY_LISTEN_ON, so always read the env var.
local M = {}

-- kitty window id of the open preview, nil when closed.
local win_id = nil

---@param args string[]
---@return { code: integer, stdout: string, stderr: string }
local function kitten(args)
	local cmd = { "kitten", "@", "--to", vim.env.KITTY_LISTEN_ON }
	vim.list_extend(cmd, args)
	return vim.system(cmd, { text = true }):wait()
end

---Open the preview beside nvim, or close it if it is already up.
function M.toggle()
	if not vim.env.KITTY_LISTEN_ON then
		vim.notify("No kitty remote control socket", vim.log.levels.WARN)
		return
	end

	if win_id then
		local closed = kitten({ "close-window", "--match", "id:" .. win_id })
		win_id = nil
		-- A non-zero code means the window is already gone (mdfried quit with
		-- `q`, or the split was closed by hand). Fall through and reopen.
		if closed.code == 0 then
			return
		end
	end

	local file = vim.api.nvim_buf_get_name(0)
	if vim.bo.filetype ~= "markdown" or file == "" then
		vim.notify("Not a markdown file on disk", vim.log.levels.WARN)
		return
	end

	-- `--watch` reloads on write, so the preview tracks the file rather than the
	-- buffer -- unsaved changes show up on `:w`.
	-- `--keep-focus` leaves the cursor in nvim; ctrl-l moves into the preview
	-- through vim-kitty-navigator.
	-- `--cwd` is the file's directory so relative image paths resolve.
	local opened = kitten({
		"launch",
		"--type=window",
		"--location=vsplit",
		"--title=markdown-preview",
		"--keep-focus",
		"--cwd=" .. vim.fs.dirname(file),
		"mdfried",
		"--watch",
		file,
	})
	if opened.code ~= 0 then
		vim.notify("kitty launch failed: " .. (opened.stderr or ""), vim.log.levels.ERROR)
		return
	end
	win_id = vim.trim(opened.stdout)
end

return M
