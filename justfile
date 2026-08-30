# Homebrew-driven setup for these dotfiles. See README.md for the bootstrap order.
#
# Recipes are quiet by default; run `just --no-quiet <recipe>` to echo commands.
set quiet

# List available recipes
default:
    just --list

# Run every recipe; note that postgres starts a background service
all: stow zsh brew git nvim tmux fonts util go lua java ruby postgres copilot

# Install stow and link the dotfiles into $HOME
[group('setup')]
stow:
    brew install stow
    stow -R --no-folding . # --no-folding links contents, not parent directories

# Configure Homebrew aliases
[group('setup')]
brew:
    brew alias | grep -q "clean=" || brew alias clean='cleanup && brew doctor' # `brew alias` is built in; the homebrew/aliases tap is deprecated

# Install zsh prompt, plugins, and version managers
[group('shell')]
zsh:
    brew install starship zoxide zsh-autosuggestions zsh-syntax-highlighting
    brew install fzf # .zshrc sources `fzf --zsh` at startup, so it must land here
    brew install fnm rbenv # Node and Ruby version managers, initialized in .zshrc

# Install tmux and plugin manager
[group('shell')]
tmux:
    brew install tmux
    [ -d "$HOME/.tmux/plugins/tpm" ] || git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"

# Install fonts
[group('shell')]
fonts:
    brew install --cask font-hack-nerd-font

# Install various utilities
[group('shell')]
util:
    brew install bat colordiff eza jq tokei
    brew install sevenzip # provides 7zz, used by the unzip alias in .zshrc

# Install Copilot CLI
[group('shell')]
copilot:
    brew install copilot-cli

# Configure Git and install related tools
[group('git')]
git:
    brew install czg # Conventional Commits prompt, aliased to `git cz`
    brew install gh # provides the zsh completions .zshrc picks up
    brew install gitleaks # required by hooks/pre-push
    brew install lazygit # required by lazygit.nvim and .config/lazygit
    git config core.hooksPath hooks

# Install Neovim and its external dependencies
[group('nvim')]
nvim:
    brew install neovim tree-sitter-cli
    brew install make # telescope-fzf-native and LuaSnip are compiled by nvim's PackChanged hook
    brew install fd ripgrep # required by Telescope
    brew install buf prettier shfmt sql-formatter # conform.nvim; the rest come from the go, lua and ruby recipes

# Install Go and its formatter
[group('lang')]
go:
    brew install go goimports # goimports is used by conform.nvim

# Install Lua and its package manager
[group('lang')]
lua:
    brew install lua luarocks lua-language-server stylua

# Install a JDK for nvim-jdtls
[group('lang')]
java:
    brew install openjdk # keg-only, so .zprofile puts it on PATH

# Install Ruby and its formatter
[group('lang')]
ruby:
    rbenv install --skip-existing 3.4.2 # rbenv comes from the zsh recipe
    rbenv global 3.4.2
    gem install rubocop # used by conform.nvim

# Install PostgreSQL and pgcli
[group('data')]
postgres:
    brew install postgresql@18
    brew services start postgresql@18
    brew install pgcli
