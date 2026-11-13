# Login shell environment. Interactive settings live in .zshrc.

# add Homebrew to path and set HOMEBREW_PREFIX, MANPATH, INFOPATH
eval "$(/opt/homebrew/bin/brew shellenv)"

# keep path and fpath entries unique so this file is safe to source more than once
# (tmux starts each pane as a login shell)
typeset -U path PATH fpath

# set XDG config home so XDG-aware tools (e.g. lazygit) use ~/.config on macOS
export XDG_CONFIG_HOME="$HOME/.config"

# use nvim wherever a program opens an editor
export EDITOR=nvim VISUAL=nvim

export GOPATH="$HOME/go"

# point JAVA_HOME-aware tools (Gradle, Maven) at Homebrew's keg-only JDK
# (each Java project's own justfile installs the JDK; this repo does not)
export JAVA_HOME="$HOMEBREW_PREFIX/opt/openjdk/libexec/openjdk.jdk/Contents/Home"

path=(
    "$HOMEBREW_PREFIX/opt/openjdk/bin"
    "$GOPATH/bin"
    "$HOME/.local/bin"
    $path
)

export NODE_PATH="$HOMEBREW_PREFIX/lib/node_modules/"

export JQ_COLORS='36;1:35;1:33;1:34;1:38;1:32;1:90;1:97;1:49'

# starship draws the virtualenv indicator itself
export VIRTUAL_ENV_DISABLE_PROMPT=true
