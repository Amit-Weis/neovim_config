vim.loader.enable()
vim.o.pumwidth = 30
require("amit.core")
require("amit.core.keymaps")
require("amit.lazy")

vim.notify = require("notify")
