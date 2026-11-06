-- Only markers that exist once per project: every module of a multi-module
-- build has its own pom.xml or build.gradle, which would make the module the root.
local root_dir = vim.fs.root(0, { 'gradlew', '.git', 'mvnw' }) or vim.fn.getcwd()

local config = {
  -- Without -data, jdtls keeps its index in a temp dir named after the basename
  -- of Neovim's cwd, so two projects named alike share one index. Name it after
  -- the full root instead, the way 'undodir' names files (/ becomes %).
  cmd = { 'jdtls', '-data', vim.fn.stdpath 'cache' .. '/jdtls/' .. root_dir:gsub('/', '%%') },
  root_dir = root_dir,
}
require('jdtls').start_or_attach(config)
