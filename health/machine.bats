load ../test/helpers

# Start an interactive login zsh, as the terminal does, so .zprofile runs too; the zle warning appears only because no terminal is attached
zsh_startup() {
    zsh -il -c exit 2>&1 | grep -v "can't change option: zle"
}

@test "zsh starts without printing anything" {
    quiet zsh_startup
}

@test "nvim starts without printing anything" {
    quiet nvim --headless +qa
}

@test "nvim can run every formatter and language server it uses" {
    quiet nvim --headless -c 'luafile scripts/nvim-tools.lua' +qa
}

# A missing program fails without a message: the popup closes as soon as the
# shell reports it, and the status line goes blank. The popup programs are read
# from tmux's own key list, so a new binding is checked too.
@test "tmux keys and the Claude status line can run their programs" {
    local prog found=0 missing=0
    while IFS= read -r prog; do
        found=1
        command -v "$prog" >/dev/null || { echo "missing: $prog"; missing=1; }
    done < <(
        tmux -L dotfiles-health -f /dev/null start-server \; source-file .tmux.conf \; list-keys |
            sed -nE 's/.*display-popup( -[A-Za-z]( "[^"]*"| [^-" ][^ ]*)?)* "?([^ "]*).*/\3/p'
        sed -n '1s/^#!.*env -S \([^ ]*\).*/\1/p' .claude/statusline.jq
    )
    [ "$found" = 1 ] || { echo 'found no programs to check'; return 1; }
    [ "$missing" = 0 ]
}

# Fails when a file in the repo would collide with a real file already in $HOME
@test "stow can link every file into the home directory" {
    stow -n -R --no-folding --target ~ .
}
