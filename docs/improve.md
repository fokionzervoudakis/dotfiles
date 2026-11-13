# Improve

Leftovers from /improve, so the next run can start here instead of re-auditing. Each line is stamped with the commit it was found at; a run deletes a line once its files have changed or it has acted on it.

- 2026-11-13 | e03b928 | scripts/nvim-tools.lua .config/nvim/ftplugin/java.lua .config/nvim/lua/custom/plugins/mason.lua | nvim tools check skips jdtls - ftplugin/java.lua starts jdtls through nvim-jdtls, not vim.lsp.enable, so the vim.lsp.get_configs loop never sees it and a missing binary passes `just test`; check with `nvim --headless -c 'lua print(vim.inspect(vim.tbl_map(function(c) return c.name end, vim.lsp.get_configs{enabled=true})))' +qa`, which lists no jdtls.
- 2026-11-13 | e03b928 | justfile hooks/pre-push scripts/test.sh | pre-push needs more than `just git` installs - the git recipe enables the hook, but the hook runs `just lint test`, which also needs tmux (terminal recipe), nvim and Mason's stylua (nvim recipe plus a first nvim start), so on a new machine pushes fail until those are run; check by reading the three files side by side.
