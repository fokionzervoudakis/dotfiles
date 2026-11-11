---
name: cleanup
description: Bring this machine back in line with the dotfiles repo - restow so new and renamed files are linked, remove symlinks left dangling by deleted files, install brew packages a recent justfile change asks for but this machine lacks, and offer to uninstall what the repo no longer asks for (orphaned vim.pack plugins, brew packages dropped from the justfile, leftover config dirs). Use whenever the user says "restow", "sync my machine", "clean up after that", "is my machine in sync with the repo?", mentions they just pulled, added, renamed, or removed something, or invokes /cleanup - and offer it after /propose or /improve lands a change that adds, removes, or renames a file, plugin, or package. This changes the machine, not the repo; to fix the config use `improve`, to change the stack use `propose`.
---

# Cleanup

`propose` and `improve` change the repo; neither undoes what the repo stopped asking for. So `$HOME` drifts: a renamed file stays linked under its old name, `vim.pack` keeps a plugin directory after its spec is gone, a package whose `brew install` line was removed stays installed, and one whose line was added in a commit pulled from elsewhere never gets installed. Nothing errors, so nobody notices. This skill makes the machine match the repo as it stands now.

Most runs should find nothing, and then the whole output is one line. When there is residue, the user should be able to approve all of it in one glance.

## Rules

- **Free:** restowing and deleting symlinks into this repo whose target is gone. Stow is idempotent and refuses to overwrite real files, and a dangling link holds no data, so both are undone by rerunning stow.
- **Free:** `brew install` for a package a recently added justfile line asks for and that is missing here - it is what the recipe would install, and nothing is lost. Install only the missing package, never the whole recipe, which reruns its other commands.
- **Ask first, once, as a list:** anything that deletes data or software - `vim.pack.del()`, `brew uninstall`, removing a leftover directory, resolving a stow conflict. These hold state the repo can't recreate.
- **Never edit the repo or commit.** If the repo itself is wrong - a stray file stow would link, a recipe installing something nothing uses - report it and point to `/improve`.
- **Plain ASCII** in everything you output: `-` not dashes, straight quotes, `->` not arrows, no emoji.

## 1. Survey

Run from the repo root. All read-only; empty output means nothing to do. Stow links into the repo's *parent* directory, so that is the target:

```sh
T=$(dirname "$PWD")
dry=$(stow -n -v -R --no-folding . 2>&1)

# Conflicts: a real file where stow wants a link
echo "$dry" | grep -E 'conflict|cannot stow'

# New links a restow would create; stow links the working tree, so flag untracked files
echo "$dry" | awk '$1=="LINK:"{print $2}' | while read -r p; do
  [ -L "$T/$p" ] || echo "$p$(git ls-files --error-unmatch -- "$p" >/dev/null 2>&1 || echo '  (untracked)')"
done

# Dangling links and leftover dirs for paths recently tracked; --no-renames, or a rename hides its old path
{ git log -20 --no-renames --name-only --format=; git diff --name-only HEAD; } | sort -u | while read -r p; do
  [ -L "$T/$p" ] && [ ! -e "$T/$p" ] && echo "dangling: $T/$p -> $(readlink "$T/$p")"
  d=$(dirname "$p"); [ "$d" != . ] && [ ! -e "$d" ] && [ -d "$T/$d" ] && echo "leftover: $T/$d"
done | sort -u

# vim.pack plugins nothing added at startup
nvim --headless -c 'lua for _,p in ipairs(vim.pack.get()) do if not p.active then print(p.spec.name) end end' +qa 2>&1

# Installed packages whose `brew install` line was removed and that no recipe still installs
{ git log -20 -p --format= -- justfile; git diff HEAD -- justfile; } | grep -E '^-[^-].*brew install' \
  | sed -E 's/#.*//; s/.*brew install//' | tr ' ' '\n' | grep -v -e '^--' -e '^$' | sort -u \
  | grep -vxFf <(grep -o 'brew install.*' justfile | sed -E 's/#.*//; s/brew install//' | tr ' ' '\n') \
  | grep -xFf <(brew list -1 --formula; brew list -1 --cask)

# Packages a recently added `brew install` line asks for, still in the justfile, but not installed
cur=$(grep -o 'brew install.*' justfile | sed -E 's/#.*//; s/brew install//' | tr ' ' '\n')
{ git log -20 -p --format= -- justfile; git diff HEAD -- justfile; } | grep -E '^\+[^+].*brew install' \
  | sed -E 's/#.*//; s/.*brew install//' \
  | awk '{k="--formula"; for(i=1;i<=NF;i++) if($i=="--cask") k="--cask"; for(i=1;i<=NF;i++) if($i !~ /^--/) print k, $i}' \
  | sort -u | while read -r k p; do
    echo "$cur" | grep -qxF "$p" && ! brew list "$k" "$p" >/dev/null 2>&1 && echo "missing: brew install $k $p"
  done
```

The history-based checks cover the last 20 commits plus uncommitted changes; if the user says the drift is older, raise the count.

Then skim `git log --oneline -20 --stat` for residue those commands don't know about - a recipe line added that isn't a `brew install` (a `curl ... | bash` installer, a `git config`, a `brew alias`; check its effect is present, and if not, run that one line), a tool dropped from Mason's `ensure_installed` (Mason never uninstalls; `:MasonUninstall <name>`), a `brew tap` nothing needs, a cache naming a removed tool. Report only what you verified is present, or verified missing.

## 2. Judge the findings

- **Conflict** - never delete the real file to make room; it may be the user's only copy. Diff it against the repo version and put it on the ask-list.
- **`(untracked)` new link** - a stray file restowing would link into `$HOME`. This repo's `.gitignore` is a whitelist, so "ignored" says nothing about intent; judge each. If it looks like a mistake, ask before restowing.
- **Leftover directory** - usually local state (history, caches). Say what's inside before offering to remove it.
- **Orphaned plugin** - grep the config for its name first, in case it is added lazily rather than at startup.
- **Brew package** - check `brew uses --installed <pkg>`; if anything depends on it, it stays. Aliases can fake a removal (`npm` is `node`), so compare canonical names with `brew info --json=v2 <pkg> | jq -r '.formulae[].name, .casks[].token'`. If it is a general-purpose CLI the user may use outside this repo, say so in the question.
- **Missing package** - `brew list` already resolves aliases, so a `missing:` line means it is not installed under any name. If it was installed by other means (`command -v <tool>` finds it outside Homebrew), report that instead of installing a second copy.

## 3. Restow, remove dangling links, install missing packages

Run `stow -R --no-folding .` (what `just stow` runs, minus installing stow), then `rm` each dangling link by path - no trailing slash, no `-r`. A conflict aborts the whole restow, so no new links land until it is resolved; say so, still remove the dangling links, and restow again once the user resolves it.

Then run each `missing:` line's command as printed, one package per command. If an install fails, report the error and carry on with the rest.

## 4. Ask once

List what needs approval, numbered: what it is, where, what's in it or what uses it, and the exact command. Ask with AskUserQuestion (All, Pick, None); on Pick, ask which numbers. Keep each command as narrow as its item - no `brew autoremove` or `brew cleanup`, which reach packages the user never saw. Remove plugins through Neovim so the lockfile stays consistent:

```sh
nvim --headless -c "lua vim.pack.del({ 'name' })" +qa
```

## 5. Verify

Rerun step 1: everything you acted on should be gone, and anything left should be what you said you'd leave. Check `nvim --headless +qa` starts clean, and `zsh -i -c exit` if anything shell-related changed. A changed `nvim-pack-lock.json` is expected after `vim.pack.del` - mention it, since the user will want to commit it.

## 6. Report

Only what changed or still needs the user - no lines for clean checks, no `git status` recap. If nothing was done, the whole report is:

```
Machine matches the repo - nothing to clean up.
```

Otherwise, one line per item under the headings that apply:

- **Done** - restowed links and removed dangling links, by path; packages installed, by name
- **Removed** - what the user approved, and the command each ran
- **Left** - declined items, conflicts, and repo fixes for `/improve`
- **Verified** - one line: survey clean and tools start, or what didn't
