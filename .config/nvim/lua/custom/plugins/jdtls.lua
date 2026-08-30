-- The server itself is installed by Mason; .config/nvim/ftplugin/java.lua attaches it.
vim.pack.add { 'https://github.com/mfussenegger/nvim-jdtls' }

vim.keymap.set('n', '<leader>i', function()
  require('jdtls').organize_imports()
end, { desc = 'Organize imports' })
