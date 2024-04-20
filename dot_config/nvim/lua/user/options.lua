-- global option
vim.opt.splitbelow = true
vim.opt.splitright = true

vim.opt.showmode = false

-- window options
vim.opt.number = true
vim.opt.relativenumber = true

-- window option
vim.opt.cursorline = true

-- SEE: :help 'tabstop', and :help 'smarttab' (on by default)

--[[ NOTE: If 'softtabstop' is set to a positive integer then pressing <Tab>
inserts that amount of whitespace as either spaces, tabs or a mixture of both
depending on what 'tabstop' is set to. For example if 'tabstop' is set to 5 and
'softtabstop' is set to 3 then pressing <Tab> once inserts 3 spaces. Pressing
<Tab> again would insert 3 more whitespace columns (for a total of 6), but
since tab counts as 5 whitespace columns vim would replace the original spaces
with one tab and then insert one space. By default softtabstop is 0.

Also note that if expandtab is set vim will never insert tab characters, and
that what is backspaced is also effected by these settings. ]]

-- buffer options
-- number of columns a tab character counts for
vim.opt.tabstop = 4
-- number of columns for a "level of indentation" (e.g., as interpreted by >>)
vim.opt.shiftwidth = 4
-- never insert a literal tab character (even after pressing <Tab>)
vim.opt.expandtab = true

-- window option
--[[ sign column only present if at least one sign is (up to a maximum of 7
signs per line) ]]
-- TODO(michael): look into h: 'statuscolumn'
vim.opt.signcolumn = "auto:7" -- gitsigns, diagnosticsigns (4), commentsigns, dap

-- window option
-- vim.opt.statuscolumn = "%s │ %=%(%{v:relnum?v:relnum:v:lnum}  %)"

-- global or local to window
vim.opt.listchars = {
    eol      = "⏎",
    tab      = "⇥·",
    space    = "·",
    trail    = "␣",
    precedes = "«",
    extends  = "»",
    nbsp     = "⍽"
}

-- global or local to window
vim.opt.scrolloff = 5

-- global or local to window
vim.opt.fillchars = { vert = "▚", fold = "·" }
vim.opt.showbreak = "↪ "

-- window options
vim.opt.linebreak = true
vim.opt.breakindent = true

vim.opt.cmdheight = 0

-- buffer options
-- do not automatically insert comment leader on o/O when in a comment
-- FIX: something else sets this after `init.lua`
vim.opt.formatoptions:remove("o")
