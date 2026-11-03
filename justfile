# Homebrew-driven setup for these dotfiles. See README.md for the bootstrap order.
#
# Recipes are quiet by default; run `just --no-quiet <recipe>` to echo commands.
set quiet

# List available recipes
default:
    just --list

# Run every recipe
all: stow zsh brew git nvim tmux ghostty fonts util claude cloud go java

# Install stow and link the dotfiles into $HOME
[group('setup')]
stow:
    brew install stow
    stow -R --no-folding --target ~ . # link each file into $HOME; --no-folding links only the files in the repo, so new files in $HOME stay out of the repo

# Configure Homebrew aliases
[group('setup')]
brew:
    brew alias | grep -q "clean=" || brew alias clean='cleanup && brew doctor' # `brew alias` is built in; the homebrew/aliases tap is deprecated

# Install zsh prompt and plugins
[group('shell')]
zsh:
    brew install starship zoxide zsh-autosuggestions zsh-syntax-highlighting
    brew install fzf # .zshrc sources `fzf --zsh` at startup, so it must land here

# Install tmux
[group('shell')]
tmux:
    brew install tmux

# Install Ghostty
[group('shell')]
ghostty:
    brew install --cask ghostty # configured by .config/ghostty/config

# Install fonts
[group('shell')]
fonts:
    brew install --cask font-hack-nerd-font

# Install various utilities
[group('shell')]
util:
    brew install bat eza jq
    brew install sevenzip # provides 7zz, used by the unzip alias in .zshrc

# Install Claude Code
[group('shell')]
claude:
    curl -fsSL https://claude.ai/install.sh | bash # installs to ~/.local/bin, which .zprofile puts on PATH; configured by .claude

# Install the AWS and Kubernetes CLIs
[group('shell')]
cloud:
    brew install awscli # provides aws, used by .config/zsh/aws.zsh
    brew install kubernetes-cli # provides kubectl, used by .config/zsh/kubectl.zsh
    brew install kubectx # provides kubectx and kubens

# Configure Git and install related tools
[group('git')]
git:
    brew install czg # Conventional Commits prompt, aliased to `git cz`
    brew install gh # provides the zsh completions .zshrc picks up
    brew install gitleaks # required by hooks/pre-push
    brew install lazygit # required by lazygit.nvim and .config/lazygit
    brew install git-delta # diff renderer for .config/lazygit
    git config core.hooksPath hooks

# Install Neovim and its external dependencies
[group('nvim')]
nvim:
    brew install neovim tree-sitter-cli
    brew install ripgrep # Telescope file search and live grep
    brew install node

# Install Go and its formatter
[group('lang')]
go:
    brew install go

# Install a JDK for nvim-jdtls
[group('lang')]
java:
    brew install openjdk # keg-only, so .zprofile puts it on PATH
