return {
	"folke/noice.nvim",
	event = "VeryLazy",
	filter = {
		event = "msg_show",
		kind = "",
		find = "written",
	},
	opts = { skip = true },
	dependencies = {
		"MunifTanjim/nui.nvim",
	},
}
