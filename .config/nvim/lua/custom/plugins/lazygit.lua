-- plenary.nvim comes from Kickstart.
vim.pack.add { 'https://github.com/kdheepak/lazygit.nvim' }

vim.keymap.set('n', '<leader>gl', '<cmd>LazyGitLog<CR>', { desc = 'LazyGit log' })
vim.keymap.set('n', '<leader>gg', '<cmd>LazyGit<CR>', { desc = 'LazyGit diff' })

-- In the lazygit window, send each Esc straight to lazygit. Without this,
-- Kickstart's <Esc><Esc> terminal map delays every Esc and a quick double
-- press drops out of terminal mode instead of reaching lazygit.
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'lazygit',
  callback = function(event) vim.keymap.set('t', '<Esc>', '<Esc>', { buffer = event.buf, nowait = true }) end,
})
