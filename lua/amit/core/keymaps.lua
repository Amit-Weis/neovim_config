-- set leader key to spce
vim.g.mapleader = " "

local keymap = vim.keymap -- for conciseness

-- General Keymaps -------------------

-- use jk to exit insert mode
-- keymap.set("i", "jk", "<ESC>", { desc = "Exit insert mode with jk" })

-- clear search highlights
keymap.set("n", "<leader>nh", ":nohl<CR>", { desc = "Clear search highlights" })

-- window management
keymap.set("n", "<leader>sv", "<C-w>v", { desc = "Split window vertically" }) -- split window vertically
keymap.set("n", "<leader>sh", "<C-w>s", { desc = "Split window horizontally" }) -- split window horizontally
keymap.set("n", "<leader>se", "<C-w>=", { desc = "Make splits equal size" }) -- make split windows equal width & height
keymap.set("n", "<leader>sx", "<cmd>close<CR>", { desc = "Close current split" }) -- close current split window
keymap.set("n", "<leader>h", "<C-w>h", { desc = "move a window to the left" })
keymap.set("n", "<leader>l", "<C-w>l", { desc = "move a window to the right" })
keymap.set("n", "<leader>j", "<C-w>j", { desc = "move a window to the down" })
keymap.set("n", "<leader>k", "<C-w>k", { desc = "move a window to the up" })

-- tab managment (not the character tab)
keymap.set("n", "<leader>tn", "<cmd>tabnew<CR>", { desc = "Open new tab" }) -- open new tab
keymap.set("n", "<leader>tx", "<cmd>tabclose<CR>", { desc = "Close current tab" }) -- close current tab
keymap.set("n", "<leader>tl", "<cmd>tabn<CR>", { desc = "Go to next tab" }) --  go to next tab
keymap.set("n", "<leader>th", "<cmd>tabp<CR>", { desc = "Go to previous tab" }) --  go to previous tab
keymap.set("n", "<leader>td", "<cmd>tabnew %<CR>", { desc = "Open current buffer in new tab" }) --  move current buffer to new tab

-- selection managment
keymap.set("n", "<C-a>", "gg0vG$", { desc = "select all" }) -- select all
keymap.set("v", "<C-a>", "<C-c>gg0vG$", { desc = "select all" }) -- select all
keymap.set("i", "<C-a>", "<C-c>gg0vG$", { desc = "select all" }) -- select all
keymap.set("v", "<C-c>", "y<C-c>", { desc = "copy paste like normal lol" }) -- ctrl c copy

-- save
keymap.set("i", "<C-s>", "<C-c>:w<ENTER>", { desc = "save in insert mode" }) -- save in insert mode and return to normal mode
keymap.set("n", "<C-s>", ":w<ENTER>", { desc = "save in normal mode" }) -- save in normal mode

keymap.set("n", "<leader>fl", vim.cmd.Ex, { desc = "goes to file exploerer" }) -- goes to file exploerer
vim.keymap.set("n", "<leader>=", "<C-a>", { desc = "Increment number under cursor" })
vim.keymap.set("n", "<leader>-", "<C-x>", { desc = "Decrement number under cursor" })

keymap.set("n", "<C-/>", "0gc$", { desc = "comment out one line" })

-- copy into system clip board (as well as the internal wsl one)
keymap.set("n", "<leader>y", ":'<,'>w !clip.exe<CR><C-v><C-c>")
keymap.set("v", "<leader>y", ":'<,'>w !clip.exe<CR><C-v><C-c>")

-- cut into system clip board (as well as the internal wsl one)
keymap.set("n", "<leader>x", ":'<,'>w !clip.exe<CR>")
keymap.set("v", "<leader>x", ":'<,'>w !clip.exe<CR>")

keymap.set("t", "<C-space>", "<C-\\><C-n>")
