vim.pack.add {
  'https://github.com/nvim-orgmode/orgmode',
  'https://github.com/nvim-orgmode/org-bullets.nvim',
}

require('orgmode').setup {
  org_agenda_files = '~/orgfiles/**/*',
  org_default_notes_file = '~/orgfiles/refile.org',
}
require('org-bullets').setup()
vim.lsp.enable 'org'

vim.pack.add { { src = 'https://github.com/chipsenkbeil/org-roam.nvim', version = '0.2.0' } }

require('org-roam').setup {
  directory = '~/orgfiles',
  templates = {
    d = {
      description = 'default',
      template = '%?',
      target = '%<%Y%m%d%H%M%S>-%[slug].org',
    },
    w = {
      description = 'work',
      template = '%?',
      target = 'work/%<%Y%m%d%H%M%S>-%[slug].org',
    },
  },
}

vim.keymap.set('n', '<leader>fl', function()
  require('orgmode').action 'org_mappings.open_at_point'
end, { desc = 'Org: Open URL at point' })
