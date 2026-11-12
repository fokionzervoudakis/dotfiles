-- Personal plugins, installed with `vim.pack` and loaded from init.lua.
--
-- Kickstart's own init.lua is left pristine so it can be updated wholesale without
-- taking personal config with it. Anything of ours lives here instead.
--
-- Order matters: the colorscheme goes first so plugins that read highlight groups
-- see the right ones.

require 'custom.plugins.colorscheme'

require 'custom.plugins.pairs'
require 'custom.plugins.tabline'
require 'custom.plugins.conform'
require 'custom.plugins.mason'
require 'custom.plugins.oil'
require 'custom.plugins.telescope'

require 'custom.plugins.lazygit'

require 'custom.plugins.jdtls'

require 'custom.plugins.orgmode'

vim.api.nvim_create_user_command('PackUpdate', function() vim.pack.update(nil, { force = true }) end, {
  desc = 'Update all vim.pack plugins without a review buffer',
})
