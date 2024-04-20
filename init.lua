-- INFO: BEFORE ALL
vim.g.mapleader = " "
vim.g.maplocalleader = " "
require("gt.lazy")

-- INFO: MAIN CONF
require("gt.core.options")
require("gt.core.keymaps")
require("gt.core.autocommands")

-- INFO: AFTER ALL
vim.cmd.colorscheme("catppuccin-frappe")
vim.cmd.hi("Comment gui=none")
