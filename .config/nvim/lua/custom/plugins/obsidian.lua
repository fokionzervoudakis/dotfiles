vim.pack.add { { src = 'https://github.com/obsidian-nvim/obsidian.nvim', version = vim.version.range '*' } }

---@module 'obsidian'
---@type obsidian.config
require('obsidian').setup {
  legacy_commands = false,
  workspaces = {
    {
      name = 'my-notes',
      path = '~/repos/notes',
    },
  },
  frontmatter = {
    enabled = false,
  },
}
