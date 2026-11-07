# Homebrew-driven setup for these dotfiles. See README.md for the bootstrap order.
#
# Recipes are quiet by default; run `just -v <recipe>` to echo commands.
set quiet

# List available recipes
default:
    just --list

# Install stow and link the dotfiles into $HOME
[group('setup')]
stow:
    brew install stow
    stow -R --no-folding --target ~ . # link each file into $HOME; --no-folding links only the files in the repo, so new files in $HOME stay out of the repo

# Configure Homebrew aliases
[group('setup')]
brew:
    brew alias | grep -q "clean=" || brew alias clean='cleanup && brew doctor' # `brew alias` is built in; the homebrew/aliases tap is deprecated

# Install the zsh prompt and plugins, and the tools .zshrc aliases
[group('setup')]
shell:
    brew install starship zoxide zsh-autosuggestions zsh-syntax-highlighting
    brew install fzf # .zshrc sources `fzf --zsh` at startup, so it must land here
    brew install bat # aliased to cat; configured by .config/bat/config
    brew install eza # aliased to ls, ll, and llt
    brew install cloc # wrapped by the cloc function
    brew install sevenzip # provides 7zz, aliased to unzip

# Install Ghostty, the Nerd Font, and tmux
[group('setup')]
terminal:
    brew install --cask ghostty # configured by .config/ghostty/config
    brew install --cask font-hack-nerd-font # Neovim's icons need a Nerd Font
    brew install tmux

# Install Claude Code
[group('setup')]
claude:
    curl -fsSL https://claude.ai/install.sh | bash # installs to ~/.local/bin, which .zprofile puts on PATH; configured by .claude

# Install jq
[group('setup')]
jq:
    brew install jq # runs .claude/statusline.jq; also used by conform.lua and .config/zsh/kubectl.zsh

# Install the AWS CLI
[group('setup')]
aws:
    brew install awscli # provides aws, used by .config/zsh/aws.zsh

# Install kubectl, kubectx, and kubens
[group('setup')]
kube:
    brew install kubernetes-cli # provides kubectl, used by .config/zsh/kubectl.zsh
    brew install kubectx # provides kubectx and kubens

# Install Git tools and enable the repo's Git hooks
[group('setup')]
git:
    brew install czg # Conventional Commits prompt, aliased to `git cz`
    brew install gh # provides the zsh completions .zshrc picks up
    brew install gitleaks # required by hooks/pre-push
    brew install lazygit # required by lazygit.nvim and .config/lazygit
    brew install git-delta # diff renderer for .config/lazygit
    git config core.hooksPath hooks # run hooks/pre-push before every push

# Install Neovim and its external dependencies
[group('setup')]
nvim: go java
    brew install neovim tree-sitter-cli
    brew install ripgrep # Telescope file search and live grep
    brew install node

# Install Go
[group('setup')]
go:
    brew install go

# Install a JDK for nvim-jdtls
[group('setup')]
java:
    brew install openjdk # keg-only, so .zprofile puts it on PATH
