-- mini.icons (code block language icons) comes from Kickstart's mini.nvim.
vim.pack.add { 'https://github.com/MeanderingProgrammer/render-markdown.nvim' }

require('render-markdown').setup {
  -- Render .md files only; by default it also renders git commit messages as Markdown.
  injections = { gitcommit = { enabled = false } },
}
