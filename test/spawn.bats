load helpers

# Run each test in a new repo, with a fake tmux on PATH that writes its
# arguments to a log instead of opening a window
setup() {
    script="$BATS_TEST_DIRNAME/../.claude/skills/spawn/spawn.sh"
    mkdir "$BATS_TEST_TMPDIR/repo" "$BATS_TEST_TMPDIR/bin"
    printf '#!/bin/sh\necho "$@" >>"%s/log"\n' "$BATS_TEST_TMPDIR" >"$BATS_TEST_TMPDIR/bin/tmux"
    chmod +x "$BATS_TEST_TMPDIR/bin/tmux"
    PATH="$BATS_TEST_TMPDIR/bin:$PATH"
    cd "$BATS_TEST_TMPDIR/repo" || return 1
    git init -q
}

@test "spawn.sh check fails outside tmux" {
    TMUX='' run "$script" check
    [ "$status" -eq 1 ]
    same "$output" "not inside tmux"
}

@test "spawn.sh check fails outside a git repo" {
    cd "$BATS_TEST_TMPDIR" || return 1
    TMUX=x run "$script" check
    [ "$status" -eq 1 ]
    same "$output" "not inside a git repo"
}

@test "spawn.sh start opens a window with the name and prompt" {
    run "$script" start fix-bar /tmp/prompt.md
    same "$output" "fix-bar"
    same "$(cat "$BATS_TEST_TMPDIR/log")" "new-window -d -c $PWD claude --worktree 'fix-bar' \"\$(cat '/tmp/prompt.md')\""
}

# A reused name would open the old worktree and mix the new work into its changes
@test "spawn.sh start picks a name no worktree uses yet" {
    mkdir -p .claude/worktrees/fix-bar .claude/worktrees/fix-bar-2
    run "$script" start fix-bar /tmp/prompt.md
    same "$output" "fix-bar-3"
}
