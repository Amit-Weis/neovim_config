print("hello")
vim.cmd("let g:netrw_liststyle = 3")

-- opt init
local opt = vim.opt

-- relative line numbers
opt.relativenumber = true -- relative numbers
opt.number = true --

-- tabs & indentation
opt.tabstop = 2 -- 2 spaces for tabs
opt.shiftwidth = 2 -- 2 spaces for indent width
opt.expandtab = true -- expand tab to spaces
opt.autoindent = true -- copy indent from current line when starting new one

-- wrap
opt.wrap = false -- no soft line wrapping (MIGHT NEED CHANGING NGL)

-- search settings
opt.ignorecase = true -- ignore case when searching
opt.smartcase = true -- if you include capital case in your search, vim assumes you want case-sensative search
opt.hlsearch = false -- turns off highlighted search lol
opt.incsearch = true -- turns on highlighted search when activlty searching

-- cursore line
opt.cursorline = true -- highlights the line the cursor is on

-- turn on termbuicolors for colorschemes to work
-- have to use any true color terminal (like powershell) for this to function properly as well
opt.termguicolors = true
opt.background = "dark" -- colorschemes that can be light or dark will be made dark
opt.signcolumn = "yes" -- show sign colunm so text does not shift

-- backspace
opt.backspace = "indent,eol,start" -- allow backspace on indent, end of line, or insert mode start position

-- split window rules
opt.splitright = true -- split vertical window to the right
opt.splitbelow = true -- split horizontal window to the bottom

-- scroll
opt.scrolloff = 8
opt.updatetime = 50
opt.colorcolumn = "100"
