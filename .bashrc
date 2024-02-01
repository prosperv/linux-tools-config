# Default from Ubuntu 20
# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
# Default 1000
HISTSIZE=2000
# Default 2000
HISTFILESIZE=4000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
        # We have color support; assume it's compliant with Ecma-48
        # (ISO/IEC-6429). (Lack of such support is extremely rare, and such
        # a case would tend to support setf rather than setaf.)
        color_prompt=yes
    else
        color_prompt=
    fi
fi

if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# colored GCC warnings and errors
#export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

# Screw it, we don't need a seperate file just add it in here.
# if [ -f ~/.bash_aliases ]; then
#     . ~/.bash_aliases
# fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

##
# End of Ubuntu 20 stuff

if [ -d ~/.project ]; then
    . ~/.project/.elroy.bashrc
fi

# Set our default editor to be vim other it will be nano
EDITOR="vim"

# Save current path to variable
function sp() {
    eval $1=$(pwd)
}

# Forgot what I was trying to do here....
# Change to last previous path?? Like `cd -`.
# Maybe this is pointless. To be deleted later
function cdd() {
    newpath='$d'$1
    eval cd $newpath
}

# Jump to directory base on index from `dl`
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
# View list of directories
alias dl="dclean; dirs -v"


# stop flow control in Tmux e.g. freeze with <C-s> and resume with <C-q>
stty -ixon
stty stop undef


###
# Share bash history across terminal
# Avoid duplicates
HISTCONTROL=ignoredups:erasedups
# When shell exits, append to history file
shopt -s histappend
#After each command, append to the history file and reread it
#PROMPT_COMMAND="${PROMPT_COMMAND:+$PROMPT_COMMAND$'\n'}history -a; history -c; history -r"
# Save history instead of waiting for shell to exit
alias savehist='history -a'



###
# ssh agent stuff

function run_ssh-agent() {
    echo "Running ssh-agent from .bashrc"
    eval "$(ssh-agent)"
    ln -sf "$SSH_AUTH_SOCK" "${HOME}/.ssh/ssh_auth_sock_${HOSTNAME}"
}

# start the ssh-agent && and prompt for ssh passphrase only after first login
ssh_start_agent() {
    if [ ! -S "${HOME}/.ssh/ssh_auth_sock_${HOSTNAME}" ]; then
        echo "Symlink not found"
        run_ssh-agent
    else
        # Get ssh-agent PID from symlink
        SSH_LINK=`readlink ${HOME}/.ssh/ssh_auth_sock_${HOSTNAME}`
        # Add one cus it's weird
        LINK_PID=$(( ${SSH_LINK##*.} + 1 ))

        # Get ssh-agent PID from ps
        SSH_PS=`ps -x | grep ssh-agent | grep $LINK_PID`
        PID_ARRAY=($SSH_PS)
        PS_PID=${PID_ARRAY[0]}

        if [[ $PS_PID -ne $LINK_PID ]]; then
            echo "ssh-agent not running"
            run_ssh-agent
        else
            echo "ssh-agent found!"
        fi
    fi
    export SSH_AUTH_SOCK="${HOME}/.ssh/ssh_auth_sock_${HOSTNAME}"
    ssh-add -l > /dev/null || ssh-add
}
ssh_start_agent


# Keep vscode socket update
save_vscode_socket() {
    # Check if we are in a shell in tmux
    if [[ -z "$TMUX" ]] && ! [[ -z "$VSCODE_IPC_HOOK_CLI" ]]; then
        echo "$VSCODE_IPC_HOOK_CLI"
        echo "$VSCODE_IPC_HOOK_CLI" > ~/.vscode-socket-path
    fi
}
save_vscode_socket

load_vscode_socket() {
    if ! [[ -z "$TMUX" ]] && ! [[ -z "$VSCODE_IPC_HOOK_CLI" ]]; then
        echo "VSCODE_IPC_HOOK_CLI=$(cat ~/.vscode-socket-path)"
        VSCODE_IPC_HOOK_CLI=$(cat ~/.vscode-socket-path)
    fi
}

alias code='load_vscode_socket; code'