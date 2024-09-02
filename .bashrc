# ~/.bashrc

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# == Determine OS ==

platform="unknown"
unamestr=$(uname)
if [ "$unamestr" = "Linux" ]; then
   platform="linux"
elif [ "$unamestr" = "NetBSD" ]; then
   platform="netbsd"
fi

# == Prompt ==

# Colour codes
RED="\\[\\e[1;31m\\]"
GREEN="\\[\\e[1;32m\\]"
YELLOW="\\[\\e[1;33m\\]"
BLUE="\\[\\e[1;34m\\]"
MAGENTA="\\[\\e[1;35m\\]"
CYAN="\\[\\e[1;36m\\]"
WHITE="\\[\\e[1;37m\\]"
ENDC="\\[\\e[0m\\]"

# Set a two-line prompt
[[ -n "$SSH_CLIENT" ]] && ssh_message="-ssh_session"
PS1="${MAGENTA}\t ${GREEN}\u ${WHITE}at ${YELLOW}\h${RED}${ssh_message} ${WHITE}in ${BLUE}\w \n${CYAN}\$${ENDC} "

# == Functions ==

# backup and timestamp files
bak() { for f in "$@" ; do cp -- "$f" "$f.$(date +%FT%H%M%S).bak" ; done ; }

# change directories and list contents; setting LC_ALL to C makes the ls command
# sort dotfiles first, followed by uppercase and lowercase filename
if [ "$platform" = "linux" ]; then
  c() { cd -- "$@" && LC_ALL=C ls -alhF --color=always ; }
elif [ "$platform" = "netbsd" ]; then
  c() { cd -- "$@" && colorls -alFG ; }
fi

# top 10 most used commands
cmd10() { history | awk '{print $3}' | sort | uniq -c | sort -rn | head ; }

# make directory and change to it immediately
md() { mkdir -p -- "$@" && cd -- "$@" || return ; }

# replace spaces and non-ascii characters in a filename with underscore
mtg() { for f in "$@" ; do mv -- "$f" "${f//[^a-zA-Z0-9\.\-]/_}" ; done ; }

# process grep
psg() { ps aux | head -n 1; ps auxww | grep --color=auto $1 ; }

# == Aliases ==

alias dff="df -hT"
alias dpkgg="dpkg -l | grep"
alias e="nvim"
alias gsave="git commit -m 'save'"
alias gs="git status"
if [ "$platform" = "linux" ]; then
  alias l="LC_ALL=C ls -alhF --color=always"
elif [ "$platform" = "netbsd" ]; then
  alias l="colorls -alFG"
fi
alias lo="locate -ir ~/"
alias mountt="mount | column -t"
alias p="less"
alias t="c ~/tmp"
alias tmuxd="tmux new -s default -A"
alias x="exit"
alias yta="yt-dlp --extract-audio --audio-format mp3 --audio-quality 0 --restrict-filenames"

# == History ==

# unlimited history
HISTSIZE=
HISTFILESIZE=

# change the history file location because certain bash sessions truncate 
# .bash_history upon close
HISTFILE=~/.bash_unlimited_history

# Default is to write history at the end of each session, overwriting the
# existing file with an updated version. If logged in with multiple sessions,
# only the last session to exit will have its history saved.
#
# Require prompt write to history after every command and append to the history
# file; don't overwrite it.
shopt -s histappend
PROMPT_COMMAND="history -a; $PROMPT_COMMAND"
# Now the commands from all shells in near real-time are recorded in HISTFILE.
# Starting a new shell displays the combined history from all terminals.

# don't put duplicate lines or lines starting with space in the history
HISTCONTROL=ignoreboth

# add a timestamp per entry; useful for context when viewing logfiles.
HISTTIMEFORMAT="%FT%T  "

# save all lines of a multiple-line command in the same history entry
shopt -s cmdhist

# re-edit a history substitution line if it failed
shopt -s histreedit

# edit a recalled history line before executing
shopt -s histverify

# toggle history off/on for a current shell
alias stophistory="set +o history"
alias starthistory="set -o history"

# == Misc ==

# greeting
[ -f ~/.fortunes ] && fortune ~/.fortunes

# default editor
export EDITOR="nvim"
export VISUAL=$EDITOR

# PROMPT_COMMAND sets the terminal title bar.
export PROMPT_COMMAND='printf "\033]0;%s at %s\007" "${USER}" "${HOSTNAME%%.*}"'

# when resizing a terminal emulator, check the window size after each command
# and, if necessary, update the values of LINES and COLUMNS
shopt -s checkwinsize

# use `keychain` for ssh-agent management
if [[ -x /usr/local/bin/keychain ]] || [[ -x /usr/bin/keychain ]]; then
  keychain ~/.ssh/${HOSTNAME}
  source ~/.keychain/${HOSTNAME}-sh
fi

# disable XON/XOFF flow control; enables use of C-S in other commands
# examples: forward search in history; disable screen freeze in vim
[[ $- == *i* ]] && stty -ixon


