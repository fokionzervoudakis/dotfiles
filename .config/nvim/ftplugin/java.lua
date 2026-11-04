local config = {
  cmd = { 'jdtls' },
  root_dir = require('jdtls.setup').find_root { '.git', 'pom.xml', 'build.gradle', 'build.gradle.kts' },
}
require('jdtls').start_or_attach(config)
