vim.pack.add { 'https://github.com/hat0uma/csvview.nvim' }

require('csvview').setup {
  view = { display_mode = 'border' },
}

-- Aligned view is the whole point of the plugin, so turn it on for every CSV.
-- Alignment is virtual text, so on-screen columns stop matching byte positions;
-- `:CsvViewDisable` drops back to raw text for column-precise edits.
vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'csv', 'tsv' },
  callback = function()
    vim.cmd 'CsvViewEnable'
  end,
})
