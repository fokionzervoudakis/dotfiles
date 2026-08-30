-- plenary.nvim and telescope.nvim come from Kickstart.
vim.pack.add { 'https://github.com/NeogitOrg/neogit' }

require('neogit').setup {}

vim.keymap.set('n', '<leader>gn', '<cmd>Neogit<CR>', { desc = 'Open Neogit' })
