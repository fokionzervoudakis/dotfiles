local keymap = vim.keymap

-- https://stackoverflow.com/a/3776182

-- NORMAL MODE

-- Go to previous buffer
keymap.set('n', '<leader>,', '<cmd>bprevious<CR>', { desc = 'Go to previous buffer' })

-- Go to next buffer
keymap.set('n', '<leader><leader>', '<cmd>bnext<CR>', { desc = 'Go to next buffer' })

-- Go to previously opened buffer
keymap.set('n', '<leader>.', '<cmd>b#<CR>', { desc = 'Go to previously opened buffer' })

-- Go to next diagnostic message, centered
keymap.set('n', '<leader>d', function()
  vim.diagnostic.jump { count = 1 }
  vim.cmd 'normal! zz'
end, { desc = 'Go to next diagnostic' })

-- Go to previous diagnostic message, centered
keymap.set('n', '<leader>D', function()
  vim.diagnostic.jump { count = -1 }
  vim.cmd 'normal! zz'
end, { desc = 'Go to previous diagnostic' })

-- Toggle a quickfix list of diagnostics from all buffers
keymap.set('n', '<leader>xx', function()
  if vim.fn.getqflist({ winid = 0 }).winid ~= 0 then
    vim.cmd.cclose()
  else
    vim.diagnostic.setqflist()
  end
end, { desc = 'Toggle diagnostics quickfix list' })

-- Go to next spelling error, centered
keymap.set('n', '<leader>s', ']szz', { desc = 'Go to next spelling error' })

-- Repeat latest f, t, F or T in opposite direction
keymap.set('n', "'", ',', { desc = 'Repeat f/t/F/T in opposite direction' })

-- Copy relative file path to clipboard
keymap.set('n', '<leader>cp', '<cmd>let @* = expand("%:p:~:.")<CR>', { desc = 'Copy relative file path' })

-- Delete current buffer
keymap.set('n', '<leader>db', '<cmd>bd<CR>', { desc = 'Delete current buffer' })

-- Save view of current buffer
keymap.set('n', '<leader>mk', '<cmd>mkview<CR>', { desc = 'Save view of current buffer' })

-- Open new tab
keymap.set('n', '<leader>to', '<cmd>tabedit<CR>', { desc = 'Open new tab' })

-- Disable movement with arrow keys
keymap.set('n', '<up>', '<nop>')
keymap.set('n', '<down>', '<nop>')
keymap.set('n', '<left>', '<nop>')
keymap.set('n', '<right>', '<nop>')

-- Center screen when jumping
keymap.set('n', 'n', 'nzz')
keymap.set('n', 'N', 'Nzz')
keymap.set('n', '<C-d>', '<C-d>zz')
keymap.set('n', '<C-u>', '<C-u>zz')

-- VISUAL AND SELECT MODES

-- Disable movement with arrow keys
keymap.set('v', '<up>', '<nop>')
keymap.set('v', '<down>', '<nop>')
keymap.set('v', '<left>', '<nop>')
keymap.set('v', '<right>', '<nop>')

-- VISUAL MODE

-- Paste the same value over selected text multiple times
-- 'p' to put/paste, 'gv' to select the text that was put, and 'y' to copy the selected text
keymap.set('x', 'p', 'pgvy')

-- INSERT MODE

-- Disable movement with arrow keys
keymap.set('i', '<up>', '<nop>')
keymap.set('i', '<down>', '<nop>')
keymap.set('i', '<left>', '<nop>')
keymap.set('i', '<right>', '<nop>')
