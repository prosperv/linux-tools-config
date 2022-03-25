
# Save current path to variable
function sp() {
    eval $1=$(pwd)
}

function cdd() {
    newpath='$d'$1
    eval cd $newpath
}

d() {
    if [[ $1 = -[0-9] ]]; then
        echo "pushd +${1##*-}"
        pushd +"${1##*-}" >/dev/null
    else
       pushd +"$(($(dirs -p | sed -n '1d;s,.*/,,;/^'"$1"'/{=;q;}')-1))" >/dev/null
    fi
}

# Remove duplicate directories in dirs -v
dclean(){
    declare -a new=() copy=("${DIRSTACK[@]:1}")
    declare -A seen
    local v i
    seen[$PWD]=1
    for v in "${copy[@]}"
    do if [ -z "${seen[$v]}" ]
       then new+=("$v")
            seen[$v]=1
       fi
    done
    dirs -c
    for ((i=${#new[@]}-1; i>=0; i--))
    do      builtin pushd -n "${new[i]}" >/dev/null
    done
}

EDITOR="vim"
function cd() {
  if [ "$#" = "0" ]
  then
    pushd ${HOME} > /dev/null
  elif [ -f "${1}" ]
  then
    ${EDITOR} ${1}
  else
    pushd "$1" > /dev/null
  fi
}
alias dl="dclean; dirs -v"


# stop flow control in Tmux e.g. freeze with <C-s> and resume with <C-q>
stty -ixon
stty stop undef


## Share bash history across terminal
# Avoid duplicates
HISTCONTROL=ignoredups:erasedups
# When shell exits, append to history file
shopt -s histappend

#After each command, append to the history file and reread it
#PROMPT_COMMAND="${PROMPT_COMMAND:+$PROMPT_COMMAND$'\n'}history -a; history -c; history -r"
