---
name: spawn
description: Hand the work agreed in this conversation to background subagents, one per item, in the current repo or a given path. Lists the agreed items, asks the user to confirm, then starts the subagents; each implements its item and nothing else (no commit), and shows up in /tasks. Use when the user invokes /spawn, or asks to "spawn subagents for the accepted ones", "farm these out", "run these in parallel", or similar.
argument-hint: "[path]"
---

# Spawn

Turn what the user agreed to in this conversation into background subagents, one per item, so the user can keep talking to this session while the work runs and watch or stop each one from `/tasks`.

```
spawn [path]

1. resolve   the path, default .              not a directory -> say so, stop
2. collect   the agreed items                 none -> say so, stop
3. confirm   the list with the user           change -> revise, ask again
4. start     one background subagent each
5. report    each result as it lands
```

## 1. Resolve the path

The argument is the directory the subagents work in. With no argument, use `.`, the current working directory. Expand `~` and turn it into an absolute path, since the subagents get it written into their prompt and must not depend on where they happen to start. If it is not a directory, say so and stop.

## 2. Collect the agreed items

Read back through this conversation for work the user agreed to: items they accepted or answered yes to, a plan they approved, a list where they picked some ("do 1, 3 and 5"). Proposals the user rejected, questioned, or never answered are not agreed. Leave them out, because a subagent started on a guess is work the user has to read and undo.

Split the agreed work into items that can each be done on its own. Give each a short label of two to four words; it becomes the subagent's name in `/tasks`, which is how the user tells the rows apart.

If nothing in the conversation is clearly agreed, say so in one line and stop. Don't invent tasks.

## 3. Confirm

Show the list, one line per item, label first, then the path they will run in:

```
In ~/repos/macros:
1. retry fetch - retry the price fetch once on a timeout
2. csv header - write a header row in the export
```

If two items look likely to edit the same files, say so under the list, since parallel subagents in one checkout can overwrite each other's edits; the user may prefer to merge them into one item.

Ask the user to confirm, with AskUserQuestion if you have it (options: Start, Change, Cancel). On Change, revise the list and ask again. On Cancel, stop. Start nothing until the user says Start.

## 4. Start the subagents

Start all of them in one message, one Agent call per item, each with `run_in_background: true` and the label as its `description`. Sending them together makes them run in parallel.

A subagent sees none of this conversation, so its prompt carries everything it needs:

- the absolute path to work in, and that it works only there
- the item, in full: what to change and why, with the decisions and constraints the user settled in the conversation, and the files or lines already identified
- that it implements the item and nothing else: no commits, no pushes, no branches, no edits outside the item
- that it runs the repo's own checks (tests, lint) for what it changed if the repo has them
- that it finishes with a short report: what it changed, file by file, and anything it could not do or was unsure about

Then tell the user in one line that the subagents are running and that `/tasks` shows them (`Enter` opens one's transcript, `x` stops it).

## 5. Report

As each subagent finishes, relay its result in a line or two: the label, what it changed, and anything it flagged. Leave the changes uncommitted; the user reviews them and commits when ready.
