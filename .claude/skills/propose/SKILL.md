---
name: propose
description: Survey this dotfiles repo and write up one high-value proposal to change the *stack itself* - a plugin or tool to add, remove, replace, or consolidate. Use whenever the user asks "what should I add", "should I swap X for Y", "are any of my plugins obsolete", "what am I missing", "propose an improvement to my setup", "is this still the right tool", or invokes /propose, without naming a specific change. The skill chooses what to propose and writes a concrete, reviewable proposal - it does NOT apply it. No files change.
---

# Propose

Pick the single most valuable change to *what this setup is made of*, and write it up as a concrete, reviewable proposal. One run produces one focused proposal - a clear pitch the user can accept, reject, or refine. **You do not apply it.** No files change. The deliverable is the proposal itself.

This is the sibling of `/improve`, aimed one level up. `improve` asks "is this config **correct**?" - it reads the files offline, finds bugs, dead settings, deprecated idioms, and formatting drift, and applies the fixes the user approves. `propose` asks "is this config still the **right choice**?" - whether a plugin has been superseded, whether two tools are doing one job, whether something the user reaches for daily is missing. Those are different questions with different evidence: `improve` finds its answers inside the repo, `propose` usually cannot. The value here is *judgment plus restraint*: surveying what the setup is today, spotting the one change a thoughtful user would make next, and describing it well enough to decide on - without jumping to make it.

## Hard rule: propose, don't execute

This skill is read-only on the working tree. Do **not** create, edit, or delete config files, do **not** run `just` recipes (every one of them installs software via `brew` or `npm`), do **not** run `stow`, and do **not** touch `.config/nvim/lazy-lock.json` or run any `:Lazy` command that would install, update, or remove a plugin. Surveying with read-only commands (`ls`, `grep`, `cat`, `git log`, `just --list`, `nvim --headless` startup profiling, web research) is expected and encouraged - you need to understand the setup to propose well. But the run ends with a written proposal, not a change.

If you catch yourself editing a `.lua` or `.zsh` file, stop - that's out of scope for this skill. If the user likes the proposal, *they* will green-light building it.

## What "high-value" means here

A dotfiles repo is not a codebase that grows features; it is a set of *choices* that silently rots as the ecosystem moves. Plugins get archived. Their best ideas get absorbed into core. Two tools that were complementary in 2023 became redundant in 2025. So you're optimizing for the change that most improves the setup per unit of disruption to the user's habits.

Good candidates, roughly in order of how often they pay off:

- **Redundancy worth collapsing** - two plugins or tools doing one job. This is usually the highest-value find, because removal is pure profit: less to maintain, fewer keymaps competing, faster startup, one thing to learn instead of two. Look hard at the whole set, not at each file in isolation - redundancy is invisible when you read one plugin spec at a time.
- **Something superseded** - a plugin that is archived or effectively unmaintained, whose job Neovim core now does natively, or that a clearly better-maintained option has replaced. Check the *evidence*, not the vibe: last commit date, an archive notice, an upstream deprecation, a `:h` entry that now covers it.
- **A real gap** - a capability the setup lacks that the user's *own existing choices* imply they'd want. The justification has to come from this repo, not from a "top 10 plugins" list. If you can't point at something already here that makes the gap felt, it's not a gap, it's a suggestion.
- **Non-nvim stack choices** - zsh plugins and aliases, overlap between tmux and wezterm, the CLI utilities installed by `just util`, git aliases and hooks. These get less attention than the nvim config and drift just as much.

Lower value, usually skip: cosmetic swaps, "this plugin is popular" with no argument for why it fits *this* setup, anything requiring the user to relearn their workflow for a marginal gain, and migrating to a config distro or framework. Aim for the minimum change that solves a real problem, nothing speculative - it should be something the user would call *worth doing*, not just *doable*.

**Weigh switching cost honestly.** This is the thing that separates a real dotfiles proposal from a bad one. Config is muscle memory. A plugin that is 20% better but rebinds keys the user has typed ten thousand times is a *bad* trade, and a proposal that ignores that is not credible. Say plainly what the user would have to relearn.

## The loop

### 1. Survey what's actually here

Map the setup as it stands, so your proposal is genuinely new and actually fits:

```sh
ls .config/nvim/lua/custom/plugins/          # the plugins the user deliberately chose
cat .config/nvim/lazy-lock.json              # everything installed, including transitive deps
grep -rn 'vim.keymap.set' .config/nvim/lua/  # the keymaps in play - the collision surface
grep -rn 'alias ' .zshrc .config/zsh/        # shell shortcuts, i.e. what the user types most
just --list                                  # the install surface (see below)
git log --oneline -20                        # what the user has been changing lately
```

Two structural facts about this repo that shape what you can propose:

- `.config/nvim/init.lua` is vendored Kickstart.nvim, kept close to upstream. It is not the user's config and is not where proposals land. The real surface is `lua/keymaps.lua`, `lua/options.lua`, and `lua/custom/plugins/*.lua`, which load after Kickstart and intentionally override it. But **do read `init.lua`** during the survey - it's what installs mini.nvim, telescope, treesitter, LSP and friends, so a plugin you think is missing may already be there, and a redundancy may span the Kickstart/custom boundary.
- Anything requiring a new binary needs a `just` recipe to install it. A proposal that adds a dependency without saying which recipe changes is incomplete.

Don't over-survey. Enough to know the vocabulary and spot a real candidate. If two or three compete, pick the best value-to-disruption ratio and note the others at the end.

**Before proposing to remove or replace anything, check whether it's actually used.** The config tells you what's *installed*, never what's *reached for* - a plugin abandoned two years ago and one used every morning are byte-for-byte indistinguishable in a spec file. Proposing to delete something the user depends on is the worst output this skill can produce, and it's also the cheapest error to avoid, because the evidence is sitting right outside the config:

```sh
ls -d ~/some/configured/path        # does the directory it points at even exist?
find ~/that/path -type f -newermt "3 months ago" | head   # is anything recent?
git -C ~/that/repo log -1 --date=short --format="%ad"     # last activity
```

Two plugins that look like obvious redundancy can turn out to be two live systems the user runs deliberately for different purposes. Equally, a stack that looks healthy can be pointed at a directory nobody has touched in a year - which turns a vague "you have two of these" into a specific, well-evidenced proposal. Either way the check changes the answer, so run it before you commit to a candidate rather than after.

### 2. Check the outside world

This step is what makes the proposal worth reading, and it's the one you cannot skip. **The files cannot tell you the ecosystem moved.** A plugin spec looks exactly the same the day it's written and three years after the repo was archived. `improve` is blind to this by construction; `propose` is where it gets caught.

For the candidate(s) you're weighing, verify against current reality rather than recalled reality - your training cutoff is behind the user's Neovim:

- Is the repo archived, or has it gone quiet? Check the actual last-commit date.
- Has Neovim core absorbed the functionality? Core has been steadily eating plugin territory (LSP config, commenting, snippets, and more). Check the version the user is on.
- Is there a maintained successor the community actually moved to, or just a shinier alternative?
- If proposing a replacement, does it cover the *specific* features this config uses? Read the config's own options before claiming parity.

Prefer checking to guessing. One verified fact ("archived in March, upstream points at X") makes a proposal; three plausible-sounding claims sink one.

### 3. Decide and state it

Before writing the full proposal, name the one change you're proposing and *why it's the right one* in a sentence or two. If you can't articulate why the user would want it, it's not the right pick.

If nothing genuinely worthwhile turns up, say so. An honest "this setup is in good shape, here's the one marginal idea and why I set the others aside" is a legitimate and useful outcome - it tells the user their config is done, which is worth knowing. Inventing a change to look productive is the failure mode this skill exists to avoid.

### 4. Write the proposal

This is the deliverable. Keep it concrete and grounded in the actual files - reference real paths, real plugin names, real keymaps. Structure it as:

- **What** - the change, in one or two sentences. Add, remove, replace, or consolidate what, exactly?
- **Why** - the value, and the evidence behind it. What does the user get, and what specifically did you verify (archived repo, core coverage, the two plugins that overlap)?
- **How it fits** - which files change (`lua/custom/plugins/<name>.lua`, `.zshrc`, the `justfile`), which existing settings and keymaps it touches, and what it interacts with. Enough that the reader can picture the shape without you writing it.
- **Sketch** - the shape, not the finished config: the plugin spec skeleton, the keymaps that would change, or the abbreviation. Illustrative snippets are fine; a complete drop-in file is not. **Keep any command you recommend as narrow as the change.** The user will paste what you write, so a command wider than the proposal is a hazard rather than a convenience: `:Lazy sync` updates every plugin and churns the whole lockfile when `:Lazy update <plugin>` was the actual need, and `brew upgrade` is not `brew upgrade <formula>`. Reach for the narrowest form that does the job, and if a wide command genuinely is required, say what else it will touch. Where you can, include the command that *verifies* the change landed - it's the difference between the user hoping it worked and knowing.
- **Cost & risk** - rough size (small/medium/large), what the user has to relearn, what could break, whether it needs a `just` recipe or a new binary, whether `lazy-lock.json` churns. Call out anything that would make it *not* worth it. Be straight here; a proposal that only lists upside isn't a proposal, it's a pitch.
- **Open questions** - the decisions the user needs to make for this to proceed.

### 5. Hand it back

End the run with the proposal and nothing changed. Explicitly confirm you made no edits. Close with **Also considered** - the one or two other changes you weighed and set aside, one line each with the reason, so the user knows the space you looked at and doesn't have to wonder whether you noticed the obvious thing. Then stop: the next move is the user's - accept it, refine it, or ask for a different one.
