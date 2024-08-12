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

local count = 0
local function ansi_truecolor_to_hex(ansi_code)
	-- Split the ANSI code by ";"
	local parts = {}
	for part in string.gmatch(ansi_code, "([^;]+)") do
		table.insert(parts, part)
	end

	-- Convert parts to integers and then to hex
	local r = string.format("%02X", tonumber(parts[#parts - 2]))
	local g = string.format("%02X", tonumber(parts[#parts - 1]))
	local b = string.format("%02X", tonumber(parts[#parts]))

	-- Return hex color code
	return string.format("#%s%s%s", r, g, b)
end

local function hex_to_vim_highlight(color)
	-- Create Vim highlight command

	local vim_command = string.format(":highlight %s guifg=%s guibg=NONE", tostring(count), color)
	count = count + 1
	vim.cmd(vim_command)
	return tostring(count - 1)
end
function convert_ansi_tree_to_vim_hl_tree(file_path)
	-- converts a textfile into a alphanvim dashboard
	local dashboard = {}
	for line in file:lines() do
		table.insert(dashboard, "")
		local i = 0
		while i <= #line do
			if line[i] ~= "\27" then
				dashboard[#dashboard] = dashboard[#dashboard] .. line[i]
				i = i + 1
			elseif line[i] == "\27" then
				i = i + 2
				local asni_code = ""
				while line[i] ~= "m" do
					asni_code = asni_code .. line[i]
					i = i + 1
				end
				i = i + 1
				local hex_code = ansi_truecolor_to_hex(asni_code)
				local hl_name = hex_to_vim_highlight(hex_code)
				dashboard[#dashboard] = dashboard[#dashboard] .. hl_name
			end
		end
	end
end

local buff_id = vim.api.nvim_get_current_buf()
local function highlight_alpha_dashboard(buf_id)
	-- Assuming you want to loop through all lines in the dashboard
	local lines = vim.api.nvim_buf_get_lines(buf_id, 0, -1, false)

	for line_num, line in ipairs(lines) do
		-- Loop through each character in the line
		for col_num = 0, #line do
			-- Example: Highlight each character in a different color
			vim.api.nvim_buf_add_highlight(buf_id, -1, "Function", line_num - 1, col_num, col_num + 1)
		end
	end
end

return {
	"goolord/alpha-nvim",
	event = "VimEnter",
	config = function()
		local alpha = require("alpha")
		local dashboard = require("alpha.themes.dashboard")

		-- Set header
		dashboard.section.header.val = {
			"                                                     ",
			"  ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗ ",
			"  ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║ ",
			"  ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║ ",
			"  ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║ ",
			"  ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║ ",
			"  ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝ ",
			"                                                     ",
		}

		-- Set menu
		dashboard.section.buttons.val = {
			dashboard.button("%", "  > New File", "<cmd>ene<CR>"),
			dashboard.button("SPC ff", "󰱼  > Find File", "<cmd>Telescope find_files<CR>"),
			dashboard.button("SPC <C-r>", "󰁯  > Restore Session", "<cmd>SessionRestore<CR>"),
			dashboard.button("q", "  > Quit NVIM", "<cmd>qa<CR>"),
		}

		-- Send config to alpha
		alpha.setup(dashboard.opts)

		-- Disable folding on alpha buffer
		vim.cmd([[autocmd FileType alpha setlocal nofoldenable]])
	end,
}
