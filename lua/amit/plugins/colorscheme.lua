return {
	-- Add other plugins here

	-- Add rose-pine colorscheme plugin
	{
		"rebelot/kanagawa.nvim",
		config = function()
			require("kanagawa").setup({
				keywordStyle = { italic = false },
				theme = "dragon",
			})
			-- Set the colorscheme
			vim.cmd("colorscheme kanagawa")
		end,
	},
}
