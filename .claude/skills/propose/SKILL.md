---
name: propose
description: Survey this repo and pitch one high-value change to what it is or does - a capability to add (a command, calculation, output, or integration), or a plugin, tool, or dependency to add, remove, replace, or consolidate. Works in any repo. Use when the user invokes /propose or explicitly asks for ideas about this repo, such as "propose an extension", "what should I add to this repo", or "are any of my plugins obsolete", without naming a specific change. The skill checks docs/propose.md so it never repeats an earlier idea, gives a short overview and asks the user to accept or reject it, writes a plan only if they accept, and applies it only once they approve the plan.
argument-hint: "[low|medium]"
---

# Propose

Pick the single most valuable change to *what this repo is or does* and pitch it in a few lines. The user decides at each step, and nothing but the log is changed until they say so:

1. **Pitch** - a short overview. The user accepts or rejects it.
2. **Plan** - only if accepted: how it would be applied. The user approves it, asks for changes, or stops.
3. **Build** - only once the plan is approved.

This is the sibling of `/improve`, aimed one level up. `improve` asks "is this **correct**?" and finds its answers inside the repo. `propose` asks "is this still the **right shape**?" - what could exist that doesn't, whether a tool has been superseded, whether two things are doing one job. The value is in *judgment plus restraint*: spotting the one change a thoughtful user would make next, and letting them decide cheaply before anyone spends effort on it. That's why the pitch is short - a rejected idea should cost the user ten seconds of reading, not a page.

```
propose [low|medium]

1. check     the log for earlier ideas      already logged -> don't repeat
2. survey    the repo and outside tools     nothing worthwhile -> say so, stop
3. pitch     one change, log it             reject -> record it, stop
4. plan      the change                     stop -> leave it accepted
                                            change -> revise, ask again
5. build     only the approved plan         needs more -> stop, ask
6. verify    the change landed              fails -> fix it first
7. finish    mark built, summarize          left uncommitted -> stop
```

## Scope

The skill takes an optional scope: `/propose low` or `/propose medium`. With no argument, use `low`.

- **low** - favor the best value for the least disruption, usually one small addition, removal, swap, or consolidation.
- **medium** - favor the candidate that most widens what the repo can do: a change that opens a new question or capability, or one tool replacing a whole layer, beats a small tweak even at more effort or relearning. If the repo has a doc listing known limits or what its data can't answer, such as a `Traps` section, start the search there.

## Hard rule: nothing changes until the plan is approved

Until the user approves a plan (step 6), the only file you touch is `docs/propose.md`. No source, config, generated code, data, lockfiles, or installed software. Surveying with read-only commands (`git ls-files`, `ls`, `grep`, `git log`, `just --list`, a compile or test run that writes nothing tracked, a headless editor start) is expected - you need to understand the repo to propose well. Before you run any recipe, read what it does: anything that installs or removes software, links files into `$HOME`, starts a service, writes anything beyond build caches and temp files, touches data, regenerates code, commits, or calls an external API is off limits. The same goes for a plugin manager's install, update, and delete calls. Don't rely on a list of recipe or command names - this file can't know about a mutating one added after it was written.

If you catch yourself editing anything but the log before the user has approved a plan, stop.

## Plain ASCII only

Everything this skill outputs - the pitch, the plan, your replies, and the lines in `docs/propose.md` - is plain ASCII: `-` or `--` instead of em/en dashes, `...` instead of an ellipsis, straight quotes, `->` instead of arrows, `|` as a separator, and no emoji. The user reads these in a terminal and in plain-text files, where typographic characters get in the way. Before you send anything, check it for characters outside ASCII and replace them.

## What "high-value" means here

You're optimizing for the change that most improves what this repo can do per unit of effort and disruption. What the repo *is* today comes from the tree, not from this file - step 1 derives it, and proposing something that already exists is the main way this skill fails.

**Start from what this repo's log and recent commits show the user values.** What they built and rejected here is better evidence of the right kind of idea than any general list. With no log yet, rely on the survey alone.

Good candidates:

- **A missing capability** - a natural next command, calculation, output, export, or small integration. It should compose with what is already here rather than duplicate it.
- **A small extension of something existing** - a filter, format, range, or target. Check how the repo takes input first: where nothing parses flags or arguments yet, the first one is a real interface change, so say so in the pitch.
- **Redundancy worth collapsing** - two plugins, tools, or dependencies doing one job. Removal is pure profit: less to maintain, one thing to learn instead of two. Look at the whole set, not each file in isolation - redundancy is invisible one spec at a time, and it often spans the boundary between a vendored base and the user's own layer.
- **Something superseded** - a plugin, tool, or dependency that is archived or has gone quiet, whose job the platform now does natively, or that a clearly better-maintained option has replaced.
- **A real gap** - something the user's *own existing choices* imply they'd want. The justification has to come from this repo, not from a "top 10" list. If you can't point at something already here that makes the gap felt, it's a suggestion, not a gap.
- **The less-watched corners** - shell plugins and aliases, installed CLI utilities, git aliases and hooks. They get less attention than the main code and drift just as much.

Lower value, usually skip: cosmetic swaps, "this is popular" with no argument for why it fits *this* repo, speculative frameworks, config systems nobody asked for, features that don't fit the data model, and "flexibility" for hypothetical users. The bar is the minimum change that solves a *real* problem, nothing speculative: something the user would call *worth doing*, not just *doable*.

**Weigh switching cost honestly.** Habits are muscle memory. A tool that is 20% better but rebinds keys the user has typed ten thousand times is a bad trade, and a pitch that hides that is not credible.

## The loop

### 1. Survey

Start with the proposal log. Every earlier run added a line to `docs/propose.md` (newest first), and repeating one of them wastes the run - the user has already seen it, and may have already rejected it:

```sh
cat docs/propose.md 2>/dev/null
```

Treat every logged proposal as taken, whatever its status - `proposed` and `accepted` ones are in the pipeline, `rejected` ones the user said no to, `built` ones are already applied. Don't re-pitch a close variant either (the same capability under a new name or output format, the same swap with a different replacement, or the same removal argued another way) unless you can say what makes it materially different. Rejected lines also tell you what this user doesn't value - if several are the same kind of idea, steer away from that kind. Lines that carry a scope show which kind of idea each scope tends to get accepted or rejected, so weigh most heavily the lines with this run's scope. Older lines have no scope field; read them the same way otherwise.

Then get oriented. Map what the repo is and does **today** from the tree itself - any map written down here would go stale:

```sh
git ls-files                     # what is actually tracked
just --list                      # or: make help, the scripts table, whatever the repo exposes
git log --oneline -20            # what the user has been changing lately
cat README.md                    # how the repo says it is built, installed, and used
git grep -l 'DO NOT EDIT'        # generated code: propose at the source, never the output
```

From there, follow what the repo is made of. Find its entry points and the inputs they accept, the logic available to build on, its dependency or plugin lists and their lockfiles, and how software gets installed. Where it has key bindings or aliases, those are both what the user reaches for daily and the collision surface. Read the comments and the README as you go - repos record their deliberate oddities in place.

Find anything generated or vendored. Where code is generated, read the recipe that produces it to learn its real source - a proposal that touches it starts there, never at the output. Read vendored code too, because a dependency you think is missing may already be there, but a proposal lands in the user's own layer, never in the vendored file. A proposal that needs a new binary has to say which recipe installs it.

**Before pitching to remove or replace anything, check whether it's actually used.** The config tells you what's *installed*, never what's *reached for* - something abandoned two years ago and something used every morning look identical in a spec file. Pitching the removal of something the user depends on is the worst output this skill can produce, and the cheapest to avoid, because the evidence usually sits right outside the config:

```sh
ls -d ~/some/configured/path                             # does the directory it points at even exist?
git -C ~/that/path log -1 --date=short --format='%ad'    # last activity
git -C ~/that/path log --since='3 months ago' --oneline | wc -l
```

Two tools that look like obvious redundancy can turn out to be two live systems the user runs deliberately. Equally, a healthy-looking stack can point at a directory nobody has touched in a year. Either way the check changes the answer, so run it before you commit to a candidate.

**When judging a public tool or dependency, check the outside world.** Send outside services only its public name, never repo contents, private paths, or data. The files cannot tell you the ecosystem moved: a spec looks the same the day it's written and three years after the repo was archived. Verify against current reality, not recalled reality - your training data is older than the user's installed versions:

- Is the repo archived, or has it gone quiet? Get the real last-commit date (`git ls-remote`, `gh api`, the plugin's own checkout).
- Has core absorbed the job? Check against the version the user is actually running.
- Is there a maintained successor people actually moved to, or just a shinier alternative?
- Does the replacement cover the *specific* options and keys this repo uses? Read the config before claiming parity.

**When pitching a new capability, verify the gap.** Read the code that would own it and judge what the data can support from its schema and docs, not its values.

One verified fact makes a pitch; three plausible-sounding claims sink one.

Don't over-survey. A few minutes is enough to spot a real candidate. If two or three compete, pick the one the scope favors.

### 2. Decide

Pick the one change to pitch. Check it against the log from step 1 - if it's already there, pick again. If you can't say in a sentence why the user would want it, it's not the right pick. If nothing genuinely worthwhile turns up, say so - an honest "this repo is in good shape" beats inventing a change, and tells the user something worth knowing.

### 3. Pitch it

Keep it to a few lines - enough to decide on, nothing more. Ground it in the real files, but save the detail for the plan:

```
Proposal: <title>
<What gets added, removed, replaced, or consolidated, and what the user can do afterward - one or two sentences.>
Why: <who wants it and when, and the one fact you verified that backs it - one sentence.>
Size: <small|medium|large> - <what it touches, and what the user has to relearn (or "nothing to relearn")>
```

No sketch, no code, no open questions, no list of alternatives - all of that either belongs in the plan or doesn't matter if the answer is no. Only add a line if something would change the decision (a new binary or dependency, a feature the user loses, a data migration, a schema change, a wide lockfile churn).

### 4. Log it and ask

Add one line to `docs/propose.md`, newest first: insert it directly below the header, above any existing entries, so the latest proposal is always at the top. If the file doesn't exist, create it with the heading:

```markdown
# Proposals

Logged by /propose so it doesn't repeat itself, newest first. Entries start as proposed; a run marks them accepted, rejected, or built.

Columns: date | scope (if logged) | status | title - description | Reason: why it was rejected (if confirmed)
```

Each line is `- <YYYY-MM-DD> | <scope> | proposed | <title> - <description, in one sentence>`, where scope is the run's `low` or `medium`, for example:

```markdown
- 2026-09-26 | low | proposed | Drop the second fuzzy finder - remove plugin B and move its two keymaps to plugin A, which already covers them.
```

That line is only an illustration - don't copy it into the log. New lines always start as `proposed`. Don't stage or commit the file; the user decides whether the log goes in the repo.

Then ask the user to accept or reject the proposal - with the AskUserQuestion tool if you have it (options: Accept, Reject), otherwise as a one-line question. Stop and wait.

### 5. Record the verdict

Update the proposal's line in `docs/propose.md`:

- **Reject** - set the status to `rejected`. Then propose the likeliest reason in one line, labeled as your guess, and ask the user to confirm it - AskUserQuestion if you have it (options: Use this reason, No reason; the user can type their own under Other). Append it as a last column, ` | Reason: <reason>`, only if the user confirms it or gives their own; never record an unconfirmed guess. Word it impersonally (no "I", "me" or "my"), and confirm any rewording of the user's reason before recording it. Then stop; offer to run again for a different idea.
- **Accept** - set the status to `accepted` and go on to step 6.
- **Anything else** (a tweak, a question) - answer or adjust the pitch, update the line's title and description if the change itself changed, and ask again. Don't infer a verdict the user didn't give.

```markdown
- 2026-09-26 | low | rejected | Drop the second fuzzy finder - remove plugin B and move its two keymaps to plugin A, which already covers them. | Reason: plugin B's preview is still needed
```

Only touch the line for this proposal.

### 6. Plan it

Now the detail is worth writing, because the user wants the thing. Keep it concrete and grounded in the actual files:

- **Shape** - where it lands, which files change, what existing code, settings, or keymaps it builds on or touches, and the data flow where there is one.
- **Interface** - if it adds or changes one: the command and any arguments, or the function signature, with a sample invocation and its expected output.
- **Evidence** - what you verified and how (the gap in the code, what the schema or docs show the data can support, the last-commit date, the core feature and the version it landed in, the usage check), so the user can re-check it.
- **Steps** - the edits and the tests that will cover them, in order, then every command that installs, removes, or updates software or regenerates code, written out exactly. Keep each command as narrow as the change: update or delete the one plugin, upgrade the one dependency rather than running a recipe that updates everything. A command wider than the proposal churns things the user never agreed to; if a wide one is truly required, say what else it touches. End with the command that *verifies* the change landed. If only real data can prove it, say so here so the user can run it themselves.
- **Risks** - what the user has to relearn, what they lose, what could break, whether a lockfile churns, and anything tricky such as generated code, a schema or data-format change, a data migration, or a new dependency or binary. Be straight; a plan that only lists upside isn't credible.
- **Questions** - only decisions you genuinely can't make from the repo or sensible defaults. For anything else, pick the obvious option and state it in the plan.

Then ask the user to approve it - AskUserQuestion if you have it (options: Approve, Change, Stop). Nothing but the log has changed yet. On **Change**, revise and ask again. On **Stop**, leave the line `accepted` and stop - they can apply it later.

### 7. Build it

Only after the plan is approved. Apply the plan and nothing else: every changed line and every command run should trace to it. Approval covers the commands the plan listed, exactly as written, plus the repo's read-only build, test, and lint checks - if you find you need a different or wider one, stop and ask. Match the surrounding style and comment habits, add the tests the plan named, leave vendored files alone, put generated-code changes at their source and regenerate with the repo's recipe, and if the change needs a new binary, add it to the recipe the plan named so a fresh machine gets it too. The limits from the hard rule still apply to anything outside the plan - don't touch data, commit, call external APIs, or install or remove anything the plan didn't name.

Verify it the way the plan said, plus whatever the repo already uses to check itself (read the `justfile` and the formatter configs for its build, test, and lint recipes, or fall back to the language's standard tools): the tool starts cleanly, the removed thing is gone from the lockfile, the replacement answers the keys the old one did, the new command produces the expected output, using test fixtures where the repo holds private data. If something fails, fix it; if a fix would go beyond the plan, stop and ask.

When everything passes, set the proposal's status to `built` and leave the changes uncommitted for the user to review. Finish with a short summary: what changed, how you verified it, and what to try first.
