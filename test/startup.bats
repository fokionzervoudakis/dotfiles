load helpers

# Start an interactive login zsh, as the terminal does, so .zprofile runs too; the zle warning appears only because no terminal is attached
zsh_startup() {
    zsh -il -c exit 2>&1 | grep -v "can't change option: zle"
}

@test "zsh startup" {
    quiet zsh_startup
}

@test "nvim startup" {
    quiet nvim --headless +qa
}

@test "nvim tools" {
    quiet nvim --headless -c 'luafile scripts/nvim-tools.lua' +qa
}

# Fails when a file in the repo would collide with a real file already in $HOME
@test "stow links" {
    stow -n -R --no-folding --target ~ .
}

# A throwaway server on its own socket, which exits once the file is read; a bad
# line in .tmux.conf otherwise shows only as a brief message when a client attaches
@test "tmux config" {
    tmux -L dotfiles-test -f /dev/null start-server \; source-file .tmux.conf
}

# A key bound to a script that was renamed or deleted loads without complaint
@test "bound scripts exist" {
    local f missing=0
    while IFS= read -r f; do
        [ -f "$f" ] || { echo "missing $f"; missing=1; }
    done < <(grep -o '\.config/tmux/[^ "]*' .tmux.conf | sort -u)
    [ "$missing" = 0 ]
}
