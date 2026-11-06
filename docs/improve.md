# Improve

Leftovers from /improve, so the next run can start here instead of re-auditing. Each line is stamped with the commit it was found at; a run deletes a line once its files have changed or it has acted on it.

- 2026-11-06 | f340f40 | .zshrc | zshaddhistory drops function definitions - a line like `foo() { echo; }` typed at the prompt has first word `foo`, which whence cannot resolve yet, so it is never saved; check with `zsh -c 'emulate -L zsh -o extended_glob; first=${${(z)"$(printf "foo() { echo; }\n")"}[1]}; whence -- $first'`
