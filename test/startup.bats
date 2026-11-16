load helpers

# A throwaway server on its own socket, which exits once the file is read; a bad
# line in .tmux.conf otherwise shows only as a brief message when a client attaches
@test "tmux loads .tmux.conf without errors" {
    tmux -L dotfiles-test -f /dev/null start-server \; source-file .tmux.conf
}

# A key bound to a script that was renamed, deleted, or is no longer executable
# loads without complaint
@test "tmux keys run scripts that are executable" {
    local f missing=0
    while IFS= read -r f; do
        [ -x "$f" ] || { echo "missing or not executable: $f"; missing=1; }
    done < <(grep -o '\.config/tmux/[^ "]*' .tmux.conf | sort -u)
    [ "$missing" = 0 ]
}
