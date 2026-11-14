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
