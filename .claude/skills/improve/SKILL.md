---
name: improve
description: Survey this repo and make one high-value, self-contained improvement - a correctness gap, a missing test, a broken or stale config, a tool the repo references but never provides, a dead setting. Works in any language and in config repos such as dotfiles. Use whenever the user asks to "improve the repo", "tidy this up", "is anything broken here?", or invokes /improve, without naming a specific file or change. The skill chooses what to improve, applies it, verifies it, and leaves it uncommitted for review. It fixes what is there; whether something should be added, removed, or replaced is `propose`'s question.
---

# Improve

Pick the single highest-value improvement you can find in this repo right now, make it well, prove it works, and hand it back uncommitted for the user to review. One run produces one focused, reviewable change - not a sweep, and not something trivial. A "helpful" rewrite that changes behavior is worse than no change at all. The value is in *judgment*: surveying what's actually here and choosing the one change a careful owner would make first.

## What "high-value" means here

You're optimizing for the change that most improves the repo per line touched. Good candidates, roughly in order of how often they pay off:

- **Correctness or robustness gaps** - an unhandled error, a missing edge case, a function that misbehaves on empty or malformed input, a bad path, a misspelled option, syntax borrowed from the wrong tool, a build recipe that's broken. These are worth the most.
- **Referenced but never provided** - something the repo names but nothing in it supplies: a binary a config shells out to, a tool a recipe assumes, a dependency missing from the manifest. See step 1a; this is the one kind of fault that survives every other kind of review, so it is the most likely to hold something real.
- **Missing test coverage** - a function with real logic and no test, or a test that asserts almost nothing.
- **Clarity** - a confusing function that a small refactor or a doc comment would make obvious. Don't add comments that just restate the code.
- **Dead, redundant, or outdated** - commented-out cruft, duplicated settings, modules nothing loads, an unused helper, APIs the language or tool has moved past, options renamed across versions.

Lower value, usually skip: cosmetic reformatting (the formatter handles it), speculative abstraction, renaming or reordering for taste, and anything where the user might reasonably prefer their current style. The bar is the minimum change that solves a real problem - surgical, nothing speculative.

## The loop

### 1. Survey

Start with the leftovers from the last run, if there are any. Step 6 writes the candidates it found but did not fix to `docs/improve.md`, best first, each stamped with the commit it was found at and the files it concerns:

```sh
cat docs/improve.md 2>/dev/null
```

An entry is live only while its files are unchanged since its stamp - the check compares against the working tree, so uncommitted edits count too:

```sh
git diff --stat <hash> -- <files>    # empty output: the entry is live
```

Delete every entry whose files have moved; it was found in a tree that no longer exists. Take the first live entry and verify the claim itself with one check - run the command, read the function, resolve the binary. If it holds, delete its line, skip the build, lint, coverage and reading passes below that exist to find candidates, and go to step 2; you still need `just --list` (or its equivalent) and the formatter configs, because step 4 runs them. If it doesn't hold, delete the line and try the next live entry. An empty or missing file, or no entry that survives, means the full survey.

Get oriented before you touch anything. Derive the map instead of trusting one written down here - a hardcoded list of paths and commands goes stale the moment the tree moves, and a stale map is worse than no map:

```sh
git ls-files | head -100    # the tree (narrow by directory in a large repo); everything untracked is local state
just --list                 # or: make help, the scripts table, whatever the repo exposes
cat README.md               # how the repo says it is built, installed, and used
<build>                     # compiles, or the config loads without error
<lint>                      # the repo's own linter, or the language's default
<coverage report>           # least-covered functions, where a coverage tool exists
```

From that, work out three things:

- **How it is built and checked.** The repo's own recipes for build, test, lint, and coverage; use those, not your own. If there is no recipe, use the language's standard tool. Prefer checks that execute over checks that read, because they catch what reading misses.
- **How it is used.** A program is run; a library is imported; config is linked or copied into place (by stow or similar) or read where it sits. That decides which tracked files are live.
- **Where the house style is.** Formatter and linter configs, and the surrounding code. The house style is whatever the code already does - read it, don't impose your own.

Coverage is a gap only where the function makes decisions (branches, counts, thresholds); code that just prints or wires calls together can stay untested. A test file's existence proves nothing about what it tests - read the report, not the file list. Where there is no coverage tool, list source files with no test counterpart by the language's convention, then read them.

Read comments before judging the code beside them. A comment explaining why something looks wrong turns a candidate into a non-candidate.

Generated and vendored files are off limits for editing or restyling. A change to generated code starts at its source (the `.proto`, `.sql`, or whatever produced it) and is regenerated; its packages are untested by design, not a coverage gap. Vendored code keeps upstream's idioms, which often look wrong out of context: check upstream before calling anything near a vendored file a bug. But vendored does not mean unread - diff it against upstream, because a large divergence means local changes have crept in, and *that* is a candidate.

Don't install a missing tool unprompted, and don't skip a file because its tool is missing - read it by eye instead.

Don't over-survey. A few minutes is enough to spot something real. If two or three candidates compete, pick the one with the best value-per-line and note the others in your final summary - you're allowed to mention them, just not to do them all.

### 1a. Check that referenced tools actually exist

Config or code that names a binary is the one thing you cannot verify by reading. A formatter mapping can be valid, current, and well formatted - and completely inert because the binary isn't installed. Nothing in the file is wrong, so every other check walks past it.

Find referenced tools wherever the repo shells out: formatter and linter mappings, build recipes, plugins that wrap a CLI, shell aliases and functions, git hooks, CI steps. Then ask three separate questions, because they fail differently:

- **Is it on this machine now?** Run it (`<tool> --version`) rather than trusting `command -v` - a shim whose interpreter is gone still resolves as present. If not, that feature is dead *today* and the user probably doesn't know.
- **Would a fresh machine get it?** A tool can be on `$PATH` because it was installed by hand years ago. The repo is only self-installing if its bootstrap path brings it in - a justfile, a manifest, an installer the editor or shell config runs itself.
- **Is the copy on `$PATH` the one the repo installs?** Resolve it (`ls -l "$(command -v <tool>)"`). This fails three ways, all of which look healthy: the package ships a differently named binary, an earlier `$PATH` entry shadows it, or a different package manager put it there.

Missing *and* uninstallable is broken now; present but uninstallable, or present from somewhere other than the bootstrap, is a trap that only bites on a new machine. The first outranks the second when you choose.

Check the bootstrap itself the same way: steps the top-level entry point never runs, and - where files are linked into place - tracked files that are neither linked nor deliberately ignored.

### 2. Decide and state it

Before editing, say in one or two sentences what you're going to improve and *why it's worth doing*. This keeps you honest - if you can't articulate the value, it's probably not the right change. If nothing genuinely worthwhile turns up (it happens in a clean repo), say so rather than inventing busywork.

### 3. Apply it surgically

Make the change and nothing else. The test to hold yourself to: every changed line should trace directly to the improvement you named, with `docs/improve.md` as the one exception - steps 1 and 6 maintain it. Don't "improve" adjacent code along the way, don't reformat untouched lines, match the surrounding style even where you'd personally do it differently. If your change orphans something - an import, a helper, a PATH entry, an install line, a README mention - clean up that orphan, but only that.

If the change alters an interface something else depends on - a data file's columns or units, a CLI flag, a config schema - update the doc that describes it in the same change. A stale doc turns into wrong behavior wherever it is read.

Edit the repo, not the machine. Installing, uninstalling, or relinking on this machine is the user's call; if the fix needs it, name the command to run in the summary.

Don't touch `.claude/skills/**` unless asked - those are skills, not code to lint.

### 4. Verify

A change isn't done until you've proven it works. Run the repo's build, test, and lint recipes, in that order, and rerun the step 1 checks against every file you touched. Where you can, exercise the thing itself: run the command, run the alias, trigger the keymap headlessly, dry-run the recipe.

If you added or changed logic, there should be a test that exercises it - and you should have watched that test fail before your change and pass after, so you know it's actually testing the thing. For a config fix, the same goes for the check that caught it. If verification fails, fix it before reporting; don't hand back a red build.

Some changes have nothing to test - a swapped default that would only re-test the library, a recipe that would install software, a setting that only shows in an interactive terminal. Say in the summary what you did not run and why, so the gap reads as a decision, not an oversight.

### 5. Review your own diff

Read `git diff` as if someone else wrote it and you're the reviewer. This pass is cheap and it is the one that saves a round trip:

- **Cut comments that argue.** A comment earns its place by saying something the code cannot: a non-obvious invariant, a surprising tool or API behavior, why the obvious approach is wrong. *Why the change was worth making* goes in the summary, not the source. If the doc comment is longer than the function, it's too long.
- **Look for redundancy your change introduced** - two guards for one concern, an error path that duplicates another, a setting now made in two places, an install line that duplicates another recipe's.
- **Take the smallest form that keeps every behavior.** Shorter is better only while nothing is lost; don't drop a wrapped error or a distinct message to save a line.

### 6. Report, uncommitted

Leave the changes in the working tree - **do not commit**. The user reviews before anything lands.

First save the candidates you found and left, so the next run can start from them instead of re-auditing. Write them to `docs/improve.md`, best first, one line each:

```
- <YYYY-MM-DD> | <short HEAD hash> | <files, space-separated> | <title> - <the claim in one sentence, and how to check it>
```

Only create the file when you have something to write; a repo that was surveyed once and came up clean should not grow an empty log. When creating it, start with the heading:

```markdown
# Improve

Leftovers from /improve, so the next run can start here instead of re-auditing. Each line is stamped with the commit it was found at; a run deletes a line once its files have changed or it has acted on it.
```

Stamp with `git rev-parse --short HEAD`. Name every file whose change would make the claim stale, and no more - the check in step 1 only looks at the files you name, and everything else you read along the way just adds false invalidations. Don't stage or commit the file; the user decides whether it goes in the repo.

End with a short summary:

- **What** you changed (the files, one line each)
- **Why** it was the highest-value pick
- **Verification** - what you ran and that it's clean, plus anything you could not run
- **Leftovers** - the entries you wrote to `docs/improve.md`, or that there were none

Keep the summary tight. The diff tells most of the story; your job is to explain the judgment behind it.
