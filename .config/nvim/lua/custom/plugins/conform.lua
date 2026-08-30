-- conform.nvim is installed and configured by Kickstart. Only the filetype map is ours,
-- so assign into it rather than calling setup again, which would drop Kickstart's
-- format_on_save and notify_on_error settings.
local conform = require 'conform'

conform.formatters_by_ft = vim.tbl_extend('force', conform.formatters_by_ft or {}, {
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
})
