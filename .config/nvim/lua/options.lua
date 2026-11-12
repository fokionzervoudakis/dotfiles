-- termguicolors is required by several plugins
vim.opt.termguicolors = true

-- Set relative line numbers
vim.opt.relativenumber = true

-- Set the command line height
vim.opt.cmdheight = 2

-- Enable spell checking
vim.opt.spell = true

-- Open help windows to the right of the current window
vim.api.nvim_create_autocmd('BufWinEnter', {
  callback = function()
    if vim.bo.buftype == 'help' then vim.cmd 'wincmd L' end
  end,
})

-- Use fuzzy-matching to find completion matches
vim.opt.wildoptions = 'fuzzy'

-- Configure indentation
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4
vim.opt.expandtab = true

-- Configure white space
vim.opt.list = true
vim.opt.listchars = {
  eol = '↲',
  multispace = '·',
  tab = '»·',
  trail = '·',
}

-- FOLDS

-- Restore views for all file types when buffers are loaded
vim.api.nvim_create_autocmd('BufWinEnter', {
  callback = function() vim.cmd 'silent! loadview' end,
})

-- Do not open folds when moving with Shift+[ or Shift+]
vim.opt.foldopen:remove 'block'

-- CSV

-- The built-in csv syntax colours each column; the treesitter parser Kickstart
-- attaches only colours the delimiters, and disables syntax while it runs.
vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'csv', 'tsv' },
  callback = function(args)
    vim.treesitter.stop(args.buf)
    vim.bo[args.buf].syntax = args.match
  end,
})

-- COPILOT

-- Activate the copilot-language-server config shipped by nvim-lspconfig.
-- Sign in with :LspCopilotSignIn, see `:help lsp-copilot`
vim.lsp.enable 'copilot'

-- Show Copilot suggestions as ghost text wherever a client that supports them
-- attaches, including clients that start later
vim.lsp.inline_completion.enable()

-- Accept the current suggestion
vim.keymap.set('i', '<C-l>', vim.lsp.inline_completion.get, { desc = 'Accept inline completion' })
