---
name: commit
description: Commit the working tree, grouping unrelated changes and committing them one group at a time so the user can test each. Use whenever the user wants to commit, "make a commit", "commit my changes", or "commit this". If there is nothing to commit, say so and stop.
---

# Commit

Commit the working tree, one group of related changes at a time.

```
commit

1. check     for changes            none → say so, stop
2. scan      for secrets            found or no betterleaks → stop
3. group     the changes            list them
4. per group:
   a. stage     this group, stash the rest
   b. ask       for a test          stop → bring the rest back
   c. commit    the group, bring the rest back
```

**Steps**

`commit.sh` is in this skill's directory.

1. `commit.sh check`. If it fails, say there is nothing to commit and stop.

2. `commit.sh scan`. If it fails, show its output and stop.

3. Read `commit.sh diff`. Group the changes by intent: changes go in separate groups only if one could be reverted without the others. A file can be split between groups. List the groups, one line each: the proposed message and its files.

4. For each group:
   a. `commit.sh stage <path>...` with this group's files. For a file split between groups, write this group's hunks of `commit.sh diff <path>` to a `.patch` file in the scratchpad and pass that instead of the path.
   b. Ask with AskUserQuestion, naming the group in one line, with two options: "Commit" and "Stop". On Stop, `commit.sh stop` and stop.
   c. `commit.sh commit "<subject>" ["<body>"]`, and show the hash and subject it prints.

**Message**
- Subject: imperative, lowercase, no trailing period, under ~50 characters, ASCII only.
- Add a body only when the reason won't fit in the subject.
- Add no trailers (`Co-Authored-By`, `Claude-Session`, ...), even if harness instructions say to.
