---
name: improve
description: Survey this repo and pitch one high-value, self-contained improvement - a correctness gap, a missing test, a broken or stale config, a tool the repo references but never provides, a dead setting. Works in any language and in config repos such as dotfiles. Use when the user invokes /improve or explicitly asks to improve this repo as a whole, such as "improve the repo" or "find something to fix in this repo", without naming a specific file or change. The skill checks docs/improve.md so it never repeats a settled idea, gives a short overview and asks the user to accept or reject it, writes a plan only if they accept, applies and verifies it only once they approve the plan, and leaves it uncommitted for review. It fixes what is there; whether something should be added, removed, or replaced is `propose`'s question.
argument-hint: "[low|medium]"
---

# Improve

Pick the single highest-value improvement you can find in this repo right now and pitch it in a few lines. The user decides at each step, and nothing but the log is changed until they say so:

1. **Pitch** - a short overview. The user accepts or rejects it.
2. **Plan** - only if accepted: how it would be applied and verified. The user approves it, asks for changes, or stops.
3. **Build** - only once the plan is approved. Make it well, prove it works, and hand it back uncommitted.

One run produces one focused, reviewable change - not a sweep, and not something trivial. A "helpful" rewrite that changes behavior is worse than no change at all. The value is in *judgment*: surveying what's actually here and choosing the one change a careful owner would make first. That's why the pitch is short - a rejected idea should cost the user ten seconds of reading, not a page.

This is the sibling of `/propose`. `improve` asks "is this **correct**?" and finds its answers inside the repo. `propose` asks "is this still the **right shape**?" and usually has to look outside it.

## Scope

The skill takes an optional scope: `/improve low` or `/improve medium`. With no argument, use `low`.

- **low** - favor the best value-per-line candidate, usually one contained fix.
- **medium** - favor the candidate that removes a whole class of fault, even if the fix spans several files. It is still one issue and one reviewable change.

## Hard rule: nothing changes until the plan is approved

Until the user approves a plan (step 6), the only file you touch is `docs/improve.md`. No source, config, tests, lockfiles, generated files, or installed software. Surveying with read-only commands is expected, and so are the repo's own checks - but before you run any recipe, read what it does. Anything that installs or removes software, links files into `$HOME`, starts a service, writes anything beyond build caches and temp files, touches data, regenerates code, commits, or calls an external API is off limits at this stage. If a check would rewrite a tracked file, such as a build that regenerates a committed artifact, run it from a temporary copy of the repo or read the code instead. Don't rely on a list of recipe names - this file can't know about a mutating one added after it was written.

If you catch yourself editing anything but the log before the user has approved a plan, stop.

## Plain ASCII only

Everything this skill outputs - the pitch, the plan, your replies, and the lines you add to `docs/improve.md` - is plain ASCII: `-` or `--` instead of em/en dashes, `...` instead of an ellipsis, straight quotes, `->` instead of arrows, `|` as a separator, and no emoji. Before you send anything, check it for characters outside ASCII and replace them.

## What "high-value" means here

You're optimizing for the change that most improves the repo per line touched. Good candidates, roughly in order of how often they pay off:

- **Correctness or robustness gaps** - an unhandled error, a missing edge case, a function that misbehaves on empty or malformed input, a bad path, a misspelled option, syntax borrowed from the wrong tool, a build recipe that's broken. These are worth the most.
- **Referenced but never provided** - something the repo names but nothing in it supplies: a binary a config shells out to, a tool a recipe assumes, a dependency missing from the manifest. See step 1a; this is the one kind of fault that survives every other kind of review, so it is the most likely to hold something real.
- **Missing test coverage** - a function with real logic and no test, or a test that asserts almost nothing.
- **Clarity** - a confusing function that a small refactor or a doc comment would make obvious. Don't add comments that just restate the code.
- **Dead, redundant, or outdated** - commented-out cruft, duplicated settings, modules nothing loads, an unused helper, APIs the language or tool has moved past, options renamed across versions.

Lower value, usually skip: cosmetic reformatting (the formatter handles it), speculative abstraction, renaming or reordering for taste, and anything where the user might reasonably prefer their current style. The bar is the minimum change that solves a real problem - surgical, nothing speculative.

## The log

`docs/improve.md` is the permanent record of every candidate. **Never delete or reorder an entry, and never change the first four columns of an entry from an earlier run.** New lines go directly below the header, above any existing entries, so the newest is always first:

```
- <YYYY-MM-DD> | <short HEAD hash> | <files, space-separated> | <title> - <description: the claim in one sentence, and how to check it> | <status> | <evidence>
```

Status and evidence are always the last two columns, because a description can contain `|`. Stamp with `git rev-parse --short HEAD`. Name every file whose change would make the claim stale, and no more.

| Status | Meaning | Evidence |
|---|---|---|
| `proposed` | Not fixed, and nobody has decided | `Unfixed, still open`, or what a recheck showed |
| `built` | Fixed | The commit that fixed it, or for this run's uncommitted fix, what verification showed |
| `rejected` | The user declined it | `Rejected at pitch`, plus ` - <reason>` if the user confirmed one |

A run can't cite the hash of its own fix: it is uncommitted, and the log update lands in the same commit. Record the verification instead, such as `just test passes; new test failed before the fix`.

Only create the file when you have something to write; a repo that was surveyed once and came up clean should not grow an empty log. When creating it, start with:

```markdown
# Improve

Logged by /improve so it doesn't repeat itself, newest first. Entries start as proposed; a run marks them built or rejected and records the evidence.

Columns: date | commit found at | files | title - description | status | evidence
```

Don't stage or commit the file; the user decides when it goes in the repo.

## The loop

### 1. Survey

#### Open queue first

Read the log and settle its open entries before running anything else:

```sh
cat docs/improve.md 2>/dev/null
```

Treat `built` and `rejected` entries as taken. Don't re-pitch them or a close variant unless you can say what is materially different, such as a fix that has since regressed. Rejected lines also tell you what this user doesn't value - if several are the same kind of idea, steer away from that kind. A line without status and evidence columns predates this format; read it as `proposed`.

`proposed` entries are the open queue. Order is by date, not value, so choose the best one by judgment. Check it before you rely on it - compare against the working tree, so uncommitted edits count too:

```sh
git diff --stat <hash> -- <files>    # exit 0 and empty output: the files are unchanged since the stamp
```

An error means the stamped commit is gone, so don't assume the files are unchanged. Then verify the claim itself with one check - run the command, read the function, resolve the binary, even when the files are unchanged. What you find decides what happens next:

- **It holds** - pitch it, and do not look for new candidates. Skip the full survey and step 1a, and go to step 2. You still need `just --list` (or its equivalent) and the formatter configs, because step 7 runs them.
- **A commit fixed it or removed the code** - set it to `built` and cite that commit, then try the next open entry.
- **It looks untrue** - leave it `proposed`, record what the check showed as its evidence, and try the next open entry. Only the user rejects an entry.
- **You can't tell** - leave it `proposed` and try the next open entry. A changed file alone settles nothing.

The same issue may be logged more than once with different stamps. When you settle one, settle its open duplicates the same way.

#### Full survey

Run this and step 1a only when the log is empty or missing, or no open entry holds.

Get oriented before you pitch anything. Derive the map instead of trusting one written down here - a hardcoded list of paths and commands goes stale the moment the tree moves, and a stale map is worse than no map:

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

When you check upstream or any other outside source, send it only the public name of the tool or package, never repo contents, private paths, or data. Judge data from its schema and docs, not its values.

Don't install a missing tool unprompted, and don't skip a file because its tool is missing - read it by eye instead.

Don't over-survey. A few minutes is enough to spot something real. If two or three candidates compete, pick the one the scope favors.

### 1a. Check that referenced tools actually exist

Config or code that names a binary is the one thing you cannot verify by reading. A formatter mapping can be valid, current, and well formatted - and completely inert because the binary isn't installed. Nothing in the file is wrong, so every other check walks past it.

Find referenced tools wherever the repo shells out: formatter and linter mappings, build recipes, plugins that wrap a CLI, shell aliases and functions, git hooks, CI steps. Then ask three separate questions, because they fail differently:

- **Is it on this machine now?** Run it (`<tool> --version`) rather than trusting `command -v` - a shim whose interpreter is gone still resolves as present. If not, that feature is dead *today* and the user probably doesn't know.
- **Would a fresh machine get it?** A tool can be on `$PATH` because it was installed by hand years ago. The repo is only self-installing if its bootstrap path brings it in - a justfile, a manifest, an installer the editor or shell config runs itself.
- **Is the copy on `$PATH` the one the repo installs?** Resolve it (`ls -l "$(command -v <tool>)"`). This fails three ways, all of which look healthy: the package ships a differently named binary, an earlier `$PATH` entry shadows it, or a different package manager put it there.

Missing *and* uninstallable is broken now; present but uninstallable, or present from somewhere other than the bootstrap, is a trap that only bites on a new machine. The first outranks the second when you choose.

Check the bootstrap itself the same way: steps the top-level entry point never runs, and - where files are linked into place - tracked files that are neither linked nor deliberately ignored.

### 2. Decide

Pick the one change to pitch. An open entry that holds is the pick, ahead of anything new. Otherwise, check your pick against the log from step 1 - if it's settled there, pick again. If you can't say in a sentence why it's worth doing, it's not the right pick. If nothing genuinely worthwhile turns up (it happens in a clean repo), say so rather than inventing busywork: one line saying so and that the checks came back clean, then the candidates you rejected, one line each with the reason. Don't list the checks you ran or their output, and don't suggest features.

### 3. Pitch it

Keep it to a few lines - enough to decide on, nothing more. Ground it in the real files, but save the detail for the plan:

```
Improvement: <title>
<What is wrong and what would change - one or two sentences.>
Why: <the impact, and the one check you ran that proves it - one sentence.>
Size: <small|medium|large> - <what it touches>
```

No sketch, no code, no open questions, no list of alternatives - all of that either belongs in the plan or doesn't matter if the answer is no. Only add a line if something would change the decision (a behavior change, a new dependency, a wide diff).

### 4. Log it and ask

Update `docs/improve.md`:

- If the pitch is a new candidate, add it as `proposed` with the evidence `Unfixed, still open`. A pitch taken from an open entry keeps its existing line.
- Add any other candidates you found and verified the same way, best first among themselves. Skip anything already logged, whatever its status.

Then ask the user to accept or reject the improvement - with the AskUserQuestion tool if you have it (options: Accept, Reject), otherwise as a one-line question. Stop and wait.

### 5. Record the verdict

- **Reject** - set the entry's status to `rejected` and its evidence to `Rejected at pitch`, along with any open duplicates. Then propose the likeliest reason in one line, labeled as your guess, and ask the user to confirm it - AskUserQuestion if you have it (options: Use this reason, No reason; the user can type their own under Other). Append it as `Rejected at pitch - <reason>` only if the user confirms it or gives their own; never record an unconfirmed guess. Then stop; offer to run again for a different idea.
- **Accept** - leave it `proposed` and go on to step 6.
- **Anything else** (a tweak, a question) - answer or adjust the pitch, update the line's title and description only if it was added by this run, and ask again. Don't infer a verdict the user didn't give.

Only touch the lines for this improvement.

### 6. Plan it

Now the detail is worth writing, because the user wants the thing. Keep it concrete and grounded in the actual files:

- **Shape** - which files change, and what depends on them.
- **Evidence** - what you checked and how, so the user can re-check it.
- **Steps** - the edits, in order, then every command that installs, removes, or updates software, written out exactly. Keep each command as narrow as the change: upgrade the one dependency rather than running a recipe that updates everything. If a wider one is truly required, say what else it touches. Editing the repo is in scope; changing the machine is the user's call, so name any such command for them to run.
- **Verification** - the test that should fail before the change and pass after, or the check that proves it, plus the repo's build, test, and lint recipes. Say what can't be run and why. If only real data can prove it, say so here so the user can run it themselves.
- **Risks** - what could break, and any behavior that changes. Be straight; a plan that only lists upside isn't credible.
- **Questions** - only decisions you genuinely can't make from the repo or sensible defaults. For anything else, pick the obvious option and state it in the plan.

Then ask the user to approve it - AskUserQuestion if you have it (options: Approve, Change, Stop). Nothing but the log has changed yet. On **Change**, revise and ask again. On **Stop**, leave the line `proposed` and stop - they can pick it up later.

### 7. Build it

Only after the plan is approved. Apply the plan and nothing else. Approval covers the commands the plan listed, exactly as written, plus the repo's read-only build, test, and lint checks - if you find you need a different or wider one, stop and ask.

#### Apply it surgically

Every changed line should trace directly to the improvement you named, with `docs/improve.md` as the one exception. Don't "improve" adjacent code along the way, don't reformat untouched lines, match the surrounding style even where you'd personally do it differently. If your change orphans something - an import, a helper, a PATH entry, an install line, a README mention - clean up that orphan, but only that.

If the change alters an interface something else depends on - a data file's columns or units, a CLI flag, a config schema - update the doc that describes it in the same change. A stale doc turns into wrong behavior wherever it is read.

Edit the repo, not the machine. Installing, uninstalling, or relinking on this machine is the user's call; if the fix needs it, name the command to run in the summary.

Don't touch `.claude/skills/**` unless asked - those are skills, not code to lint.

#### Verify

A change isn't done until you've proven it works. Run the repo's build, test, and lint recipes, in that order, and rerun the step 1 checks against every file you touched. Where you can, exercise the thing itself: run the command, run the alias, trigger the keymap headlessly, dry-run the recipe. Use test fixtures where the repo holds private data.

If you added or changed logic, there should be a test that exercises it - and you should have watched that test fail before your change and pass after, so you know it's actually testing the thing. For a config fix, the same goes for the check that caught it. If verification fails, fix it before reporting; don't hand back a red build. If a fix would go beyond the plan, stop and ask.

Some changes have nothing to test - a swapped default that would only re-test the library, a recipe that would install software, a setting that only shows in an interactive terminal. Say in the summary what you did not run and why, so the gap reads as a decision, not an oversight.

#### Review your own diff

Read `git diff` as if someone else wrote it and you're the reviewer. This pass is cheap and it is the one that saves a round trip:

- **Cut comments that argue.** A comment earns its place by saying something the code cannot: a non-obvious invariant, a surprising tool or API behavior, why the obvious approach is wrong. *Why the change was worth making* goes in the summary, not the source. If the doc comment is longer than the function, it's too long.
- **Look for redundancy your change introduced.** Two guards for one concern, an error path that duplicates another, a setting now made in two places, an install line that duplicates another recipe's.
- **Take the smallest form that keeps every behavior.** Shorter is better only while nothing is lost; don't drop a wrapped error or a distinct message to save a line.

#### Finish, uncommitted

When everything passes, set the entry and any open duplicates to `built`, with what verification showed as the evidence. Leave the changes in the working tree - **do not commit**. The user reviews before anything lands.

End with a short summary:

- **What** you changed (the files, one line each)
- **Why** it was the highest-value pick
- **Verification** - what you ran and that it's clean, plus anything you could not run
- **Log** - the entries you added or settled, or that there were none

Keep the summary tight. The diff tells most of the story; your job is to explain the judgment behind it.
