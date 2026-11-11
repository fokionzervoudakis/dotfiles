-- plenary.nvim comes from Kickstart.
vim.pack.add { 'https://github.com/kdheepak/lazygit.nvim' }

vim.keymap.set('n', '<leader>gl', '<cmd>LazyGitLog<CR>', { desc = 'LazyGit log' })
vim.keymap.set('n', '<leader>gg', '<cmd>LazyGit<CR>', { desc = 'LazyGit diff' })
