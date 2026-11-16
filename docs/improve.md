# Improve

Leftovers from /improve, so the next run can start here instead of re-auditing. Each line is stamped with the commit it was found at; a run deletes a line once its files have changed or it has acted on it.

- 2026-11-15 | 750d131 | test/startup.bats | Tmux key test accepts a script that cannot run - "tmux keys run scripts that exist" tests [ -f ], so a script that lost its executable bit passes and the key does nothing. Check: read the test; it should use [ -x ].
