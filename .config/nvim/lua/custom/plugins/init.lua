-- Personal plugins, installed with `vim.pack` and loaded from init.lua.
--
-- Kickstart's own init.lua is left pristine so it can be updated wholesale without
-- taking personal config with it. Anything of ours lives here instead.
--
-- Order matters: the colorscheme goes first so plugins that read highlight groups
-- see the right ones.

require 'custom.plugins.colorscheme'

require 'custom.plugins.autopairs'
require 'custom.plugins.bufferline'
require 'custom.plugins.conform'
require 'custom.plugins.csvview'
require 'custom.plugins.leap'
require 'custom.plugins.oil'
require 'custom.plugins.telescope'
require 'custom.plugins.trouble'

require 'custom.plugins.lazygit'
require 'custom.plugins.neogit'

require 'custom.plugins.jdtls'
require 'custom.plugins.vimtex'

require 'custom.plugins.obsidian'
require 'custom.plugins.orgmode'
