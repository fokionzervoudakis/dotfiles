-- mini.icons comes from Kickstart's mini.nvim.
vim.pack.add { 'https://github.com/stevearc/oil.nvim' }

---@module 'oil'
---@type oil.SetupOpts
require('oil').setup {
  view_options = {
    show_hidden = true,
  },
}

vim.keymap.set('n', '-', '<cmd>Oil<CR>', { desc = 'Open Oil file explorer' })
