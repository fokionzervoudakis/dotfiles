# Improve

Leftovers from /improve, so the next run can start here instead of re-auditing. Each line is stamped with the commit it was found at; a run deletes a line once its files have changed or it has acted on it.

- 2026-11-10 | a1486cf | .tmux.conf | Stale pick-dir comment - the comment above `bind f` in .tmux.conf says it picks "from zoxide and the repos", but pick-dir only reads `zoxide query -l`; check with grep -n repos .tmux.conf .config/tmux/pick-dir.
