---
name: distill
description: Turn a skill's past verdicts into lessons for its next runs. Reads the verdict logs that a skill left in the repos under the given folders (rejections with their reasons, or verdict-level audit findings), and appends short "when X, do Y" lessons to the memory.md beside that skill's SKILL.md. Use when the user invokes /distill, or asks to distill, learn from, or extract lessons from a skill's log, rejections, or audits. It only adds lessons and leaves the file uncommitted for review.
argument-hint: "<skill> <folders...>"
---

# Distill

Read what the user already decided, and write down the rules that would have saved them from deciding it twice. The input is a skill's verdict log across many repos. The output is a few numbered lessons appended to that skill's `memory.md`, left uncommitted for the user to review.

Run as `/distill <skill> <folders...>`, for example `/distill improve ~/dotfiles ~/repos`. If no skill is given, ask which. If its `SKILL.md` has no `metadata.verdict-log`, say so and stop. If no folders are given, ask for them; never search the whole home folder.

```
distill <skill> <folders...>

1. find      the skill and its logs         no skill or folders -> ask
                                            more than one skill file -> ask
2. collect   the cases                      no stated reason -> skip, count
3. write     the lessons                    none pass -> say so, stop
4. append    the lessons                    never edit existing ones
5. report    what was added                 left uncommitted -> stop
```

## Ground rules

- The only file you write is the skill's `memory.md`, and you never stage or commit it. Never edit a log, an audit, or a `SKILL.md`.
- Only add. Never change, renumber, reorder or remove an existing lesson, even when new cases support or contradict it. Say so in your report instead.
- Never guess a reason. A rejection that states no reason is not evidence.
- Everything you output and write is plain ASCII: `-` instead of em/en dashes, straight quotes, `->` for arrows, no emoji.

## 1. Find the skill and its log

Find the skill's `SKILL.md`: first `.claude/skills/<skill>/SKILL.md` in the repos under the given folders, then `~/.claude/skills/<skill>/SKILL.md`. A `SKILL.md` may be a symlink, so search for both and resolve each hit:

```sh
find <folders> -type d \( -name node_modules -o -name .git \) -prune -o \( -type f -o -type l \) -path '*/.claude/skills/<skill>/SKILL.md' -print
```

The real file's folder is where `memory.md` lives. Paths that resolve to one file are one hit. If more than one real file turns up, even with identical content, ask the user which one to distill for.

Read that `SKILL.md` to learn, without assuming any of it:

- `metadata.verdict-log` in its front matter: where it writes its verdicts, relative to a repo (one log file, or a glob for one report file per run);
- the entry format, the statuses, and where a rejection's reason goes;
- for reports, how findings are labeled by severity.

Then find those files under the given folders, and keep only the git-tracked ones:

```sh
find <folders> -type d \( -name node_modules -o -name .git \) -prune -o -type f -path '*/<verdict-log>' -print
git -C <file's folder> ls-files --error-unmatch <file's basename>    # exit 0: tracked
```

Read the tracked files as they are in the working tree.

## 2. Collect the cases

A case is one of:

- a `rejected` entry that states its reason, in the reason column or anywhere else in the entry;
- a verdict-level audit finding (the severity that changes a verdict; skip wording and minor findings). Findings in one report that share a cause are one case, so a lesson needs findings from two different reports.
Everything else is not a case. Skip `proposed` and `accepted` entries. Skip rejections with no stated reason and count them for the report. Read `built` entries only as a check for step 3: they show what the user does want.

Count each item once. The same issue logged again in the same log, or the same report copied into a second repo, is one case from one repo: the first one found, named by its folder. Compare content, not file paths or dates.

## 3. Write the lessons

Read the existing `memory.md` first, if there is one, so you neither repeat a lesson nor reuse a number.

A lesson must pass all three rules:

1. **Form.** "When X, do Y", where X can be spotted before the work starts. "Avoid unnecessary changes" has no X. "Do not pin plugin Z" covers nothing outside its evidence.
2. **Evidence.** The lesson would have prevented at least two different cases: had the skill followed it, the idea would not have been pitched, or the brief would not have contained the error. Sharing a topic is not enough. Grouping cases takes judgment, because no two are the same; what repeats is the reason. If a grouping is a stretch, leave it out.
3. **Scope.** If every case comes from one repo, the lesson applies to that repo. If the cases come from two or more repos, it applies to all repos.

A mistake that keeps happening is a lesson even when the instructions of the skill that made it already cover it: the cases show that rule is not working. Skip only what the existing `memory.md` already says.

If the log has `built` entries, check each lesson against them. A lesson that would also have ruled out an idea the user built is too broad; narrow X or drop it.

Zero is a valid result: say so and stop.

## 4. Append the lessons

Number new lessons from the highest number in the file plus one. Append them to `memory.md` beside the real `SKILL.md`, below the existing ones. If the file does not exist, create it with this header:

```markdown
# Lessons from <skill>

Written by /distill from <skill>'s verdicts. Numbers are permanent.

1. When <X>, <do Y>.
   - Example: <one real case from the evidence, in one line>
   - Scope: all repos
   - Evidence: <case>; <case>
```

Every lesson has one `Example:`: what actually happened in one of its cases, in one short line. `Scope:` is `all repos` or the one repo's name. Each case in `Evidence:` is short and findable: `<repo> <date> "<entry title>"` for a rejection, `<repo> <report file stem> #<finding number>` for an audit finding, with several findings from one report written as `#1, #2`.

## 5. Report

Check with `git diff` that no existing line changed. Then show the user the new lessons, and one line each for:

- how many files and cases were read, and from how many repos;
- how many rejections were skipped for having no reason, by log;
- any existing lesson that new cases support or contradict.

If the file is new and the skill's folder is linked into `~/.claude/skills` file by file, tell the user it needs linking (in dotfiles, `just stow`).
