# Shared by the .bats files.

# Run from the repo root so the relative paths in the tests resolve
setup() {
    cd "$BATS_TEST_DIRNAME/.." || return 1
}

# Fail if the command prints anything; nvim and zsh exit 0 even after startup errors
quiet() {
    local out
    out=$("$@" 2>&1) || true # only the output counts; bats would stop on the exit status
    [ -z "$out" ] || { printf '%s\n' "$out"; return 1; }
}

# Print both values when they differ
same() {
    [ "$1" = "$2" ] || { printf 'got  %s\nwant %s\n' "$1" "$2"; return 1; }
}
