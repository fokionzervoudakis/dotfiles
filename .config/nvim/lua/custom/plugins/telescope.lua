-- telescope, telescope-fzf-native and telescope-ui-select come from Kickstart.
-- Only this extension and the config below are ours.
vim.pack.add { 'https://github.com/debugloop/telescope-undo.nvim' }

local actions = require 'telescope.actions'

-- Grep the same files find_files lists: hidden and gitignored ones too, but not .git
local grep_args = { unpack(require('telescope.config').values.vimgrep_arguments) }
vim.list_extend(grep_args, { '--no-ignore', '--hidden', '--glob', '!**/.git/*' })

require('telescope').setup {
  defaults = {
    vimgrep_arguments = grep_args,
    mappings = {
      i = {
        ['<C-k>'] = actions.cycle_history_prev,
        ['<C-j>'] = actions.cycle_history_next,
        ['<C-f>'] = actions.to_fuzzy_refine,
      },
    },
  },
  pickers = {
    find_files = {
      find_command = {
        'rg',
        '--files',
        '--hidden',
        '--no-ignore',
        '--glob',
        '!**/.git/*',
      },
    },
  },
  -- Preserved from Kickstart's own setup call, which this one replaces.
  extensions = {
    ['ui-select'] = { require('telescope.themes').get_dropdown() },
  },
}

require('telescope').load_extension 'undo'

local builtin = require 'telescope.builtin'
vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = 'Find buffers' })
vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = 'Find files' })
vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = 'Find by grep' })
vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = 'Find help' })
vim.keymap.set('n', '<leader>fo', builtin.oldfiles, { desc = 'Find recently opened files' })
vim.keymap.set('n', '<leader>u', '<cmd>Telescope undo<CR>', { desc = 'Browse undo history' })

-- Buffer-local, so buffers without an LSP keep Vim's own gd and gr.
vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('custom-telescope-lsp-attach', { clear = true }),
  callback = function(event)
    vim.keymap.set('n', 'gd', builtin.lsp_definitions, { buffer = event.buf, desc = 'Go to definition' })
    vim.keymap.set('n', 'gr', builtin.lsp_references, { buffer = event.buf, desc = 'Find references' })
  end,
})
