load helpers

# The tmux scripts run only when a key is pressed, so the tests below run them
# against a throwaway tmux server: windows a, b and c in one session and d in a
# second. No terminal is attached to it, so the scripts get a tmux that writes
# "switch window" to a log, drops "show message" and passes everything else on.

# 3>&- keeps the server from holding bats' output open, which would hang the run
t() { tmux -L dotfiles-test-scripts "$@" 3>&-; }

setup_file() {
    cd "$BATS_TEST_DIRNAME/.." || return 1
    tmp=$(cd "$BATS_FILE_TMPDIR" && pwd -P) # tmux reports directories with symlinks resolved
    export tmp
    t kill-server 2>/dev/null || true # left over if an earlier run was cut short

    mkdir -p "$tmp/bin" "$tmp/home/alpha"
    cat >"$tmp/bin/tmux" <<FAKE
#!/bin/sh
case "\$1 \$2" in
"switch-client "*) echo "\$*" >>"$tmp/log" ;;
"display-message -p") exec "$(command -v tmux)" "\$@" ;; # a question, not a message
"display-message "*) ;;
*) exec "$(command -v tmux)" "\$@" ;;
esac
FAKE
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
    # The command the jump key runs, as written in .tmux.conf
    next_claude_binding=$(sed -n 's/.*run-shell "\(.*next-claude.*\)"$/\1/p' .tmux.conf)
    export win_a pane_a win_b win_c win_d tmux_env next_claude_binding
}

teardown_file() {
    t kill-server 2>/dev/null || true
}

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
@test "claude hooks write known states" {
    local cmd state ran=0
    while IFS= read -r cmd; do
        TMUX="$tmux_env" TMUX_PANE="$pane_a" sh -c "$cmd"
        state=$(t show-options -wqv -t "$win_a" @claude)
        case $state in
        working | blocked | 'done' | '') ran=1 ;;
        *) echo "unknown state '$state' from: $cmd"; return 1 ;;
        esac
    done < <(jq -r '.. | .command? // empty | select(test("@claude"))' .claude/settings.json)
    [ "$ran" = 1 ] || { echo 'found no hooks that write @claude'; return 1; }
}

@test "next-claude skips a working window" {
    marks - working 'done' blocked
    next_claude "$win_a" "$win_c"
}

@test "next-claude goes on into the next session" {
    marks - working 'done' blocked
    next_claude "$win_c" "$win_d"
}

@test "next-claude wraps past the last window" {
    marks - working 'done' blocked
    next_claude "$win_d" "$win_c"
}

@test "next-claude with nothing waiting elsewhere" {
    marks 'done' working - -
    next_claude "$win_a" ''
}

# alpha is the name of window a's directory
@test "pick-window switches to the pick" {
    pick_window alpha "$win_a"
}
