# Interactive shell configuration. Environment and PATH live in .zprofile.

: ${HOMEBREW_PREFIX:=/opt/homebrew}
: ${XDG_CONFIG_HOME:=$HOME/.config}

# History
HISTFILE="$HOME/.zsh_history"
HISTSIZE=50000
SAVEHIST=50000
setopt SHARE_HISTORY
setopt HIST_IGNORE_SPACE
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_REDUCE_BLANKS

# Completions
#
# brew shellenv in .zprofile puts Homebrew's site-functions (brew, git, just, eza,
# gh and others) on fpath.
# No -C: it reuses ~/.zcompdump without rescanning fpath, so completions for
# tools installed after the dump was written are never picked up.
autoload -Uz compinit && compinit
# Homebrew's git completion only matches from the start of a filename, so
# "g add pro<Tab>" never finds .zprofile. Load zsh's built-in one instead.
if [[ -r /usr/share/zsh/$ZSH_VERSION/functions/_git ]]; then
  unfunction _git
  autoload -Uz /usr/share/zsh/$ZSH_VERSION/functions/_git
fi
zstyle ':completion:*' menu no # fzf-tab draws the menu; menu select would fight it
# Case-insensitive prefix, then substring.
zstyle ':completion:*' matcher-list \
  'm:{a-z}={A-Za-z}' \
  'm:{a-z}={A-Za-z} l:|=* r:|=*'

# Vi key bindings
bindkey -v
export KEYTIMEOUT=1

# bindkey -v binds backspace and friends to vi-* widgets that refuse to delete
# past the point insert mode was last entered, so they do nothing on recalled
# history or text typed before the last Esc. The plain widgets have no such
# restriction.
bindkey -M viins '^?' backward-delete-char
bindkey -M viins '^W' backward-kill-word
bindkey -M viins '^U' backward-kill-line

# Shape the cursor per vi mode: block is normal, beam is insert. Must precede
# starship's init, which wraps a pre-existing zle-keymap-select rather than
# replacing it.
vi_cursor() { [[ $KEYMAP == vicmd ]] && print -n '\e[2 q' || print -n '\e[6 q' }
zle -N zle-keymap-select vi_cursor
zle -N zle-line-init vi_cursor

# Aliases

# brew's ask mode is on by default and prompts whenever a plan pulls in
# packages beyond the ones named. b skips it; type brew in full to be asked.
alias b='HOMEBREW_NO_ASK=1 brew'
alias back=backup_run
alias dback=backup_dry_run

alias c=clear
alias cat=bat
alias claude='claude --dangerously-skip-permissions'
alias cl=claude

alias diff='diff --color'

alias g=git

# zsh's history shows only the last 16 entries; start from event 1 for all of them
alias h='history 1'

alias j=just

alias ls='eza --icons=auto'
alias ll='eza -lh --icons --git'
alias lla='ll -a'
alias llt='eza --tree --icons -a --ignore-glob=.git --level=2'

alias m=just

# exec rather than source: re-sourcing double-loads zsh-syntax-highlighting
alias r='exec zsh'
alias rmds='find . -name .DS_Store -delete'

alias tm=tmux

alias untar='tar -xvf'

alias vim=nvim
alias v=nvim

# Functions

# Emptying HISTFILE leaves the entries in the in-memory list, so exec a fresh
# shell to drop them from the current session's recall too.
history_clear() {
    : >| "$HISTFILE"
    exec zsh
}
alias hc=history_clear

# Counts the current directory when called with no arguments (plain cloc only
# prints its usage), and always skips node_modules.
cloc() {
    (( $# )) || set -- .
    command cloc --exclude-dir=node_modules "$@"
}

# With arguments, eject those. Without, pick from /Volumes with fzf (Tab marks
# several). Only real directories are listed, which leaves out the
# "Macintosh HD" symlink to / and keeps external disks, disk images and shares.
unmount() {
    local vols=("$@") vol
    (( $# )) || vols=(${(f)"$(find /Volumes -mindepth 1 -maxdepth 1 -type d | fzf --multi)"})
    # diskutil eject takes one volume per call
    for vol in $vols; do
        diskutil eject "$vol"
    done
}

# takes source and destination; trailing arguments are passed through to rsync.
# The source is normalized to always end in / so a bare directory (e.g. `back
# ~/dotfiles .`) merges its contents into the destination, same as `.` does,
# instead of nesting the source dir one level deeper.
#
# On exFAT/FAT32 drives, add --no-perms to stop re-listing backed-up files.
backup_run() {
    local src=$1
    shift
    [[ -d $src && $src != */ ]] && src+=/
    # Defaults go first so trailing flags (e.g. --no-perms) can override them.
    rsync --verbose \
        --archive \
        --delete \
        --human-readable \
        --exclude .git/ \
        --exclude '._*' \
        "$src" "$@"
}

backup_dry_run() {
    backup_run "$@" --dry-run
}

# Per-tool configuration
for __zsh_conf in "$XDG_CONFIG_HOME"/zsh/*.zsh(N); do
    source "$__zsh_conf"
done
unset __zsh_conf

# Tool initialization
#
# zsh-syntax-highlighting must be sourced last; it wraps the widgets the
# preceding integrations install.
# Tab completion menus in fzf; needs compinit and bindkey -v above, and must
# precede the widget wrappers below
source "$HOMEBREW_PREFIX/opt/fzf-tab/share/fzf-tab/fzf-tab.zsh"
source "$HOMEBREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
export FZF_CTRL_R_OPTS='--reverse' # Ctrl-R history search with the prompt on top
source <(fzf --zsh)
eval "$(zoxide init zsh)" # provides z and zi
eval "$(starship init zsh)"
source "$HOMEBREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"

# Machine-local overrides
#
# Sourced last so it can override anything above. Kept out of version control
# (see .gitignore) for per-machine secrets and settings.
[[ -f "$HOME/.zshrc.local" ]] && source "$HOME/.zshrc.local"
