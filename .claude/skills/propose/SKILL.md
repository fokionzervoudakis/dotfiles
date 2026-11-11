---
name: propose
description: Survey this dotfiles repo and pitch one high-value change to the *stack itself* - a plugin or tool to add, remove, replace, or consolidate. Use whenever the user asks "what should I add", "should I swap X for Y", "are any of my plugins obsolete", "what am I missing", "propose an improvement to my setup", "is this still the right tool", or invokes /propose, without naming a specific change. The skill checks docs/proposals.md so it never repeats an earlier idea, gives a short overview and asks the user to accept or reject it, writes a plan only if they accept, and applies it only once they approve the plan.
argument-hint: "[low|medium]"
---

# Propose

Pick the single most valuable change to *what this setup is made of* and pitch it in a few lines. The user decides at each step, and nothing is changed until they say so:

1. **Pitch** - a short overview. The user accepts or rejects it.
2. **Plan** - only if accepted: how it would be applied. The user approves it, asks for changes, or stops.
3. **Build** - only once the plan is approved.

This is the sibling of `/improve`, aimed one level up. `improve` asks "is this config **correct**?" and finds its answers inside the repo. `propose` asks "is this config still the **right choice**?" - whether a plugin has been superseded, whether two tools are doing one job, whether something the user reaches for daily is missing - and usually has to look outside the repo to answer. The value is in *judgment plus restraint*: spotting the one change a thoughtful user would make next, and letting them decide cheaply before anyone spends effort on it. That's why the pitch is short - a rejected idea should cost the user ten seconds of reading, not a page.

## Scope

The skill takes an optional scope: `/propose low` or `/propose medium`. With no argument, use `low`.

- **low** - favor the best value-to-disruption candidate, usually removing, swapping or consolidating one plugin or tool.
- **medium** - favor the candidate that most widens what the setup can do: a capability the user's own choices imply they want, or one tool replacing a whole layer, beats a one-plugin swap even at more relearning. The aliases, key bindings and recent `git log` show what the user reaches for daily, so start the search there.

## Hard rule: nothing changes until the plan is approved

Until the user approves a plan (step 6), the only file you touch is `docs/proposals.md`. No config files, no lockfiles, no installed software. Surveying with read-only commands (`git ls-files`, `ls`, `grep`, `git log`, `just --list`, a headless editor start, `gh api`, web research) is expected - you need to understand the setup to propose well. Before you run any `just` recipe, read what it does in the `justfile`: anything that installs or removes software, links files into `$HOME`, starts a service, or commits is off limits. The same goes for a plugin manager's install, update, and delete calls. Don't rely on a list of recipe or command names - this file can't know about a mutating one added after it was written.

If you catch yourself editing a config file before the user has approved a plan, stop.

## Plain ASCII only

Everything this skill outputs - the pitch, the plan, your replies, and the lines in `docs/proposals.md` - is plain ASCII: `-` or `--` instead of em/en dashes, `...` instead of an ellipsis, straight quotes, `->` instead of arrows, `|` as a separator, and no emoji. The user reads these in a terminal and in plain-text files, where typographic characters get in the way. Before you send anything, check it for characters outside ASCII and replace them.

## What "high-value" means here

A dotfiles repo is not a codebase that grows features; it is a set of *choices* that silently rots as the ecosystem moves. Plugins get archived. Their best ideas get absorbed into core. Two tools that were complementary a few years ago are redundant now. So you're optimizing for the change that most improves the setup per unit of disruption to the user's habits. What the setup *is* today comes from the tree, not from this file - step 1 derives it. Good candidates, roughly in order of how often they pay off:

- **Redundancy worth collapsing** - two plugins or tools doing one job. Usually the highest-value find, because removal is pure profit: less to maintain, fewer keymaps competing, one thing to learn instead of two. Look at the whole set, not each file in isolation - redundancy is invisible one spec at a time, and it often spans the boundary between a vendored base config and the user's own layer.
- **Something superseded** - a plugin or tool that is archived or has gone quiet, whose job the editor, shell, or terminal now does natively, or that a clearly better-maintained option has replaced.
- **A real gap** - a capability the setup lacks that the user's *own existing choices* imply they'd want. The justification has to come from this repo, not from a "top 10 plugins" list. If you can't point at something already here that makes the gap felt, it's a suggestion, not a gap.
- **The less-watched corners** - shell plugins and aliases, overlap between terminal and multiplexer, installed CLI utilities, git aliases and hooks. They get less attention than the editor config and drift just as much.

Lower value, usually skip: cosmetic swaps, "this plugin is popular" with no argument for why it fits *this* setup, and migrating to a config distro or framework. The bar is the minimum change that solves a *real* problem, nothing speculative: something the user would call *worth doing*, not just *doable*.

**Weigh switching cost honestly.** Config is muscle memory. A plugin that is 20% better but rebinds keys the user has typed ten thousand times is a bad trade, and a pitch that hides that is not credible.

## The loop

### 1. Survey

Start with the proposal log. Every earlier run added a line to
`docs/proposals.md` (newest first), and repeating one of them wastes the run - the user has
already seen it, and may have already rejected it:

```sh
cat docs/proposals.md 2>/dev/null
```

Treat every logged proposal as taken, whatever its status - `proposed` and
`accepted` ones are in the pipeline, `rejected` ones the user said no to, `built`
ones are already applied. Don't re-pitch a close variant either (the same swap
with a different replacement, or the same removal argued another way) unless you
can say what makes it materially different. Rejected lines also tell you what
this user doesn't value - if several are the same kind of idea, steer away from
that kind. Lines that carry a scope show which kind of idea each scope tends to
get accepted or rejected, so weigh most heavily the lines with this run's scope.
Older lines have no scope field; read them the same way otherwise.

Then get oriented in the setup. Map what it is made of **today** from the tree
itself - any map written down here would go stale, and proposing something that
is already there is an easy way for this skill to fail:

```sh
git ls-files                               # the config that is actually tracked
just --list                                # the install surface; read the justfile for what each recipe installs
git log --oneline -20                      # what the user has been changing lately
grep -rn 'keymap\|bindkey\|^bind' .        # the key bindings in play - the collision surface
grep -rn '^alias ' .                       # shell shortcuts, i.e. what the user types most
```

From there, find each tool's plugin list and its lockfile (which also shows
transitive dependencies), and read the comments and the README as you go - this
repo records its deliberate oddities in place. In particular, find anything
vendored from upstream and meant to stay close to it. Read it, because it
installs things too and a plugin you think is missing may already be there, but
a proposal lands in the user's own layer, never in the vendored file. And note
how software gets installed: a proposal that needs a new binary has to say which
recipe installs it.

**Before pitching to remove or replace anything, check whether it's actually used.** The config tells you what's *installed*, never what's *reached for* - a plugin abandoned two years ago and one used every morning look identical in a spec file. Pitching the removal of something the user depends on is the worst output this skill can produce, and the cheapest to avoid, because the evidence sits right outside the config:

```sh
ls -d ~/some/configured/path                             # does the directory it points at even exist?
git -C ~/that/path log -1 --date=short --format='%ad'    # last activity
git -C ~/that/path log --since='3 months ago' --oneline | wc -l
```

Two plugins that look like obvious redundancy can turn out to be two live systems the user runs deliberately. Equally, a healthy-looking stack can point at a directory nobody has touched in a year. Either way the check changes the answer, so run it before you commit to a candidate.

**Then check the outside world.** The files cannot tell you the ecosystem moved: a plugin spec looks the same the day it's written and three years after the repo was archived. Verify against current reality, not recalled reality - your training data is older than the user's installed versions:

- Is the repo archived, or has it gone quiet? Get the real last-commit date (`git ls-remote`, `gh api`, the plugin's own checkout).
- Has core absorbed the job? Check against the version the user is actually running.
- Is there a maintained successor people actually moved to, or just a shinier alternative?
- Does the replacement cover the *specific* options and keys this config uses? Read the config before claiming parity.

One verified fact makes a pitch; three plausible-sounding claims sink one.

Don't over-survey. A few minutes is enough to spot a real candidate. If two or three compete, pick the one the scope favors.

### 2. Decide

Pick the one change to pitch. Check it against the log from step 1 - if it's already there, pick again. If you can't say in a sentence why the user would want it, it's not the right pick. If nothing genuinely worthwhile turns up, say so - an honest "this setup is in good shape" beats inventing a change, and tells the user something worth knowing.

### 3. Pitch it

Keep it to a few lines - enough to decide on, nothing more. Ground it in the real files, but save the detail for the plan:

```
Proposal: <title>
<What gets added, removed, replaced, or consolidated - one or two sentences.>
Why: <the benefit, and the one fact you verified that backs it - one sentence.>
Size: <small|medium|large> - <what it touches, and what the user has to relearn (or "nothing to relearn")>
```

No sketch, no code, no open questions, no list of alternatives - all of that either belongs in the plan or doesn't matter if the answer is no. Only add a line if something would change the decision (a new binary, a feature the user loses, a wide lockfile churn).

### 4. Log it and ask

Add one line to `docs/proposals.md`, newest first: insert it directly below the heading, above the existing entries, so the latest proposal is always at the top. If the file doesn't exist, create it with the heading:

```markdown
# Proposals

Logged by /propose so it doesn't repeat itself. Change a status to accepted, rejected, or built.
```

Each line is `- <YYYY-MM-DD> | <scope> | proposed | <title> - <the What, in one sentence>`, where scope is the run's `low` or `medium`, for example:

```markdown
- 2026-09-26 | low | proposed | Drop the second fuzzy finder - remove plugin B and move its two keymaps to plugin A, which already covers them.
```

That line is only an illustration - don't copy it into the log. New lines always start as `proposed`. Don't stage or commit the file; the user decides whether the log goes in the repo.

Then ask the user to accept or reject the proposal - with the AskUserQuestion tool if you have it (options: Accept, Reject), otherwise as a one-line question. Stop and wait.

### 5. Record the verdict

Update the proposal's line in `docs/proposals.md`:

- **Reject** - set the status to `rejected`. Don't ask why. Then stop; offer to run again for a different idea.
- **Accept** - set the status to `accepted` and go on to step 6.
- **Anything else** (a tweak, a question) - answer or adjust the pitch, update the line's title and summary if the change itself changed, and ask again. Don't infer a verdict the user didn't give.

```markdown
- 2026-09-26 | low | rejected | Drop the second fuzzy finder - remove plugin B and move its two keymaps to plugin A, which already covers them.
```

Only touch the line for this proposal.

### 6. Plan it

Now the detail is worth writing, because the user wants the thing. Keep it concrete and grounded in the actual files:

- **Shape** - which files change, which existing settings and keymaps it touches, and what it interacts with.
- **Evidence** - what you verified and how (the last-commit date, the core feature and the version it landed in, the usage check), so the user can re-check it.
- **Steps** - the edits, in order, then every command that installs, removes, or updates software, written out exactly. Keep each as narrow as the change: update or delete the one plugin, upgrade the one formula. A command wider than the proposal churns things the user never agreed to; if a wide one is truly required, say what else it touches. End with the command that *verifies* the change landed.
- **Risks** - what the user has to relearn, what they lose, what could break, whether a lockfile churns, whether a `just` recipe or a new binary is needed. Be straight; a plan that only lists upside isn't credible.
- **Questions** - only decisions you genuinely can't make from the repo or sensible defaults. For anything else, pick the obvious option and state it in the plan.

Then ask the user to approve it - AskUserQuestion if you have it (options: Approve, Change, Stop). Nothing is changed yet. On **Change**, revise and ask again. On **Stop**, leave the line `accepted` and stop - they can apply it later.

### 7. Build it

Only after the plan is approved. Apply the plan and nothing else: every changed line and every command run should trace to it. Approval covers the commands the plan listed, exactly as written - if you find you need a different or wider one, stop and ask. Match the surrounding config's style and comment habits, leave vendored files alone, and if the change needs a new binary, add it to the recipe the plan named so a fresh machine gets it too. The limits from the hard rule still apply to anything outside the plan - don't commit, and don't install or remove anything the plan didn't name.

Verify it the way the plan said, plus whatever the repo already uses to check itself (read the `justfile` and the formatter configs): the tool starts cleanly, the removed thing is gone from the lockfile, the replacement answers the keys the old one did. If something fails, fix it; if a fix would go beyond the plan, stop and ask.

When everything passes, set the proposal's status to `built` and leave the changes uncommitted for the user to review. Finish with a short summary: what changed, how you verified it, and what to try first.
