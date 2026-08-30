vim.pack.add { 'https://github.com/folke/trouble.nvim' }

require('trouble').setup {
  auto_preview = false,
  focus = true,
  warn_no_results = false,
  open_no_results = true,
}

vim.keymap.set('n', '<leader>xx', '<cmd>Trouble diagnostics toggle<cr>', { desc = 'Diagnostics (Trouble)' })
