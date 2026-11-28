load helpers

# Run each test in a new repo with one commit holding a 20-line file a and a file b;
# the repo sits in a subfolder so patches can be written outside it
setup() {
    script="$BATS_TEST_DIRNAME/../.claude/skills/commit/commit.sh"
    mkdir "$BATS_TEST_TMPDIR/repo"
    cd "$BATS_TEST_TMPDIR/repo" || return 1
    git init -q
    git config user.name test
    git config user.email test@example.com
    seq 1 20 >a
    echo b >b
    git add -A
    git commit -qm init
}

@test "commit.sh check fails when there is nothing to commit" {
    run "$script" check
    [ "$status" -eq 1 ]
    same "$output" "nothing to commit"
}

# Two groups: the first takes the top hunk of a plus all of b, the second takes
# the bottom hunk of a plus a new file; nothing should be left over or stashed
@test "commit.sh commits two groups, one file split between them" {
    sed -i.bak -e 's/^1$/1x/' -e 's/^20$/20x/' a && rm a.bak
    echo b2 >>b
    echo new >new
    "$script" diff a | awk '/^@@/{n++} n<2' >../top.patch

    "$script" stage ../top.patch b
    "$script" commit "first" "the reason"
    "$script" stage a new
    "$script" commit "second"

    same "$(git log --format=%s | paste -sd ' ' -)" "second first init"
    same "$(git log -1 --skip=1 --format=%b)" "the reason"
    same "$(git show --format= --name-only HEAD~1 | paste -sd ' ' -)" "a b"
    same "$(git status --porcelain)" ""
    same "$(git stash list)" ""
}

@test "commit.sh stop brings back the rest without committing" {
    echo b2 >>b
    echo a2 >>a
    "$script" stage b
    "$script" stop

    same "$(git log --format=%s)" "init"
    same "$(git status --porcelain | paste -sd ' ' -)" " M a M  b"
    same "$(git stash list)" ""
}
