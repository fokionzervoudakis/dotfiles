-- telescope, telescope-fzf-native and telescope-ui-select come from Kickstart.
-- Only this extension and the config below are ours.
vim.pack.add { 'https://github.com/debugloop/telescope-undo.nvim' }

local actions = require 'telescope.actions'

-- Extend default vimgrep arguments to not respect .gitignore
local grep_args = { unpack(require('telescope.config').values.vimgrep_arguments) }
table.insert(grep_args, '--no-ignore')

require('telescope').setup {
  defaults = {
    vimgrep_arguments = grep_args,
    mappings = {
      i = {
        ['<C-k>'] = actions.cycle_history_prev,
        ['<C-j>'] = actions.cycle_history_next,
        ['<C-o>'] = function(p_bufnr)
          actions.send_selected_to_qflist(p_bufnr)
          vim.cmd.cfdo 'edit'
        end,
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
vim.keymap.set('n', '<leader>fb', builtin.buffers)
vim.keymap.set('n', '<leader>ff', builtin.find_files)
vim.keymap.set('n', '<leader>fg', builtin.live_grep)
vim.keymap.set('n', '<leader>fh', builtin.help_tags)
vim.keymap.set('n', '<leader>fo', builtin.oldfiles)
vim.keymap.set('n', '<leader>u', '<cmd>Telescope undo<CR>')

-- Buffer-local, so buffers without an LSP keep Vim's own gd and gr.
vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('custom-telescope-lsp-attach', { clear = true }),
  callback = function(event)
    vim.keymap.set('n', 'gd', builtin.lsp_definitions, { buffer = event.buf })
    vim.keymap.set('n', 'gr', builtin.lsp_references, { buffer = event.buf })
  end,
})
