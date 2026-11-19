-- Print every formatter and LSP server the Neovim config uses but cannot run.
-- A missing one fails silently in the editor: the file saves unformatted, the server never starts.

local conform = require 'conform'
local missing = {}

for _, names in pairs(conform.formatters_by_ft) do
  for _, name in ipairs(names) do
    if not conform.get_formatter_info(name).available then missing['formatter ' .. name] = true end
  end
end

-- Servers whose cmd is a function (ts_ls) pick their binary at start time.
-- Run it with the process start swapped out to see the command; an in-process server (org) starts none.
vim.lsp.rpc.start = function(cmd) return cmd end
for _, config in ipairs(vim.lsp.get_configs { enabled = true }) do
  local cmd = config.cmd
  if type(cmd) == 'function' then cmd = cmd({}, {}) end
  if vim.islist(cmd) and vim.fn.executable(cmd[1]) == 0 then missing['lsp ' .. config.name .. ' (' .. cmd[1] .. ')'] = true end
end

-- ftplugin/java.lua hands jdtls to nvim-jdtls, so it is not among the configs above.
-- Run it with the start swapped out to see the command it would launch.
require('jdtls').start_or_attach = function(config)
  if vim.fn.executable(config.cmd[1]) == 0 then missing['lsp jdtls (' .. config.cmd[1] .. ')'] = true end
end
vim.cmd.runtime 'ftplugin/java.lua'

for line in vim.spairs(missing) do
  print(line)
end
