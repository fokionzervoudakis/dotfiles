# README

This is the repository for my dotfiles. To install on macOS:

## Configure GitHub

[Connecting to GitHub with SSH](https://docs.github.com/en/authentication/connecting-to-github-with-ssh)

## Install dotfiles

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
brew install git just
git clone git@github.com:zerdaks/dotfiles.git
cd dotfiles/
just stow
just git
exec zsh
just --list # then run the recipes you need
```

Rerun `just stow` after adding a new file to the repo. Stow links files
individually, so a file it has never linked does not exist as far as anything
reading `~/.config` is concerned.

## Check the configs

```bash
just test lint
just health # checks this machine: zsh and Neovim start cleanly, stow can link
```

## Configure Neovim

```bash
vim
:LspCopilotSignIn
```

## Update

```bash
just update # upgrades the Homebrew packages, the Neovim plugins and the Mason tools, then runs just health
```

Plugin updates are applied without a review buffer; run `:lua vim.pack.update()`
in Neovim to review them first.

## Configure tmux

> System Settings &rarr; Keyboard &rarr; Keyboard Shortcuts... &rarr; Input Sources &rarr; Select the previous input source (uncheck)

[https://stackoverflow.com/a/71337138](https://stackoverflow.com/a/71337138)
