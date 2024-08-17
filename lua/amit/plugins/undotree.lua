return {
	"mbbill/undotree",

	config = function()
		-- Set keymap for toggling Undotree
		vim.keymap.set("n", "<leader>u", ":UndotreeToggle<CR>")

		-- Configuration options for undotree
		vim.g.undotree_WindowLayout = 2 -- Layout option, you can customize this
		vim.g.undotree_SplitWidth = 30 -- Width of the undotree window
		vim.g.undotree_SetFocusWhenToggle = 1 -- Focus on the undotree window when opened
		vim.g.undotree_TreeNodeShape = "" -- Change the node shape to a filled circle
		vim.g.undotree_TreeVertShape = "│" -- Vertical line

		-- Enable persistent undo in Neovim
		vim.opt.undofile = true -- Maintain undo history between sessions
		vim.opt.undodir = vim.fn.expand("~/.config/nvim/undo") -- Directory to store undo files

		-- Ensure the undo directory exists
		local undodir = vim.opt.undodir:get()[1]
		if vim.fn.isdirectory(undodir) == 0 then
			vim.fn.mkdir(undodir, "p")
		end
	end,
}
-- test
