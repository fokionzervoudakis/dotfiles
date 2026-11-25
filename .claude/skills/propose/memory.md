# Lessons from propose

Written by /distill from propose's verdicts. Numbers are permanent.

1. When a candidate is a new command, option, check or recipe whose benefit comes only in a situation that happens rarely (backdating an entry, a rate-limited fetch, a new machine, a data error) and nothing is broken today, do not pitch it; pick something the user meets on most runs.
   - Short: rare-situation benefit
   - Example: macros "Log a past date" was rejected as adding complexity for a rare case.
   - Scope: all repos
   - Evidence: macros 2026-10-24 "Log a past date"; macros 2026-10-15 "Day notes in the journal"; macros 2026-10-11 "Data check command"; macros 2026-09-26 "Save day as template"; piggy-bank 2026-10-22 "Fetch selected series"; dotfiles 2026-11-17 "Run the bootstrap on a clean Mac after every push"; dotfiles 2026-11-13 "Add an apps recipe"

2. When a candidate adds a table that breaks an existing summary down into finer rows (per deposit, per month, per food, per account group), do not pitch it; the summary the view already prints is enough.
   - Short: finer breakdown of a summary
   - Example: piggy-bank "Per-deposit breakdown in cost_basis" was rejected as more granular than necessary.
   - Scope: all repos
   - Evidence: piggy-bank 2026-10-17 "Per-deposit breakdown in cost_basis"; piggy-bank 2026-10-15 "BTC position history"; piggy-bank 2026-10-05 "Wrapper breakdown"; macros 2026-10-04 "Eaten amounts view"

3. When a candidate replaces a small hand edit of a data file (one amount, one row) with a new command or an automatic lookup, do not pitch it; the hand edit is easy enough.
   - Short: hand edit is easy enough
   - Example: macros "Log a single food" was rejected because editing the CSV by hand is easy enough.
   - Scope: all repos
   - Evidence: piggy-bank 2026-10-11 "BTC as an account unit"; macros 2026-10-23 "Log a single food"

4. When a candidate adds an editor aid for typing, linting or debugging code or prose by hand (grammar checker, inline linter, debugger), do not pitch it; code and text are no longer written by hand in the editor.
   - Short: aid for hand editing
   - Example: "Debug Go tests inside Neovim" was rejected because code is no longer written or debugged by hand in an editor.
   - Scope: dotfiles
   - Evidence: dotfiles 2026-11-20 "Grammar checking in Neovim with Harper"; dotfiles 2026-11-11 "golangci-lint findings inline in Neovim"; dotfiles 2026-10-31 "Debug Go tests inside Neovim"

5. When a candidate swaps in or adds a tool for an existing workflow, first confirm from its docs or a test that it supports what the repo actually uses (the link syntax in the notes, the jumps the current plugin gives, the permission mode Claude runs in), and do not pitch it if it does not.
   - Short: confirm the tool supports the workflow
   - Example: markdown-oxide was rejected because it cannot follow the block links the notes use.
   - Scope: dotfiles
   - Evidence: dotfiles 2026-11-13 "Follow note links in Neovim with markdown-oxide"; dotfiles 2026-10-16 "Drop nvim-jdtls for lspconfig's jdtls"; dotfiles 2026-11-13 "Sandbox Claude's shell commands"
