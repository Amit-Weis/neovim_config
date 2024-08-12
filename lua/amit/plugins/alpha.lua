-- Open the file and generate the tree
local file = io.open("tree.txt", "w+")
os.execute("pybonsai > tree.txt")
file:close() -- Close the file after writing

-- Reopen the file to read its content
file = io.open("tree.txt", "r")
local lines = {}
for line in file:lines() do
	table.insert(lines, line)
end
file:close() -- Close the file after reading

-- Define the function to strip the tree boundaries and write to another file
local function strip_tree_boundaries_to_file(input_lines, output_file)
	local first_escape_line = -1
	local last_escape_line = -1
	local escape_char = "\27" -- This is the escape character (ASCII 27)

	local leftmost_col, rightmost_col = math.huge, 0
	-- Find the first and second-last lines containing the escape character
	for i = 2, #input_lines - 1 do
		if input_lines[i]:find(escape_char) then
			local first_non_whitespace = input_lines[i]:find(escape_char)
			leftmost_col = math.min(leftmost_col, first_non_whitespace)
			rightmost_col = math.max(rightmost_col, #input_lines[i])
			if first_escape_line == -1 then
				first_escape_line = i
			end
			last_escape_line = i
		end
	end

	-- Determine the leftmost and rightmost points of the tree
	-- Trim the lines to the leftmost and rightmost boundaries
	local trimmed_lines = {}
	for i = first_escape_line, last_escape_line - 1 do
		local trimmed_line = input_lines[i]:sub(leftmost_col, rightmost_col)
		table.insert(trimmed_lines, trimmed_line)
	end

	-- Write the trimmed lines to the output file
	for _, line in ipairs(trimmed_lines) do
		output_file:write(line .. "\n")
	end
	return trimmed_lines
end

-- Open the output file for writing
local file2 = io.open("tree2.txt", "w+")
local function get_file_dimensions(file_path)
	local file = io.open(file_path, "r")
	local width = 0
	local height = 0

	for line in file:lines() do
		height = height + 1
		local line_width = #line
		if line_width > width then
			width = line_width
		end
	end

	file:close()
	return width
end

local function get_file_dimensions2(file_path)
	local file = io.open(file_path, "r")
	local width = 0
	local height = 0

	for line in file:lines() do
		height = height + 1
	end

	file:close()
	return height
end

return {

	"nvimdev/dashboard-nvim",
	event = "VimEnter",
	config = function()
		require("dashboard").setup({
			theme = "doom",
			hide = {
				statusline = true,
				tabline = true,
				winbar = true,
			},
			config = {
				header = strip_tree_boundaries_to_file(lines, file2),
				io.close(file2),
				disable_move = true,
				center = {
					{
						icon = " 󰈔 \t",
						icon_hl = "DashboardIcon",
						desc = "Open file",
						desc_hl = "DashboardDesc",
						key = "1",
						key_hl = "Number",
						key_format = " %s.", -- `%s` will be substituted with value of `key`
						action = "Telescope find_files",
					},
					{
						icon = " 󰈞 \t",
						icon_hl = "Title",
						desc = "Fuzzy Grep",
						desc_hl = "DashboardDesc",
						key = "2",
						key_hl = "Number",
						key_format = " %s.", -- `%s` will be substituted with value of `key`
						action = "Telescope live_grep",
					},
					{
						icon = " 󰂺 \t",
						icon_hl = "Title",
						desc = "Open Readme",
						desc_hl = "DashboardDesc",
						key = "3",
						key_hl = "Number",
						key_format = " %s.", -- `%s` will be substituted with value of `key`
						action = "Glow README.md",
					},
					{
						icon = "  \t",
						icon_hl = "DashboardIcon",
						desc = "Git History",
						desc_hl = "DashboardDesc",
						key = "4",
						key_hl = "Number",
						key_format = " %s.", -- `%s` will be substituted with value of `key`
						action = "Telescope git_commits",
					},
					{
						icon = "  \t",
						icon_hl = "Title",
						desc = "Mason Config",
						desc_hl = "DashboardDesc",
						key = "5",
						key_hl = "Number",
						key_format = " %s.", -- `%s` will be substituted with value of `key`
						action = "Mason",
					},
					{
						icon = "  \t",
						icon_hl = "Title",
						desc = "LazyVim Config",
						desc_hl = "DashboardDesc",
						key = "6",
						key_hl = "Number",
						key_format = " %s.", -- `%s` will be substituted with value of `key`
						action = "Lazy",
					},
					{
						icon = "  \t",
						icon_hl = "Title",
						desc = "Vim Options",
						desc_hl = "DashboardDesc",
						key = "7",
						key_hl = "Number",
						key_format = " %s.", -- `%s` will be substituted with value of `key`
						action = "Telescope vim_options",
					},
					{
						icon = " 󰈆 \t",
						icon_hl = "Title",
						desc = "Quit NeoVim",
						desc_hl = "DashboardDesc",
						key = "0",
						key_hl = "Number",
						key_format = " %s.", -- `%s` will be substituted with value of `key`
						action = "qa",
					},
				},
			},
		})
	end,

	dependencies = { { "nvim-tree/nvim-web-devicons" } },
}
