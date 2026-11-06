local config = {
  cmd = { 'jdtls' },
  -- Only markers that exist once per project: every module of a multi-module
  -- build has its own pom.xml or build.gradle, which would make the module the root.
  root_dir = vim.fs.root(0, { 'gradlew', '.git', 'mvnw' }),
}
require('jdtls').start_or_attach(config)
