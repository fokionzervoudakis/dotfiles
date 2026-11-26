vim.pack.add {
  'https://github.com/nvim-orgmode/orgmode',
  'https://github.com/nvim-orgmode/org-bullets.nvim',
}

local org_dir = vim.fn.expand '~/repos/orgfiles'

require('orgmode').setup {
  org_agenda_files = org_dir .. '/**/*',
  org_default_notes_file = org_dir .. '/refile.org',
}
require('org-bullets').setup()
vim.lsp.enable 'org'

vim.pack.add { 'https://github.com/chipsenkbeil/org-roam.nvim' }

-- Skip org-roam when the notes folder is missing, so it does not create an empty one
if vim.fn.isdirectory(org_dir) == 1 then
  require('org-roam').setup {
    directory = org_dir,
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
end

vim.keymap.set('n', '<leader>fl', function() require('orgmode').action 'org_mappings.open_at_point' end, { desc = 'Org: Open URL at point' })
