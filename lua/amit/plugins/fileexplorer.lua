return {
	"nvim-telescope/telescope.nvim",
	dependencies = { "nvim-telescope/telescope-file-browser.nvim" },

	config = function()
		local telescope = require("telescope")

		-- Load the Telescope extension
		telescope.setup({
			extensions = {
				file_browser = {
					-- Configurations for file_browser extension
					theme = "ivy",
					hijack_netrw = true, -- Disable netrw in favor of file_browser
				},
			},
		})

		telescope.load_extension("file_browser")
	end,
}
