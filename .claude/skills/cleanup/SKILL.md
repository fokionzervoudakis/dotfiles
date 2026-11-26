---
name: cleanup
description: Bring this machine back in line with the dotfiles repo - restow so new and renamed files are linked, remove symlinks left dangling by deleted files, install brew packages a recent justfile change asks for but this machine lacks, and offer to uninstall what the repo no longer asks for (orphaned vim.pack plugins, brew packages dropped from the justfile, leftover config dirs), and to restart a tmux server still running an older `.tmux.conf`. Use whenever the user says "restow", "sync my machine", "clean up after that", "is my machine in sync with the repo?", mentions they just pulled, added, renamed, or removed something, or invokes /cleanup - and offer it after /propose or /improve lands a change that adds, removes, or renames a file, plugin, or package. This changes the machine, not the repo; to fix the config use `improve`, to change the stack use `propose`.
---

# Cleanup

`propose` and `improve` change the repo; neither undoes what the repo stopped asking for. So `$HOME` drifts: a renamed file stays linked under its old name, `vim.pack` keeps a plugin directory after its spec is gone, a package whose `brew install` line was removed stays installed, a tmux server keeps a binding after its line is deleted from `.tmux.conf`, and a package whose line was added in a commit pulled from elsewhere never gets installed. Nothing errors, so nobody notices. This skill makes the machine match the repo as it stands now.

Most runs should find nothing, and then the whole output is one line. When there is residue, the user should be able to approve all of it in one glance.

```
cleanup

1. check     every section, from repo root  nothing found -> say so, stop
2. run       the free fixes                 restow, dangling links, missing packages
3. ask       once about the risky fixes     removes something or ends programs
4. run       what the user approved         except a tmux restart
5. verify    by rerunning every check
6. report    what changed or is left        no tmux restart -> stop
7. restart   tmux, if approved              -> stop
```

## Rules

- **Free** means it loses nothing and rerunning the recipe would do the same: restowing, deleting a dangling link, installing a missing package.
- **Ask** means it deletes data or software, or ends running programs. The repo can't recreate that state, so the user approves it first.
- **Never edit the repo or commit.** If the repo itself is wrong - a stray file stow would link, a recipe installing something nothing uses - report it and point to `/improve`.
- **Narrow commands only.** Each command touches the one item the user saw - no `brew autoremove` or `brew cleanup`.
- **Plain ASCII** in everything you output: `-` not dashes, straight quotes, `->` not arrows, no emoji.
- The history-based checks cover the last 20 commits plus uncommitted changes; if the user says the drift is older, raise the count.

## Stow

**Check** - conflicts, then the new links a restow would create. Stow links into `$HOME` (`--target ~`), so that is the target:

```sh
T=$HOME
dry=$(stow -n -v -R --no-folding --target ~ . 2>&1)
echo "$dry" | grep -E 'conflict|cannot stow'
echo "$dry" | awk '$1=="LINK:"{print $2}' | while read -r p; do
  [ -L "$T/$p" ] || echo "$p$(git ls-files --error-unmatch -- "$p" >/dev/null 2>&1 || echo '  (untracked)')"
done
```

**Read**

- A conflict is a real file where stow wants a link. Never delete it to make room; it may be the user's only copy. Diff it against the repo version.
- `(untracked)` marks a stray file that restowing would link into `$HOME`. This repo's `.gitignore` is a whitelist, so "ignored" says nothing about intent; judge each.

**Fix**

- Free: `stow -R --no-folding --target ~ .` (what `just stow` runs, minus installing stow).
- Ask: resolving a conflict, and restowing when an untracked file looks like a mistake.
- A conflict aborts the whole restow, so no new links land until it is resolved. Say so, and restow again once the user resolves it.

## Dangling links and leftover directories

**Check** - paths recently tracked whose link now points at nothing, or whose directory is gone from the repo but still in `$HOME`. `--no-renames`, or a rename hides its old path:

```sh
T=$HOME
{ git log -20 --no-renames --name-only --format=; git diff --name-only HEAD; } | sort -u | while read -r p; do
  [ -L "$T/$p" ] && [ ! -e "$T/$p" ] && echo "dangling: $T/$p -> $(readlink "$T/$p")"
  d=$(dirname "$p"); [ "$d" != . ] && [ ! -e "$d" ] && [ -d "$T/$d" ] && echo "leftover: $T/$d"
done | sort -u
```

**Read**

- A dangling link holds no data.
- A leftover directory is usually local state (history, caches). Look inside and say what is there.

**Fix**

- Free: `rm` each dangling link by path - no trailing slash, no `-r`. Do this even when a stow conflict blocks the restow.
- Ask: removing a leftover directory.

## Brew: missing packages

**Check** - packages a recently added `brew install` line asks for, still in the justfile, but not installed:

```sh
cur=$(grep -o 'brew install.*' justfile | sed -E 's/#.*//; s/brew install//' | tr ' ' '\n')
{ git log -20 -p --format= -- justfile; git diff HEAD -- justfile; } | grep -E '^\+[^+].*brew install' \
  | sed -E 's/#.*//; s/.*brew install//' \
  | awk '{k="--formula"; for(i=1;i<=NF;i++) if($i=="--cask") k="--cask"; for(i=1;i<=NF;i++) if($i !~ /^--/) print k, $i}' \
  | sort -u | while read -r k p; do
    echo "$cur" | grep -qxF "$p" && ! brew list "$k" "$p" >/dev/null 2>&1 && echo "missing: brew install $k $p"
  done
```

**Read**

- `brew list` already resolves aliases, so a `missing:` line means the package is not installed under any name.
- If `command -v <tool>` finds it outside Homebrew, report that instead of installing a second copy.

**Fix**

- Free: run each `missing:` line's command as printed, one package per command. Never run the whole recipe, which reruns its other commands.
- If an install fails, report the error and carry on with the rest.

## Brew: dropped packages

**Check** - installed packages whose `brew install` line was removed and that no recipe still installs:

```sh
{ git log -20 -p --format= -- justfile; git diff HEAD -- justfile; } | grep -E '^-[^-].*brew install' \
  | sed -E 's/#.*//; s/.*brew install//' | tr ' ' '\n' | grep -v -e '^--' -e '^$' | sort -u \
  | grep -vxFf <(grep -o 'brew install.*' justfile | sed -E 's/#.*//; s/brew install//' | tr ' ' '\n') \
  | grep -xFf <(brew list -1 --formula; brew list -1 --cask)
```

**Read**

- Check `brew uses --installed <pkg>`; if anything depends on it, it stays.
- Aliases can fake a removal (`npm` is `node`). Compare canonical names with `brew info --json=v2 <pkg> | jq -r '.formulae[].name, .casks[].token'`.
- If it is a general-purpose CLI the user may use outside this repo, say so in the question.

**Fix**

- Ask: `brew uninstall <pkg>`.

## vim.pack

**Check** - plugins nothing added at startup:

```sh
nvim --headless -c 'lua for _,p in ipairs(vim.pack.get()) do if not p.active then print(p.spec.name) end end' +qa 2>&1
```

**Read**

- Grep the config for the plugin's name first, in case it is added lazily rather than at startup.

**Fix**

- Ask: remove it through Neovim, so the lockfile stays consistent: `nvim --headless -c "lua vim.pack.del({ '<name>' })" +qa`.
- A changed `nvim-pack-lock.json` is expected afterwards. Mention it, since the user will want to commit it.

## tmux

**Check** - a server that started before `.tmux.conf` last changed, or that runs a tmux older than the installed one:

```sh
s=$(tmux display -p '#{start_time} #{version}' 2>/dev/null) && {
  [ "${s% *}" -lt "$(stat -f %m .tmux.conf)" ] && echo "stale: tmux server started before .tmux.conf last changed"
  [ "tmux ${s#* }" != "$(tmux -V)" ] && echo "stale: tmux server runs ${s#* }, installed is $(tmux -V)"
}
```

**Read**

- Reloading with `prefix r` applies added and changed lines, but a binding or option whose line was deleted stays until the server restarts.
- Restarting closes every session, window and pane and kills what runs in them. List them for the question: `tmux list-panes -a -F '#{session_name}:#{window_index} #{pane_current_command} #{pane_current_path}'`.
- If `$TMUX` is set, this Claude session is one of them. Say so.

**Fix**

- Ask: `tmux kill-server`. The next `tmux` starts a fresh server that reads `.tmux.conf` from scratch.
- Run it last, after the report. When `$TMUX` is set it kills this Claude session too, so nothing can run or be said after it. End the report by telling the user to run `tmux` to start the new server and `claude --continue` to pick this conversation back up.
- If `$TMUX` is unset, Claude survives: start nothing on the user's behalf, but confirm `tmux display -p '#{pid}'` now fails.

## Other residue

**Check** - skim `git log --oneline -20 --stat` for changes the sections above don't know about:

- A recipe line added that isn't a `brew install` (a `curl ... | bash` installer, a `git config`, a `brew alias`). Check its effect is present; if not, run that one line.
- A tool dropped from Mason's `ensure_installed`. Mason never uninstalls; the fix is `:MasonUninstall <name>`.
- A `brew tap` nothing needs.
- A cache naming a removed tool.

**Read**

- Report only what you verified is present, or verified missing.

**Fix**

- Free if it only adds what a recipe line asks for; ask if it removes anything.

## Ask once

List what needs approval, numbered: what it is, where, what's in it or what uses it, and the exact command. Ask with AskUserQuestion (All, Pick, None); on Pick, ask which numbers.

## Verify

- Rerun every Check: everything you acted on should be gone, and anything left should be what you said you'd leave.
- `nvim --headless +qa` starts clean.
- `zsh -i -c exit` starts clean, if anything shell-related changed.

## Report

Only what changed or still needs the user - no lines for clean checks, no `git status` recap. If nothing was done, the whole report is:

```
Machine matches the repo - nothing to clean up.
```

Otherwise, one line per item under the headings that apply:

- **Done** - restowed links and removed dangling links, by path; packages installed, by name
- **Removed** - what the user approved, and the command each ran
- **Left** - declined items, conflicts, and repo fixes for `/improve`
- **Verified** - one line: survey clean and tools start, or what didn't
- **Next** - an approved tmux restart, about to run
