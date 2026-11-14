load ../test/helpers

# Start an interactive login zsh, as the terminal does, so .zprofile runs too; the zle warning appears only because no terminal is attached
zsh_startup() {
    zsh -il -c exit 2>&1 | grep -v "can't change option: zle"
}

@test "zsh starts without printing anything" {
    quiet zsh_startup
}

@test "nvim starts without printing anything" {
    quiet nvim --headless +qa
}

@test "nvim can run every formatter and language server it uses" {
    quiet nvim --headless -c 'luafile scripts/nvim-tools.lua' +qa
}

# Fails when a file in the repo would collide with a real file already in $HOME
@test "stow can link every file into the home directory" {
    stow -n -R --no-folding --target ~ .
}
