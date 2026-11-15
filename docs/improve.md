# Improve

Leftovers from /improve, so the next run can start here instead of re-auditing. Each line is stamped with the commit it was found at; a run deletes a line once its files have changed or it has acted on it.

- 2026-11-15 | 750d131 | hooks/pre-push .config/nvim/lua/custom/plugins/mason.lua | Pre-push needs a stylua no recipe installs - `just git` enables the hook, whose `just lint` runs Mason's stylua, which exists only after Neovim has been opened once; on a fresh machine the first push fails. Check: the git recipe's dependencies install nvim but nothing launches it, and ls ~/.local/share/nvim/mason/bin/stylua on a new machine.
- 2026-11-15 | 750d131 | test/startup.bats | Tmux key test accepts a script that cannot run - "tmux keys run scripts that exist" tests [ -f ], so a script that lost its executable bit passes and the key does nothing. Check: read the test; it should use [ -x ].
- 2026-11-15 | 5ca0c98 | justfile | The test recipe's description leaves out zsh - the justfile comment says "the tmux config, the tmux scripts, and the Claude status line" but bats test also runs test/zsh.bats. Check: just --list | grep test.
