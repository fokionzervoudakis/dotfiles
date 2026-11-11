# Improve

Leftovers from /improve, so the next run can start here instead of re-auditing. Each line is stamped with the commit it was found at; a run deletes a line once its files have changed or it has acted on it.

- 2026-11-11 | 72f0bda | .config/tmux/pick-dir | pick-dir breaks on paths with commas - the list-panes filter splices $dir raw into `#{==:#{pane_current_path},$dir}`, so a "," or "}" in the path splits the format and the existing window is never matched (a duplicate opens); check by picking a dir like ~/tmp/a,b twice.
