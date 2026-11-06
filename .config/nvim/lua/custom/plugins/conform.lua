require('conform').setup {
  formatters_by_ft = {
    bash = { 'shfmt' },
    css = { 'prettier' },
    go = { 'goimports' },
    html = { 'prettier' },
    javascript = { 'prettier' },
    json = { 'jq' },
    lua = { 'stylua' },
    proto = { 'buf' },
    sh = { 'shfmt' },
    sql = { 'sql_formatter' },
    typescript = { 'prettier' },
  },
  format_on_save = { timeout_ms = 500 },
}
