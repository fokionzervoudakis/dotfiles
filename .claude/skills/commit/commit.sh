#!/usr/bin/env bash
# Helpers for the commit skill. Usage: commit.sh <step> [args]
set -euo pipefail

# Exit 1 with a message if there is nothing to commit.
check() {
  if [[ -z "$(git status --porcelain)" ]]; then
    echo "nothing to commit"
    exit 1
  fi
}

# Stage everything and scan it for secrets; exit 1 if betterleaks is missing or finds one.
scan() {
  if ! command -v betterleaks >/dev/null; then
    echo "betterleaks is not installed"
    exit 1
  fi
  git add -A
  betterleaks git --pre-commit --staged --no-banner
}

# Show all uncommitted changes, staged or not, optionally for the given paths only.
diff() {
  git diff HEAD -- "$@"
}

# Stage only the given files and .patch files, and stash everything else.
stage() {
  git reset -q
  for arg in "$@"; do
    if [[ "$arg" == *.patch ]]; then
      git apply --cached "$arg"
    else
      git add -- "$arg"
    fi
  done
  git stash push -q --keep-index --include-untracked -m commit-rest
}

# Commit the staged group with a subject and optional body, then bring back the stashed rest.
commit() {
  if [[ $# -ge 2 ]]; then
    git commit -q -m "$1" -m "$2"
  else
    git commit -q -m "$1"
  fi
  git stash pop -q
  git log -1 --format='%h %s'
}

# Bring back the stashed rest without committing.
stop() {
  git stash pop -q
}

case "${1:-}" in
  check | scan | diff | stage | commit | stop) "$@" ;;
  *)
    echo "usage: commit.sh check | scan | diff [path]... | stage <path|file.patch>... | commit <subject> [body] | stop" >&2
    exit 1
    ;;
esac
