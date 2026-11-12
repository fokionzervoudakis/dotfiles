# Improve

Leftovers from /improve, so the next run can start here instead of re-auditing. Each line is stamped with the commit it was found at; a run deletes a line once its files have changed or it has acted on it.

- 2026-11-12 | fcdf7fb | .gitconfig | git v breaks on paths with spaces - git status -s wraps such paths in quotes and xargs splits on whitespace, so nvim opens '"my' and 'file"'; check with: touch 'a b' && git v.
