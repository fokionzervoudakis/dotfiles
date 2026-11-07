# Improve

Leftovers from /improve, so the next run can start here instead of re-auditing. Each line is stamped with the commit it was found at; a run deletes a line once its files have changed or it has acted on it.

- 2026-11-06 | 7c51ba7 | .config/nvim/lua/keymaps.lua .config/nvim/init.lua | <leader>s is also a prefix - Kickstart's <leader>s* search maps make the next-spelling map wait out timeoutlen. Check: `nvim --headless -c 'lua for _,m in ipairs(vim.api.nvim_get_keymap("n")) do if m.lhs:match("^ s") then print(m.lhs) end end' -c qa`. Moving it means picking a new key, which is the user's call.
