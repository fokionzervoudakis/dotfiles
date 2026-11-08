# Improve

Leftovers from /improve, so the next run can start here instead of re-auditing. Each line is stamped with the commit it was found at; a run deletes a line once its files have changed or it has acted on it.

- 2026-11-08 | cabf599 | .config/nvim/lua/custom/plugins/telescope.lua .config/nvim/lua/custom/plugins/orgmode.lua .config/nvim/init.lua | <leader>f is also a prefix - Kickstart's <leader>f (format buffer) shares its prefix with the personal <leader>fb/ff/fg/fh/fo/fl maps, so format waits out timeoutlen. Check: `nvim --headless -c 'lua for _,m in ipairs(vim.api.nvim_get_keymap("n")) do if m.lhs:match("^ f") then print(m.lhs) end end' -c qa`. Moving it means picking a new key, which is the user's call.
