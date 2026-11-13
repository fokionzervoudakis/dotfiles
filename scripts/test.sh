#!/usr/bin/env bash
set -uo pipefail

# Run from the repo root so the relative paths below resolve
cd "$(dirname "$0")/.." || exit 1
failed=0

# Color only when writing to a terminal
if [ -t 1 ]; then
    green=$'\033[32m' red=$'\033[31m' reset=$'\033[0m'
else
    green='' red='' reset=''
fi

# Run one check; print its output, indented under its name, only if it fails
check() {
    local name=$1
    shift
    if out=$("$@" 2>&1); then
        echo "${green}PASS${reset} $name"
    else
        echo "${red}FAIL${reset} $name"
        [ -z "$out" ] || printf '%s\n' "$out" | sed 's/^/     /'
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

# Feed the status line the JSON in $1 and compare what it prints with $2, colors included
statusline() {
    local got
    got=$(.claude/statusline.jq <<<"$1") || return 1
    [ "$got" = "$2" ] || { printf 'got  %s\nwant %s\n' "$got" "$2"; return 1; }
}

for f in .zshrc .zprofile .config/zsh/*.zsh .config/tmux/pick-dir .config/tmux/pick-window .config/tmux/next-claude; do
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
# Green below 50, yellow from 50, red from 80, and the decimals are dropped; a
# broken script otherwise shows only as a blank status line in Claude Code
check "statusline colors" statusline \
    '{"model":{"display_name":"M"},"context_window":{"used_percentage":49.9},"rate_limits":{"five_hour":{"used_percentage":50},"seven_day":{"used_percentage":80}}}' \
    $'M | context \e[32m49%\e[0m | session \e[33m50%\e[0m | weekly \e[31m80%\e[0m'
# A new session sends the model before any of the percentages
check "statusline without usage" statusline '{"model":{"display_name":"M"}}' 'M'

exit $failed
