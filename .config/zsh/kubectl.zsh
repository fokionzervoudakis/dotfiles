# Kubernetes aliases
#
# Single quotes, so the pod picker runs when you type the alias,
# not once when the shell starts.

# stop reading this file on machines without kubectl
[[ -x $commands[kubectl] ]] || return

# kubens and kubectx open fzf themselves when run without arguments
alias ns=kubens
alias ctx=kubectx

# pick names from `kubectl get <resource>`; extra args (e.g. --multi) go to fzf
__kpick() {
    local res=$1
    shift
    kubectl get "$res" |
        fzf --header-lines=1 --bind "ctrl-r:reload(kubectl get $res)" "$@" |
        awk '{print $1}'
}

alias ctlpods='kubectl exec -it $(__kpick pods) -- /bin/sh'
alias ctljobs='kubectl exec -it job/$(__kpick jobs) -- /bin/sh'
alias ctllogs='kubectl logs $(__kpick pods)'
alias ctlevents='kubectl get events --field-selector involvedObject.name=$(__kpick pods)'
alias ctldelpods='kubectl delete pod $(__kpick pods --multi)'
alias ctldeljobs='kubectl delete job $(__kpick jobs --multi)'

# a function so a cancelled picker does nothing: with no pod name,
# `kubectl describe pod` describes every pod in the namespace
ctldescribe() {
    local pods=$(__kpick pods --multi)
    [[ -n $pods ]] && kubectl describe pod ${(f)pods}
}

# a function rather than an alias so the jq program can be single-quoted
ctlsecrets() {
    kubectl get secret "$(__kpick secrets)" -o json |
        jq -r '.data | to_entries[] | "\(.key): \(.value | @base64d)"'
}
