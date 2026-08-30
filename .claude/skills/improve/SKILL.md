---
name: improve
description: Audit this dotfiles repo for what is broken, stale, or dead - outright bugs, deprecated config idioms, redundant settings, formatting drift, and tools the config references but nothing installs - then apply the fixes you approve. Use this skill whenever the user wants to lint, audit, tidy, polish, or fix their dotfiles (zsh, Neovim Lua, tmux, wezterm, git, justfile), even if they don't name a specific file. Trigger on phrases like "improve my dotfiles", "clean up the configs", "is anything broken here?", or "anything stale in this repo?". This is the correctness pass; when the question is whether a plugin or tool should be added, removed, or replaced, use `propose` instead.
---

# Improve

Review the dotfiles repo, surface concrete improvements, and apply the ones the user approves. This is a **review-first** workflow: the user wants to see findings before anything changes, then green-light fixes.

## Why this shape

Dotfiles are personal and load-bearing — a "helpful" rewrite that changes behavior is worse than no change at all. So the job is to find real, defensible improvements and let the user decide. Bias toward fewer high-confidence findings over a long list of nitpicks. If a change is purely cosmetic and the user might reasonably prefer their current style, say so rather than asserting it's wrong.

## The stack

These are the file types you'll review and how to reason about each:

- **zsh** (`.zshrc`, `.zprofile`, `.config/zsh/*.zsh`) — shell config and aliases. `.zprofile` is login-only (environment and PATH); `.zshrc` is interactive (aliases, functions, tool init).
- **Neovim Lua** (`.config/nvim/**/*.lua`) — editor config and lazy.nvim plugin specs. `stylua.toml` defines the format (2-space, single quotes, no call parens, 160 col). `init.lua` is vendored Kickstart.nvim, kept close to upstream but edited in places; the user's own config lives in `lua/keymaps.lua`, `lua/options.lua`, and `lua/custom/plugins/*.lua`, which load after Kickstart and intentionally override it. Don't restyle `init.lua` or report it as conflicting with the custom files, but do read it for correctness (see Notes).
- **tmux** (`.tmux.conf`), **wezterm** (`.wezterm.lua`), **git** (`.gitconfig`, `.gitignore`), **just** (`justfile`), **bat** (`.config/bat/config`), **lazygit** (`.config/lazygit/config.yml`), plus small dotfiles (`.irbrc`, `.luarc.json`).
- **git hooks** (`hooks/pre-push`) — POSIX sh, activated by `just git` setting `core.hooksPath`. The only executable file in the repo: a bug here blocks pushes, and any tool it invokes must have an install recipe in the justfile.

## Workflow

### 1. Detect tooling first

Some checks rely on external tools that may not be installed. Probe before relying on them, and fall back to manual reading when missing — never skip a file just because its linter isn't present. Run the tools rather than using `command -v` — a shim whose interpreter is gone still resolves as present.

```
stylua --version
```

- `zsh -n <file>` checks shell syntax and is always available. There is no zsh formatter: `shfmt` does not parse zsh, so don't reach for it — review shell formatting by eye.
- `stylua` may be missing. If present, use `stylua --check` against `.config/nvim/stylua.toml`. If absent, check formatting by eye against the stylua.toml rules; don't install it unprompted.

### 2. Review, grouped by what matters

Scan every config file. Sort findings into these buckets, because they carry very different stakes:

- **Bugs / correctness** — things that are silently broken or wrong: bad paths, misspelled option names, make-isms in the justfile (`$(HOME)` instead of `$HOME`), keymaps that shadow each other, options that no longer exist. These are the most valuable finds.
- **Deprecated / outdated idioms** — APIs the tools have moved past: e.g. Neovim's `vim.lsp.buf_get_clients` → `vim.lsp.get_clients`, `vim.tbl_islist` → `vim.islist`, `vim.highlight` → `vim.hl`; zsh `export` in `.zshrc` where `.zprofile` is the right file; tmux options renamed across versions. Explain what changed and why the new form is preferred.
- **Dead / redundant** — commented-out cruft, duplicated settings, plugins configured but never loaded, conflicting keymaps, redundant PATH edits. Exception: a keymap, option, or plugin opt set in a custom file (`lua/keymaps.lua`, `lua/options.lua`, `lua/custom/plugins/*.lua`) that also appears in `init.lua` is a deliberate override of the Kickstart baseline, not a conflict or duplicate. Don't flag it. Only report conflicts *among the custom files themselves*.
- **Referenced but never installed** — config that names an external binary nothing in this repo installs. See below; this is the bucket most likely to hold something real, because it is the one that survives every other kind of review.
- **Formatting** — what `stylua` would change. Group these together; they're low-stakes and bulk-applicable.

For each finding, give `file:line`, what it is, and the specific fix. Keep it scannable.

### 2a. Check that referenced tools actually exist

Config that names a binary is the one thing you cannot verify by reading. `formatters_by_ft = { sh = { 'shfmt' } }` is valid Lua, correctly formatted, using a current API - and completely inert if `shfmt` isn't installed. Nothing in the file is wrong, so every other bucket walks straight past it. That's why this failure mode accumulates silently, and why it's worth checking directly on every run.

Ask three separate questions, because they fail differently:

- **Is it on this machine now?** If not, that feature is dead *today* and the user probably doesn't know. Test with `command -v <tool>`.
- **Would a fresh machine get it?** A tool can be on `$PATH` because it was installed by hand years ago. The repo is only self-installing if something here brings it in. Two places do that: `justfile` recipes (`brew install ...`) and Kickstart's `mason-tool-installer` `ensure_installed` list in `init.lua`. Note that Kickstart ships that list empty, so unless it was filled in, mason installs nothing beyond the LSP servers.
- **Is the copy on `$PATH` the one this repo installs?** Passing both checks above still isn't proof. `command -v` reports whichever copy wins the `$PATH` race, which need not be the recipe's - resolve it with `ls -l $(command -v <tool>)` and see what it actually points at. This goes wrong three ways, all of which look healthy from the outside: the recipe's formula ships a differently named binary (`sevenzip` provides `7zz`, so a `7z` on `$PATH` came from somewhere else), an earlier `$PATH` entry shadows it (`.zprofile` puts `$GOPATH/bin` ahead of Homebrew), or a different package manager put it there. Each one works today and dies on a fresh machine.

A tool can fail one of these or several. Missing from `$PATH` *and* uninstallable is broken now; present but uninstallable, or present from somewhere other than the recipe, is a bootstrap trap that only bites on a new machine. Say which, since the urgency differs.

Where to look for referenced tools: `conform.nvim`'s `formatters_by_ft`, plugin specs that shell out to a binary, zsh aliases and functions wrapping a CLI, `tmux`/`wezterm` commands, git aliases, and `hooks/pre-push`. Sweeping the whole set at once is cheap:

```sh
for t in <tools you found>; do command -v "$t" >/dev/null || echo "MISSING: $t"; done
grep -n "$t" justfile   # and check init.lua's ensure_installed
```

The fix is usually a one-line `justfile` addition, so group these together and name the recipe each belongs in.

### 3. Present, then wait

Show the findings grouped by bucket (bugs first). Don't edit yet. End with a clear question like: "Which of these should I apply? (all / bugs only / pick by number / none)".

Respect the answer precisely — apply only what's approved. This is the whole point of the review-first shape; applying unapproved changes breaks the user's trust in the skill.

### 4. Apply and verify

After approval, make surgical edits — touch only the approved lines, match surrounding style. Then verify what you changed:

- zsh files: `zsh -n <file>` (syntax; no output means clean). There is no formatting check to run — compare against the surrounding style by eye.
- Lua files: `stylua --check <file>` if available.
- Re-read each edit to confirm it's what you intended.

Report exactly what changed (file + one-line summary each) and the verification result. If a verification fails, say so and fix it — don't leave a half-applied change.

## Notes

- Don't touch `.claude/skills/**` content unless asked — those are skills, not config to lint.
- `.config/nvim/init.lua` is vendored Kickstart.nvim and is meant to stay close to upstream. Don't reformat it, don't flag its upstream idioms as outdated, and never report it as conflicting with or duplicated by the custom files — those files exist to override it.

  But vendored does not mean unread. This file has been edited, and wherever it diverges from upstream those lines are the user's own, reviewed by nothing else in this repo. They are also the easiest thing here to miss, because the file reads as boilerplate. The tell is a value that breaks the contract of the structure holding it: the `servers` table is typed `---@type table<string, vim.lsp.Config>` and every key is handed to `vim.lsp.config()` and `vim.lsp.enable()`, so a formatter parked in it is being registered as a language server. Mason installs the binary either way, so formatting still works and the bad registration stays invisible - which is exactly why it survives.
- If the repo is clean and you find nothing worth changing, say that plainly. A short "looks good, here are two optional nits" is a fine outcome — don't manufacture findings to look busy.
