# Improve

Leftovers from /improve, so the next run can start here instead of re-auditing. Each line is stamped with the commit it was found at; a run deletes a line once its files have changed or it has acted on it.

- 2026-11-06 | 7c51ba7 | .config/zsh/kubectl.zsh | ctldescribe runs unfiltered on Esc - if the fzf picker is cancelled, `$(__kpick pods --multi)` is empty and `kubectl describe pod` dumps every pod in the namespace; the other aliases just error out. Check with kubectl installed: run ctldescribe, press Esc. Untested here because kubectl is not installed.
- 2026-11-06 | 7c51ba7 | .config/nvim/lua/keymaps.lua .config/nvim/init.lua | <leader>s and <leader>d are also prefixes - Kickstart's <leader>s* search maps and keymaps.lua's own <leader>db make the next-spelling and next-diagnostic maps wait out timeoutlen. Check: `nvim --headless -c 'lua for _,m in ipairs(vim.api.nvim_get_keymap("n")) do if m.lhs:match("^ [sd]") then print(m.lhs) end end' -c qa`. Moving them means picking new keys, which is the user's call.
