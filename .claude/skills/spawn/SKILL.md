---
name: spawn
description: Hand the work agreed in this conversation to new Claude sessions, one per item, each in its own tmux window and git worktree of the current repo. Lists the agreed items, asks the user to confirm, then opens the windows; each session implements its item and nothing else (no commit). Use when the user invokes /spawn, or asks to "spawn sessions for the accepted ones", "farm these out", "run these in parallel", or similar.
---

# Spawn

Turn what the user agreed to in this conversation into separate Claude sessions, one per item. Each runs in its own tmux window and its own git worktree, so the user can keep talking to this session, switch to any of them to watch or steer it, and the sessions cannot overwrite each other's edits.

```
spawn

1. check     tmux and the repo                not in tmux or not a git repo -> say so, stop
2. collect   the agreed items                 none -> say so, stop
3. confirm   the list with the user           change -> revise, ask again
4. start     one tmux window + worktree each
5. report    the windows that were opened
```

## 1. Check tmux and the repo

The sessions work in the repo this session runs in; spawn takes no argument. Run `git rev-parse --show-toplevel` from the current directory and keep the result as the repo root. If it fails, say the current directory is not a git repo and stop.

If `$TMUX` is empty, say spawn needs to run inside tmux and stop.

## 2. Collect the agreed items

Read back through this conversation for work the user agreed to: items they accepted or answered yes to, a plan they approved, a list where they picked some ("do 1, 3 and 5"). Proposals the user rejected, questioned, or never answered are not agreed. Leave them out, because a session started on a guess is work the user has to read and undo.

Split the agreed work into items that can each be done on its own. Give each a short label of two to four words, and a slug from it in lowercase with hyphens (`retry fetch` -> `retry-fetch`). The slug names the tmux window and the worktree. If `<repo root>/.claude/worktrees/<slug>` already exists, add `-2`, `-3` and so on until it does not.

If nothing in the conversation is clearly agreed, say so in one line and stop. Don't invent tasks.

## 3. Confirm

Show the list, one line per item, slug first, then the repo they will branch from:

```
In ~/repos/macros:
1. retry-fetch - retry the price fetch once on a timeout
2. csv-header - write a header row in the export
```

If two items look likely to edit the same files, say so under the list: each works in its own worktree, but the user will have to merge the overlapping changes by hand and may prefer to merge them into one item.

Ask the user to confirm, with AskUserQuestion if you have it (options: Start, Change, Cancel). On Change, revise the list and ask again. On Cancel, stop. Start nothing until the user says Start.

## 4. Start the sessions

A new session sees none of this conversation, so its prompt carries everything it needs:

- the item, in full: what to change and why, with the decisions and constraints the user settled in the conversation, and the files or lines already identified
- that it works in its own worktree, which is the current directory, and changes nothing outside it
- that it implements the item and nothing else: no commits, no pushes, no new branches, no edits outside the item
- that it runs the repo's own checks (tests, lint) for what it changed if the repo has them
- that it finishes with a short report: what it changed, file by file, and anything it could not do or was unsure about

Write each prompt to `<slug>.md` in the scratchpad directory, then open one window per item, without switching to it:

```
tmux new-window -d -n <slug> -c <repo root> 'claude --worktree <slug> "$(cat <prompt file>)"'
```

`--worktree <slug>` makes Claude create `<repo root>/.claude/worktrees/<slug>` on a new branch and start there; reading the prompt from the file keeps quotes and newlines in it from breaking the command. Run the commands one after another, and if one fails, report it and go on with the rest.

## 5. Report

List the windows that opened, one line each with the slug and its worktree path, and any that failed with the error.

Then tell the user in one line: the tab of each window shows a red `*` when its session asks a question and a green `*` when it has finished, `prefix a` jumps to the next one, and the changes stay uncommitted in each worktree (lazygit's Worktrees tab, behind Files, switches between them) for the user to review, merge and commit when ready. When a session exits, Claude asks whether to keep or remove its worktree.

This session does not receive the results; leave the reviewing to the user.
