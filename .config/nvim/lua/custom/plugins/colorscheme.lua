-- Applied after Kickstart's tokyonight, so this is the colorscheme that wins.
-- `name` is required: the repo is catppuccin/nvim, which would install as "nvim".
vim.pack.add { { src = 'https://github.com/catppuccin/nvim', name = 'catppuccin' } }

vim.cmd.colorscheme 'catppuccin'
