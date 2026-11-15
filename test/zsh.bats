load helpers

# Run backup_run from .zshrc on its own: cut its definition out of the file and
# call it in a zsh that reads no startup files, so nothing else in .zshrc runs
backup_run() {
    zsh -fc "$(sed -n '/^backup_run() {/,/^}/p' .zshrc)"'; backup_run "$@"' zsh "$@"
}

# A source with one file and a destination holding a file the source lacks
setup_dirs() {
    src=$BATS_TEST_TMPDIR/src
    dst=$BATS_TEST_TMPDIR/dst
    mkdir "$src" "$dst"
    echo new >"$src/a"
    echo old >"$dst/stale"
}

# Without the / that backup_run adds, rsync would put src inside dst and delete
# everything else there
@test "back merges a directory named without a trailing slash" {
    setup_dirs
    backup_run "$src" "$dst"
    same "$(ls "$dst")" a
}

@test "back passes trailing flags on to rsync" {
    setup_dirs
    backup_run "$src" "$dst" --dry-run
    same "$(ls "$dst")" stale
}

@test "back copies a single file" {
    setup_dirs
    backup_run "$src/a" "$dst/b"
    same "$(cat "$dst/b")" new
}

# Run one function from a zsh file on its own, the way backup_run does above.
# $2 is zsh code that replaces the commands the function calls
run_fn() {
    local file=$1 fakes=$2 fn=$3 body
    shift 3
    body=$(sed -n "/^$fn() {/,/^}/p" "$file")
    zsh -fc "$fakes; $body; $fn \"\$@\"" zsh "$@"
}

# With no pod name, kubectl describe pod describes every pod in the namespace
@test "ctldescribe runs nothing when the picker is cancelled" {
    run run_fn .config/zsh/kubectl.zsh '__kpick() { }; kubectl() { print kubectl "$@" }' ctldescribe
    same "$output" ""
}

@test "ctldescribe describes every pod picked" {
    run run_fn .config/zsh/kubectl.zsh '__kpick() { print -l a b }; kubectl() { print kubectl "$@" }' ctldescribe
    same "$output" "kubectl describe pod a b"
}

@test "unmount ejects its arguments without opening the picker" {
    run run_fn .zshrc 'fzf() { print picked }; diskutil() { print diskutil "$@" }' unmount "/Volumes/A B" /Volumes/C
    same "$output" $'diskutil eject /Volumes/A B\ndiskutil eject /Volumes/C'
}

@test "unmount ejects each volume picked" {
    run run_fn .zshrc 'find() { print -l "/Volumes/A B" /Volumes/C }; fzf() { cat }; diskutil() { print diskutil "$@" }' unmount
    same "$output" $'diskutil eject /Volumes/A B\ndiskutil eject /Volumes/C'
}
