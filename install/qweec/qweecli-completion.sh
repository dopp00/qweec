#!/usr/bin/bash

_qweecli_completion() {
    local cur="${COMP_WORDS[COMP_CWORD]}";
    local prev="${COMP_WORDS[COMP_CWORD-1]}"

    local autoarg=1;
    case "$prev" in
        --bg | --t?* | --help)
            autoarg=2;;
    esac

    # only complete the 1st argument (or 2nd, if prev aux arg provided as 1st)
    if [ $COMP_CWORD -ne $autoarg ]; then return; fi

    COMPREPLY=( $(compgen -W "$(qweecli --comp-list)" -- "$cur") )
}

complete -F _qweecli_completion qweecli
