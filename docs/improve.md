# Improve

Leftovers from /improve, so the next run can start here instead of re-auditing. Each line is stamped with the commit it was found at; a run deletes a line once its files have changed or it has acted on it.

- 2026-11-14 | 4d22163 | justfile hooks/pre-push | pre-push needs more than `just git` installs - the git recipe enables the hook, but the hook runs `just lint test`, which also needs stow, tmux, fzf and jq (stow, terminal, shell and jq recipes), nvim and Mason's stylua (nvim recipe plus a first nvim start), so on a new machine pushes fail until those are run; check by reading the hook, the lint and test recipes and the commands the .bats files call.
