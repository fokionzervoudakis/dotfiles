require('conform').setup {
  formatters_by_ft = {
    bash = { 'shfmt' },
    css = { 'prettier' },
    go = { 'gofmt', 'goimports' },
    html = { 'prettier' },
    javascript = { 'prettier' },
    json = { 'jq' },
    lua = { 'stylua' },
    proto = { 'buf' },
    ruby = { 'rubocop' },
    sh = { 'shfmt' },
    sql = { 'sql_formatter' },
    typescript = { 'prettier' },
  },
  format_on_save = function(bufnr)
    local disable_filetypes = { c = true, cpp = true }
    if disable_filetypes[vim.bo[bufnr].filetype] then
      return nil
    end
    return { timeout_ms = 500 }
  end,
}
