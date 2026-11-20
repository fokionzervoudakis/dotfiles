-- telescope, telescope-fzf-native and telescope-ui-select come from Kickstart.
-- Only the config below is ours.

local actions = require 'telescope.actions'
local action_state = require 'telescope.actions.state'

-- Enter opens every entry marked with Tab, each in its own buffer, jumping to its line
-- for grep results. With nothing marked, or a mark that is not a file (a help tag, say),
-- it does what Enter normally does with the entry under the cursor.
local function open_selected(prompt_bufnr)
  local selections = action_state.get_current_picker(prompt_bufnr):get_multi_selection()
  local all_files = #selections > 0
  for _, entry in ipairs(selections) do
    all_files = all_files and (entry.path or entry.filename) ~= nil
  end
  if not all_files then return actions.select_default(prompt_bufnr) end
  actions.close(prompt_bufnr)
  for _, entry in ipairs(selections) do
    vim.cmd.edit(vim.fn.fnameescape(entry.path or entry.filename))
    if entry.lnum then pcall(vim.api.nvim_win_set_cursor, 0, { entry.lnum, math.max((entry.col or 1) - 1, 0) }) end
  end
end

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
        ['<CR>'] = open_selected,
        -- Arrow keys do nothing, as in keymaps.lua; C-n and C-p move through results
        ['<Up>'] = function() end,
        ['<Down>'] = function() end,
        ['<Left>'] = function() end,
        ['<Right>'] = function() end,
      },
      n = {
        ['<CR>'] = open_selected,
        -- Arrow keys fall through to the do-nothing maps in keymaps.lua; j and k move through results
        ['<Up>'] = false,
        ['<Down>'] = false,
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

local builtin = require 'telescope.builtin'
vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = 'Find buffers' })
vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = 'Find files' })
vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = 'Find by grep' })
vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = 'Find help' })
vim.keymap.set('n', '<leader>fo', builtin.oldfiles, { desc = 'Find recently opened files' })
-- The same key as prefix g g in tmux, which opens lazygit on the changed files.
vim.keymap.set('n', '<leader>gg', builtin.git_status, { desc = 'Git changed files' })

-- Buffer-local, so buffers without an LSP keep Vim's own gd and gr.
vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('custom-telescope-lsp-attach', { clear = true }),
  callback = function(event)
    vim.keymap.set('n', 'gd', builtin.lsp_definitions, { buffer = event.buf, desc = 'Go to definition' })
    vim.keymap.set('n', 'gr', builtin.lsp_references, { buffer = event.buf, desc = 'Find references' })
  end,
})
