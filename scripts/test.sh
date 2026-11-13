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

# Print both values when they differ
same() {
    [ "$1" = "$2" ] || { printf 'got  %s\nwant %s\n' "$1" "$2"; return 1; }
}

# Feed the status line the JSON in $1 and compare the color code and number of
# each percentage with $2; the labels and separators are left out, so rewording
# them does not fail this
statusline_colors() {
    same "$(.claude/statusline.jq <<<"$1" | grep -o $'\033\\[[0-9]*m[0-9]*%' | tr -d $'\033[' | paste -sd ' ' -)" "$2"
}

# A new session sends the model before any of the percentages; the line should
# still show the model instead of going blank
statusline_model_only() {
    .claude/statusline.jq <<<'{"model":{"display_name":"M"}}' | grep -q M
}

# Start an interactive login zsh, as the terminal does, so .zprofile runs too; the zle warning appears only because no terminal is attached
zsh_startup() {
    zsh -il -c exit 2>&1 | grep -v "can't change option: zle"
}

check "zsh startup" quiet zsh_startup
check "nvim startup" quiet nvim --headless +qa
check "nvim tools" quiet nvim --headless -c 'luafile scripts/nvim-tools.lua' +qa
# Fails when a file in the repo would collide with a real file already in $HOME
check "stow links" stow -n -R --no-folding --target ~ .
# A throwaway server on its own socket, which exits once the file is read; a bad
# line in .tmux.conf otherwise shows only as a brief message when a client attaches
check "tmux config" tmux -L dotfiles-test -f /dev/null start-server \; source-file .tmux.conf
# Green (32) below 50, yellow (33) from 50, red (31) from 80, and the decimals
# are dropped; a broken script otherwise shows only as a blank status line
check "statusline colors by percentage" statusline_colors \
    '{"model":{"display_name":"M"},"context_window":{"used_percentage":49.9},"rate_limits":{"five_hour":{"used_percentage":50},"seven_day":{"used_percentage":80}}}' \
    '32m49% 33m50% 31m80%'
check "statusline before usage is sent" statusline_model_only
# A key bound to a script that was renamed or deleted loads without complaint
while IFS= read -r f; do
    check "bound script $f" test -f "$f"
done < <(grep -o '\.config/tmux/[^ "]*' .tmux.conf | sort -u)

# The tmux scripts run only when a key is pressed, so the checks below run them
# against a throwaway tmux server: windows a, b and c in one session and d in a
# second. No terminal is attached to it, so the scripts get a tmux that writes
# "switch window" to a log, drops "show message" and passes everything else on.
tmp=$(cd "$(mktemp -d)" && pwd -P) # tmux reports directories with symlinks resolved
t() { tmux -L dotfiles-test-scripts "$@"; }
trap 't kill-server 2>/dev/null; rm -rf "$tmp"' EXIT
t kill-server 2>/dev/null # left over if an earlier run was cut short

mkdir -p "$tmp/bin" "$tmp/home/alpha"
cat >"$tmp/bin/tmux" <<EOF
#!/bin/sh
case "\$1 \$2" in
"switch-client "*) echo "\$*" >>"$tmp/log" ;;
"display-message -p") exec "$(command -v tmux)" "\$@" ;; # a question, not a message
"display-message "*) ;;
*) exec "$(command -v tmux)" "\$@" ;;
esac
EOF
chmod +x "$tmp/bin/tmux"

t -f /dev/null new-session -d -s s1 -c "$tmp/home/alpha" 'sleep 600'
t set -g default-command 'sleep 600' # what the other windows run
win_a=$(t display-message -p -t s1 '#{window_id}')
pane_a=$(t display-message -p -t s1 '#{pane_id}')
win_b=$(t new-window -d -t s1: -P -F '#{window_id}' -c "$tmp/home")
win_c=$(t new-window -d -t s1: -P -F '#{window_id}' -c "$tmp/home")
win_d=$(t new-session -d -s s2 -P -F '#{window_id}' -c "$tmp/home")
# what tmux puts in $TMUX inside a pane; it is how a script finds its server
tmux_env=$(t display-message -p '#{socket_path},#{pid},0')

# Run a script against the throwaway server. $1 is what is typed into fzf,
# which with --filter prints the matches instead of opening.
run_script() {
    local typed=$1
    shift
    : >"$tmp/log"
    PATH="$tmp/bin:$PATH" TMUX="$tmux_env" FZF_DEFAULT_OPTS="--filter=$typed" "$@"
}

# The id of the window the last script switched to, or nothing. tmux resolves
# whatever the script passed, so a script may name the window any way tmux accepts.
switched() {
    local target
    target=$(sed -n 's/^switch-client -t //p' "$tmp/log")
    [ -z "$target" ] || t display-message -p -t "$target" '#{window_id}'
}

# Set the Claude state of windows a, b, c and d; - clears it
marks() {
    local w
    for w in "$win_a" "$win_b" "$win_c" "$win_d"; do
        if [ "$1" = - ]; then t set -wqu -t "$w" @claude; else t set -w -t "$w" @claude "$1"; fi
        shift
    done
}

# The command the jump key runs, as written in .tmux.conf
next_claude_binding=$(sed -n 's/.*run-shell "\(.*next-claude.*\)"$/\1/p' .tmux.conf)

# Press the key in window $1; it should switch to window $2, or nowhere if $2 is
# empty. tmux fills in the binding's #{...} for that window, as it does on a real
# key press, so a binding that stops passing the window fails here too.
next_claude() {
    local cmd
    cmd=$(t display-message -p -t "$1" "$next_claude_binding")
    run_script '' sh -c "${cmd#\~/}" || return 1 # ~/.config/... is .config/... in the repo
    same "$(switched)" "$2"
}

# Type $1; it should switch to window $2
pick_window() {
    run_script "$1" .config/tmux/pick-window || return 1
    same "$(switched)" "$2"
}

# Run each hook that writes the tab mark, as Claude would from window a; what it
# leaves there must be a state the tab formats and next-claude know. A wrong
# state fails silently: the * never shows and the jump key finds nothing.
claude_hooks() {
    local cmd state ran=0
    while IFS= read -r cmd; do
        TMUX="$tmux_env" TMUX_PANE="$pane_a" sh -c "$cmd" || return 1
        state=$(t show-options -wqv -t "$win_a" @claude)
        case $state in
        working | blocked | 'done' | '') ran=1 ;;
        *) echo "unknown state '$state' from: $cmd"; return 1 ;;
        esac
    done < <(jq -r '.. | .command? // empty | select(test("@claude"))' .claude/settings.json)
    [ "$ran" = 1 ] || { echo 'found no hooks that write @claude'; return 1; }
}

check "claude hooks write known states" claude_hooks

marks - working 'done' blocked
check "next-claude skips a working window" next_claude "$win_a" "$win_c"
check "next-claude goes on into the next session" next_claude "$win_c" "$win_d"
check "next-claude wraps past the last window" next_claude "$win_d" "$win_c"
marks 'done' working - -
check "next-claude with nothing waiting elsewhere" next_claude "$win_a" ''

check "pick-window switches to the pick" pick_window alpha "$win_a"

exit $failed
