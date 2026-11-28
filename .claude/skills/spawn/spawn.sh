#!/usr/bin/env bash
# Helpers for the spawn skill. Usage: spawn.sh <step> [args]
set -euo pipefail

# Exit 1 with a message unless this runs inside tmux and a git repo.
check() {
  if [[ -z "${TMUX:-}" ]]; then
    echo "not inside tmux"
    exit 1
  fi
  if ! git rev-parse --show-toplevel >/dev/null 2>&1; then
    echo "not inside a git repo"
    exit 1
  fi
}

# Open a background tmux window running Claude in a new worktree named $1, with
# the prompt in file $2; adds -2, -3, ... to the name until no worktree uses it,
# and prints the name it used.
start() {
  local root name n=1
  root=$(git rev-parse --show-toplevel)
  name=$1
  while [[ -e "$root/.claude/worktrees/$name" ]]; do
    n=$((n + 1))
    name="$1-$n"
  done
  tmux new-window -d -c "$PWD" "claude --worktree '$name' \"\$(cat '$2')\""
  echo "$name"
}

case "${1:-}" in
  check | start) "$@" ;;
  *)
    echo "usage: spawn.sh check | start <name> <prompt file>" >&2
    exit 1
    ;;
esac
