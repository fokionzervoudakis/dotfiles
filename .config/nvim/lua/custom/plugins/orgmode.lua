vim.pack.add {
  'https://github.com/nvim-orgmode/orgmode',
  'https://github.com/nvim-orgmode/org-bullets.nvim',
}

require('orgmode').setup {
  org_agenda_files = '~/repos/orgfiles/**/*',
  org_default_notes_file = '~/repos/orgfiles/refile.org',
}
require('org-bullets').setup()
vim.lsp.enable 'org'

vim.pack.add { 'https://github.com/chipsenkbeil/org-roam.nvim' }

require('org-roam').setup {
  directory = '~/repos/orgfiles',
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

vim.keymap.set('n', '<leader>fl', function() require('orgmode').action 'org_mappings.open_at_point' end, { desc = 'Org: Open URL at point' })
