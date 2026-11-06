# AWS aliases

# stop reading this file on machines without the aws CLI
[[ -x $commands[aws] ]] || return

alias awsme='aws sts get-caller-identity'
alias awsin='aws sso login'
alias awsout='aws sso logout'

# a function so Esc in fzf leaves AWS_PROFILE unchanged instead of emptying it
awsprofile() {
    local p
    p=$(aws configure list-profiles | fzf) && export AWS_PROFILE=$p
}
