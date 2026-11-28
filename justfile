# Homebrew-driven setup for these dotfiles. See README.md for the bootstrap order.
#
# Recipes are quiet by default; run `just -v <recipe>` to echo commands.
set quiet

BOLD := `printf "\033[1m"`
RED := `printf "\033[31m"`
RESET := `printf "\033[0m"`

# List available recipes
default:
    just --list

# Install stow and link the dotfiles into $HOME
[group('setup')]
stow:
    brew install stow
    stow -R --no-folding --target ~ . # link file by file, so files that programs create in $HOME stay out of the repo

# Install the zsh prompt and plugins, and the tools .zshrc aliases
[group('setup')]
shell:
    brew install starship zoxide zsh-autosuggestions zsh-syntax-highlighting
    brew install fzf # sourced by .zshrc; also used by the tmux pickers and the zsh functions
    brew install fzf-tab # sourced by .zshrc; Tab completion through fzf
    brew install bat # aliased to cat; configured by .config/bat/config
    brew install eza # aliased to ls, ll, and llt
    brew install cloc # wrapped by the cloc function

# Install Ghostty, the Nerd Font, and tmux
[group('setup')]
terminal:
    brew install --cask ghostty # configured by .config/ghostty/config
    brew install --cask font-hack-nerd-font # set in .config/ghostty/config; draws the icons in Neovim and eza
    brew install tmux

# Install Claude Code
[group('setup')]
claude: jq
    curl -fsSL https://claude.ai/install.sh | bash # installs to ~/.local/bin, which .zprofile puts on PATH

# Install jq
[group('setup')]
jq:
    brew install jq # runs .claude/statusline.jq; also used by conform.lua

# Install Git tools and enable the repo's Git hooks
[group('setup')]
git: githooks jq shell terminal nvim # the pre-push hook runs lint and test, which need the last four
    brew install gh # GitHub's command-line tool
    brew install betterleaks # run by hooks/pre-push and .config/git/hooks/pre-push
    brew install shellcheck # run by `just lint`
    brew install bats-core # runs `just test` and `just health`
    brew install lazygit # opened by prefix g g and prefix g l in .tmux.conf
    brew install git-delta # diff renderer for .config/lazygit
    [ -x ~/.local/share/nvim/mason/bin/stylua ] || nvim --headless -c 'MasonInstall stylua' -c qa # install stylua for `just lint`; otherwise it is missing until Neovim is first opened

# Install Git hooks
[group('setup')]
githooks:
    git config core.hooksPath hooks # run hooks/pre-push before every push

# Install Neovim and its external dependencies
[group('setup')]
nvim: go jq
    brew install neovim
    brew install tree-sitter-cli # builds the parsers nvim-treesitter installs
    brew install ripgrep # Telescope file search and live grep
    brew install node # Mason installs prettier, sql-formatter and two language servers with npm
    brew install openjdk # runs jdtls, which Mason installs

# Install Go
[group('setup')]
go:
    brew install go # Mason builds gopls and goimports with it

# Test the tmux config and scripts, the zsh functions, and the Claude status line
[group('dev')]
test:
    @echo "{{RED}}{{BOLD}}Running tests...{{RESET}}"
    @bats test

# Check this machine: zsh and Neovim start cleanly, the tools the configs run are installed, and stow can link
[group('dev')]
health:
    @echo "{{RED}}{{BOLD}}Checking this machine...{{RESET}}"
    @bats health

# Upgrade the Homebrew packages, the Neovim plugins, and the Mason tools, then check this machine
[group('dev')]
update:
    @echo "{{RED}}{{BOLD}}Updating packages, plugins and tools...{{RESET}}"
    brew upgrade --yes # no confirmation prompt
    nvim --headless -c PackUpdate -c qa
    @echo # nvim's output ends without a newline
    nvim --headless -c MasonToolsUpdateSync -c qa
    @echo
    just health

# Check the shell scripts for common mistakes, the zsh files for syntax errors, and the Lua for formatting
[group('dev')]
lint:
    @echo "{{RED}}{{BOLD}}Linting shell scripts and Lua...{{RESET}}"
    @git ls-files '*.sh' '*.bash' '*.bats' '*hooks/*' | xargs shellcheck # every tracked shell script
    @printf '%s\n' .zshrc .zprofile .config/tmux/* | xargs -n1 zsh -n
    @~/.local/share/nvim/mason/bin/stylua --check .config/nvim # Mason's copy; stylua is not on PATH
    @~/.local/share/nvim/mason/bin/stylua --check --config-path .config/nvim/stylua.toml scripts
