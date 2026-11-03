# Improve

Leftovers from /improve, so the next run can start here instead of re-auditing. Each line is stamped with the commit it was found at; a run deletes a line once its files have changed or it has acted on it.

- 2026-11-03 | 29293e9 | .config/nvim/lua/custom/plugins/conform.lua | Drop gofmt from the Go formatters - goimports already formats like gofmt, so `go = { 'gofmt', 'goimports' }` runs a redundant process on every save; check by running both on a Go file and diffing.
- 2026-11-03 | 29293e9 | .config/nvim/lua/keymaps.lua .config/nvim/init.lua | Leader keys that are also prefixes - `<leader>s` (next spelling error) sits under Kickstart's `<leader>s*` search group and `<leader>d` (next diagnostic) under `<leader>db`, so each waits out timeoutlen before firing; check with `:map <leader>s` and by pressing it. Rebinding is a taste call, so ask before changing.
- 2026-11-03 | 29293e9 | .config/nvim/lua/custom/plugins/telescope.lua .config/nvim/init.lua | Redundant extension loads - telescope.lua's pcall loads of fzf and ui-select repeat the ones Kickstart's init.lua already ran; check by grepping init.lua for load_extension.
- 2026-11-03 | 29293e9 | .config/nvim/ftplugin/java.lua | Hardcoded Mason path - the jdtls cmd spells out ~/.local/share/nvim/mason/bin while Mason already puts that dir on PATH inside nvim, so `cmd = { 'jdtls' }` would do; check with `:echo exepath('jdtls')`.
