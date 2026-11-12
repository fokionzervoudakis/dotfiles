#!/usr/bin/env bash
set -uo pipefail

# Run from the repo root so the relative paths below resolve
cd "$(dirname "$0")/.." || exit 1
failed=0

# Run one check; print its output only if it fails
check() {
    local name=$1
    shift
    if out=$("$@" 2>&1); then
        echo "ok   $name"
    else
        echo "FAIL $name"
        printf '%s\n' "$out"
        failed=1
    fi
}

# Fail if the command prints anything; nvim and zsh exit 0 even after startup errors
quiet() {
    local out
    out=$("$@" 2>&1)
    [ -z "$out" ] || { printf '%s\n' "$out"; return 1; }
}

# Start an interactive login zsh, as the terminal does, so .zprofile runs too; the zle warning appears only because no terminal is attached
zsh_startup() {
    zsh -il -c exit 2>&1 | grep -v "can't change option: zle"
}

for f in .zshrc .zprofile .config/zsh/*.zsh .config/tmux/pick-dir; do
    check "zsh syntax $f" zsh -n "$f"
done
check "zsh startup" quiet zsh_startup
check "nvim startup" quiet nvim --headless +qa
check "nvim tools" quiet nvim --headless -c 'luafile scripts/nvim-tools.lua' +qa
# Fails when a file in the repo would collide with a real file already in $HOME
check "stow links" stow -n -R --no-folding --target ~ .
# A throwaway server on its own socket, which exits once the file is read; a bad
# line in .tmux.conf otherwise shows only as a brief message when a client attaches
check "tmux config" tmux -L dotfiles-test -f /dev/null start-server \; source-file .tmux.conf

exit $failed
