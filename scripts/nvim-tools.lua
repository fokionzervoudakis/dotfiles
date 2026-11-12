-- Print every formatter and LSP server the Neovim config uses but cannot run.
-- A missing one fails silently in the editor: the file saves unformatted, the server never starts.

local conform = require 'conform'
local missing = {}

for _, names in pairs(conform.formatters_by_ft) do
  for _, name in ipairs(names) do
    if not conform.get_formatter_info(name).available then missing['formatter ' .. name] = true end
  end
end

-- Servers whose cmd is a function (ts_ls, org) build it at start time, so there is no binary to check
for _, config in ipairs(vim.lsp.get_configs { enabled = true }) do
  local cmd = config.cmd
  if type(cmd) == 'table' and vim.fn.executable(cmd[1]) == 0 then missing['lsp ' .. config.name .. ' (' .. cmd[1] .. ')'] = true end
end

for line in vim.spairs(missing) do
  print(line)
end
