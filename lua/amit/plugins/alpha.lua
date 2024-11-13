-- local file = io.open("tree.txt", "w+")
-- os.execute("pybonsai > tree.txt")
--
-- -- i dont like that change
-- file:close()
--
-- file = io.open("tree.txt", "r")
-- local lines = {}
-- for line in file:lines() do
-- 	table.insert(lines, line)
-- end
-- file:close()
--
-- -- Define the function to strip the tree boundaries and write to another file
-- -- Function to strip tree boundaries and write to a file
-- local function strip_tree_boundaries_to_file(input_lines, output_file)
-- 	local first_escape_line = -1
-- 	local last_escape_line = -1
-- 	local escape_char = "\27" -- This is the escape character (ASCII 27)
--
-- 	local leftmost_col, rightmost_col = math.huge, 0
--
-- 	-- Identify the boundary lines and columns
-- 	for i = 2, #input_lines - 1 do
-- 		if input_lines[i]:find(escape_char) then
-- 			local first_non_whitespace = input_lines[i]:find(escape_char)
-- 			leftmost_col = math.min(leftmost_col, first_non_whitespace)
-- 			rightmost_col = math.max(rightmost_col, #input_lines[i])
-- 			if first_escape_line == -1 then
-- 				first_escape_line = i
-- 			end
-- 			last_escape_line = i
-- 		end
-- 	end
--
-- 	-- Trim the lines based on the identified boundaries
-- 	local trimmed_lines = {}
-- 	for i = first_escape_line, last_escape_line - 1 do
-- 		local trimmed_line = input_lines[i]:sub(leftmost_col, rightmost_col)
-- 		table.insert(trimmed_lines, trimmed_line)
-- 	end
--
-- 	-- Write trimmed lines to the output file
-- 	for _, line in ipairs(trimmed_lines) do
-- 		output_file:write(line .. "\n")
-- 	end
--
-- 	return trimmed_lines
-- end
--
-- local file2 = io.open("tree2.txt", "w+")
-- strip_tree_boundaries_to_file(lines, file2)
--
-- local function center_tree(tree_lines)
-- 	local max_width = 0
-- 	local trunk_pos = nil
-- 	local first_dot_pos = nil
-- 	local second_dot_pos = nil
--
-- 	local centered_tree = {}
--
-- 	-- Find the trunk line and calculate the maximum width
-- 	for i = 1, #tree_lines, 1 do
-- 		table.insert(centered_tree, tree_lines[i])
-- 		local width = #tree_lines[i]
-- 		if width > max_width then
-- 			max_width = width
-- 		end
--
-- 		local trunk_start = "./"
-- 		local trunk_end = "\\."
-- 		if not first_dot_pos and not second_dot_pos then
-- 			first_dot_pos = string.find(tree_lines[i], trunk_start, 1, true)
--
-- 			if first_dot_pos then
-- 				second_dot_pos = string.find(tree_lines[i], trunk_end, first_dot_pos + 1, true)
-- 			end
--
-- 			if first_dot_pos and second_dot_pos then
-- 				trunk_pos = math.floor((first_dot_pos + second_dot_pos) / 2)
-- 			else
-- 				first_dot_pos = nil
-- 				second_dot_pos = nil
-- 			end
-- 		end
-- 	end
--
-- 	if not first_dot_pos then
-- 		error("something went really wrong")
-- 	end
--
-- 	if not second_dot_pos then
-- 		error("second wrong too")
-- 	end
-- 	if not trunk_pos then
-- 		error("Trunk position not found.")
-- 	end
--
-- 	local centered_trunk_pos = math.floor((max_width + 1) / 2) - math.floor((second_dot_pos - first_dot_pos) / 2)
--
-- 	while trunk_pos ~= centered_trunk_pos do
-- 		local pad = centered_trunk_pos - trunk_pos
-- 		for i = 1, #tree_lines, 1 do
-- 			if pad > 0 then
-- 				centered_tree[i] = " " .. centered_tree[i]
-- 			else
-- 				centered_tree[i] = centered_tree[i] .. " "
-- 			end
-- 		end
-- 		if pad > 0 then
-- 			trunk_pos = trunk_pos + 1
-- 		end
-- 		max_width = max_width + 1
-- 		centered_trunk_pos = math.floor((max_width + 1) / 2) - math.floor((second_dot_pos - first_dot_pos) / 2)
-- 	end
--
-- 	return centered_tree
-- end -- Main function to process the ANSI file and apply highlights
--
-- local function convert_ansi_tree_to_vim_hl_tree(file_path)
-- 	-- Converts a text file into an alpha-nvim dashboard with applied highlights
-- 	local dashboard = {}
-- 	local file3 = io.open(file_path, "r")
-- 	local lines2 = {}
-- 	for line in file3:lines() do
-- 		table.insert(lines2, line)
-- 	end
--
-- 	for _, line in ipairs(lines2) do
-- 		table.insert(dashboard, "")
-- 		local i = 1
-- 		local current_hl = nil -- To track the current highlight
-- 		while i <= #line do
-- 			local char = line:sub(i, i)
-- 			if char ~= "\27" then
-- 				-- If there's an active highlight, wrap the character with the highlight
-- 				if current_hl then
-- 					dashboard[#dashboard] = dashboard[#dashboard] .. ("%s"):format(current_hl, char)
-- 				else
-- 					dashboard[#dashboard] = dashboard[#dashboard] .. char
-- 				end
-- 				i = i + 1
-- 			else
-- 				-- Skip the escape sequence
-- 				i = i + 2
-- 				local ansi_code = ""
-- 				while line:sub(i, i) ~= "m" do
-- 					ansi_code = ansi_code .. line:sub(i, i)
-- 					i = i + 1
-- 				end
-- 				-- Move past the 'm' character
-- 				i = i + 1
-- 				-- Convert the ANSI code to a Vim highlight group
-- 				-- local hex_code = ansi_truecolor_to_hex(ansi_code)
-- 				-- current_hl = hex_to_vim_highlight(hex_code)
-- 			end
-- 		end
-- 	end
-- 	file3:close()
-- 	local file4 = io.open("tree4.txt", "w+")
-- 	for _, line in ipairs(dashboard) do
-- 		file4:write(line .. "\n")
-- 	end
-- 	io.close(file4)
-- 	return center_tree(dashboard)
-- end
--
-- vim.keymap.set("n", "<leader>~~~~~~~~~~", function()
-- 	vim.notify("uRaID10T: Improper method to quit Neovim.", "error", { title = "QuitTime Error" })
-- end)
return {
	"goolord/alpha-nvim",
	event = "VimEnter",
	config = function()
		local alpha = require("alpha")
		local dashboard = require("alpha.themes.dashboard")

		-- Set header
		dashboard.section.header.val = ""
		-- Delete tree.txt, tree2.txt, and tree4.txt
		os.remove("tree.txt")
		os.remove("tree2.txt")
		os.remove("tree4.txt")

		-- Set menu
		dashboard.section.buttons.val = {
			dashboard.button("SPC ff", "󰱼  > Fuzzy Finder", "<cmd>Telescope find_files<CR>"),
			dashboard.button("SPC fl", "󰱼  > File Browser", "<cmd>Telescope file_browser<CR>"),
			dashboard.button("SPC gl", "󰊢  > Lazy Git", "<cmd>LazyGit<cr>"),
			dashboard.button("idk bro", "  > Quit NVIM", "<leader>~~~~~~~~~~~"),
		}

		-- Send config to alpha
		alpha.setup(dashboard.opts)

		-- Disable folding on alpha buffer
		vim.cmd([[autocmd FileType alpha setlocal nofoldenable]])
	end,
}
