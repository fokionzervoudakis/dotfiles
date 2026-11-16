-- Mason and mason-tool-installer come from Kickstart, whose init.lua installs only its own servers.
-- Tools only Neovim uses are installed here; shell tools come from the justfile.
-- This list replaces the one init.lua gave mason-tool-installer rather than adding to it,
-- so Kickstart's two are repeated at the top. `just update` updates everything listed here.
require('mason-tool-installer').setup {
  ensure_installed = {
    'lua_ls', -- Kickstart's init.lua
    'stylua', -- Kickstart's init.lua; also run by `just lint`
    'buf', -- conform.nvim: proto
    'copilot-language-server', -- options.lua
    'goimports', -- conform.nvim: go
    'gopls', -- gopls, enabled below
    'jdtls', -- ftplugin/java.lua
    'prettier', -- conform.nvim: css, html, javascript, typescript
    'shfmt', -- conform.nvim: bash, sh
    'sql-formatter', -- conform.nvim: sql
    'typescript-language-server', -- ts_ls, enabled below
  },
}

-- nvim-lspconfig ships the ts_ls and gopls configs; they attach to JS/TS and Go buffers.
vim.lsp.enable 'ts_ls'
vim.lsp.enable 'gopls'
