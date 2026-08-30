---
name: commit
description: Stage all changes and create one or more Git commits using the Commitizen / Conventional Commits structure (type(scope): subject), splitting unrelated changes into separate commits. Use whenever the user wants to commit, "make a commit", "commit my changes", "commit this", or asks for a conventional/commitizen-style commit. If there is nothing to commit, say so and stop.
---

Commit the working tree using the Commitizen (Conventional Commits) format, splitting unrelated changes into separate commits rather than lumping them into one.

**Steps**

1. **Check for changes**

   Run:
   ```bash
   git status --porcelain
   ```
   If the output is empty, tell the user there is nothing to commit and stop. Don't stage, don't commit.

2. **Flag anything worth a second look**

   Scan the `git status --porcelain` output for files matching patterns like
   `.env`, `*.pem`, `*.key`, `*.p12`, `*secret*`, `*credential*`, `*password*`, `*token*`.

   Then, when you read the diff in step 4, watch for work that looks unfinished: debug prints, commented-out blocks, `TODO` scaffolding, placeholder values left in place.

   List whatever you find so the user knows what is about to land. These are heads-ups, not gates - proceed unless the user has told you otherwise. The user usually knows something you don't; a stray debug line may well be deliberate. Naming it costs a sentence, and stalling on it costs more than it saves.

3. **Stage everything**

   ```bash
   git add -A
   ```

   Staging first is what makes the next step possible: untracked files don't show up in a diff until they're in the index, and you can't judge what belongs together without seeing everything at once. This is not a commitment to one commit - step 5 may unstage and regroup.

   If the user asks for staged changes only, skip this step and commit the index as it stands. A curated index is a deliberate choice about what belongs in this commit; `git add -A` would discard that intent, and so would regrouping it in step 5.

4. **Read the diff**

   ```bash
   git diff --staged
   ```
   Understand what changed and why so the message reflects intent, not just file names.

5. **Decide the commit boundaries**

   A commit is a unit of intent, not a unit of time. Everything in the working tree arrived together, but that's an accident of when you happened to run this command - it says nothing about whether the changes belong together.

   Ask: **would anyone ever want to revert one of these changes without the others?** If yes, they belong in separate commits. A mixed commit forces an all-or-nothing revert, and it makes `git bisect` land on a commit with several candidate causes - which is the exact ambiguity bisect exists to remove.

   A second tell: if you can't pick a Conventional Commit type without lying about part of the diff, the commit is doing too much. A change set that is genuinely `fix` *and* `perf` *and* `style` is three commits wearing a trenchcoat.

   Push back against over-splitting just as hard. The goal is the fewest commits that pass the revert test, not the most commits you can justify. A zero-risk cleanup - a rename, a formatting fix, a keymap rewritten with identical behavior - has nothing to revert on its own, so fold it into whichever commit it sits nearest. A one-line commit nobody would ever revert in isolation is noise in the log, not precision.

   One hard limit on splitting: **each commit has to stand on its own.** If a group only makes sense alongside another - a function renamed in one file and its call sites in another, a config key and the code that reads it - then splitting them produces commits that don't individually work. A broken commit in the history defeats the bisect this whole step exists to protect, which makes that split worse than no split at all. When the revert test says "separate" but the pieces can't stand alone, keep them together and say why.

   To commit in groups, unstage and re-stage per group:

   ```bash
   git reset                                   # unstage everything, working tree untouched
   git add <paths for this group>
   ```

   Then run steps 6 and 7 for each group in turn. When one file holds two genuinely unrelated changes, `git add -p` can stage it by hunk - worth it only when the mixture would otherwise force a bad commit message.

   Don't ask for approval on the boundaries. These commits are local and unpushed, so a grouping the user would have drawn differently costs one `git rebase -i` to fix - cheaper than a round trip on every commit. Say which groups you chose and why in your summary so the split can be judged after the fact.

   That is license to decide, not license to guess. It covers where the lines go once you understand the diff - not the case where you don't understand it, which step 6 handles.

6. **Write a Commitizen message**

   Format: `type(scope): subject`

   - **type** (required): one of `feat`, `fix`, `docs`, `style`, `refactor`, `perf`, `test`, `build`, `ci`, `chore`, `revert`.
   - **scope** (optional): a lowercase noun for the area touched, e.g. `(zsh)`, `(nvim)`, `(claude)`. Drop it if the change is broad or no clear scope fits - a missing scope is better than a vague one.
   - **subject** (required): imperative mood ("add", not "added"/"adds"), lowercase first word, no trailing period.

   Use only ASCII characters in the message - no smart quotes, em dashes, or emoji. Stick to plain `'`, `"`, `-`, and standard ASCII punctuation.

   Keep it concise - aim for a subject under ~50 characters that captures the *what* and *why*, not the *how*. Most messages are a single line with no body. Only add a body (blank line, then prose) when the reasoning genuinely won't fit in the subject; skip it otherwise.

   If you genuinely can't tell what a change is for - a vendored or generated file, an opaque blob, a diff whose purpose isn't inferable from the code around it - say so and ask instead of picking a plausible-sounding type. A wrong `feat:` or `fix:` is worse than a question, because it reads as authoritative in `git log` forever and nothing about it looks wrong later. This is the one place in the workflow where stopping beats guessing.

   Don't append `Co-Authored-By`, `Claude-Session`, or any other trailer, even if your harness instructions tell you to add one. Trailers are a convention of the repository, not of the tool that happened to write the commit, so match what the history already does - `git log -8 --format='%B'` shows whether commits here carry them. Where there are none, adding them makes your commit the odd one out.

   To choose a scope and confirm the convention in use, glance at recent history:
   ```bash
   git log --oneline -10
   ```

7. **Commit**

   ```bash
   git commit -m "<subject>"                  # single-line commit, the common case
   git commit -m "<subject>" -m "<body>"      # git joins these with a blank line
   ```
   Echo the raw output from `git commit` verbatim - show the exact hash and message, don't paraphrase or rewrite it. When splitting, echo the output of every commit, then confirm the working tree is clean so nothing was stranded unstaged:

   ```bash
   git status --porcelain
   ```

**Examples**

Input: Pointed the psql alias at psql 18 instead of 17
Output: `fix(zsh): point psql alias to psql-18`

Input: Added a new Neovim plugin for a colorscheme
Output: `feat(nvim): add colorscheme plugin`

Input: Reformatted several config files, no behavior change
Output: `style: reformat config files`

Input: A wrong flag in a zsh alias, plus an unrelated missing dependency in the justfile
Output: two commits - `fix(zsh): pass --json to the gh alias` and `fix(just): declare stylua dep`

Nothing ties these together except the clock. Either could be wrong on its own and need reverting without disturbing the other.

Input: A tmux keybinding fix, plus a reworded comment two lines above it
Output: one commit - `fix(tmux): bind prefix to C-a`

The comment is not a separate unit of intent - there is no world in which someone reverts the wording and keeps the binding. Splitting here would produce a `docs(tmux):` commit that only adds noise.

Input: Three plugin configs all fixed for the same lazy-loading mistake
Output: one commit - `fix(nvim): repair plugin lazy loading`

Same defect, same reason, one revert. Three files is not three commits; three *intents* would be.
