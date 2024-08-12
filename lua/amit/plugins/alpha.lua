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
	return "%#" .. tostring(count - 1)
end
function convert_ansi_tree_to_vim_hl_tree(file_path)
	-- converts a textfile into a alphanvim dashboard
	local file = io.open(file_path, "w+")
	os.execute("pybonsai > " .. file_path)
	io.close(file)
	file = io.open(file_path, "r")
	local dashboard = {}
	local onfirstline = true
	for line in file:lines() do
		if onfirstline then
			onfirstline = false
			goto continue
		end
		table.insert(dashboard, "")
		local i = 0
		while i <= #line do
			if line[i] == " " then
				dashboard[#dashboard] = dashboard[#dashboard] .. line[i]
				i = i + 1
			elseif line[i] == "" then
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
		::continue::
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

		local file = io.open("tree.txt", "w+")
		os.execute("pybonsai > tree.txt")
		io.close(file)
		-- Set header
		dashboard.section.header.val = {
			"123456789",
		}

		dashboard.opts = { { hl = "Function", 1, 9 } }

		-- Set menu
		dashboard.section.buttons.val = {
			dashboard.button("%", "  > New File", "<cmd>ene<CR>"),
			dashboard.button("SPC ff", "󰱼  > Find File", "<cmd>Telescope find_files<CR>"),
			dashboard.button("SPC <C-r>", "󰁯  > Restore Session", "<cmd>SessionRestore<CR>"),
			dashboard.button("q", "  > Quit NVIM", "<cmd>qa<CR>"),
		}

		-- Send config to alpha
		alpha.setup(dashboard.opts)

		highlight_alpha_dashboard(buff_id)
		-- Disable folding on alpha buffer
		vim.cmd([[autocmd FileType alpha setlocal nofoldenable]])
	end,
}
