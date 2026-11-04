-- Applied after Kickstart's tokyonight, so this is the colorscheme that wins.
-- Every scheme installed here (plus tokyonight) can be tried with :Telescope colorscheme.
-- `name` is required for catppuccin: the repo is catppuccin/nvim, which would install as "nvim".
vim.pack.add {
  'https://github.com/ellisonleao/gruvbox.nvim',
  { src = 'https://github.com/catppuccin/nvim', name = 'catppuccin' },
  'https://github.com/rebelot/kanagawa.nvim',
}

vim.cmd.colorscheme 'gruvbox'
