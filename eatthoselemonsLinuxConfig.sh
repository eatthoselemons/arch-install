# error out if there is an error in the script
trap_msg='s=${?}; echo "${0}: Error on line "${LINENO}": ${BASH_COMMAND}"; exit ${s}'
set -uo pipefail
trap "${trap_msg}" ERR


# install my linux config
# dependencies
sudo pacman --noconfirm -S universal-ctags neovim

if [[ -d $HOME/git/linux-config ]];
then
	rm -rf "$HOME/git/linux-config"
fi

git clone https://github.com/eatthoselemons/linux-config ~/git/linux-config

mkdir -p ~/git
cd ~/git
git clone https://github.com/eatthosemeons/arch-install.git

nvim -s $HOME/git/arch-install/neovimCommands

echo "adding bashrc config"
cat << 'EOF' >> ~/.config/nvim/init.vim
set runtimepath^=~/.vim runtimepath+=~/.vim/after
let &packpath = &runtimepath
source $HOME/git/linux-config/vimrc
EOF


cat << 'EOF' >> ~/.bashrc

#
# ~/.bashrc
#

[[ $- != *i* ]] && return

colors() {
	local fgc bgc vals seq0

	printf "Color escapes are %s\n" '\e[${value};...;${value}m'
	printf "Values 30..37 are \e[33mforeground colors\e[m\n"
	printf "Values 40..47 are \e[43mbackground colors\e[m\n"
	printf "Value  1 gives a  \e[1mbold-faced look\e[m\n\n"

	# foreground colors
	for fgc in {30..37}; do
		# background colors
		for bgc in {40..47}; do
			fgc=${fgc#37} # white
			bgc=${bgc#40} # black

			vals="${fgc:+$fgc;}${bgc}"
			vals=${vals%%;}

			seq0="${vals:+\e[${vals}m}"
			printf "  %-9s" "${seq0:-(default)}"
			printf " ${seq0}TEXT\e[m"
			printf " \e[${vals:+${vals+$vals;}}1mBOLD\e[m"
		done
		echo; echo
	done
}

[ -r /usr/share/bash-completion/bash_completion ] && . /usr/share/bash-completion/bash_completion

# Change the window title of X terminals
case ${TERM} in
	xterm*|rxvt*|Eterm*|aterm|kterm|gnome*|interix|konsole*)
		PROMPT_COMMAND='echo -ne "\033]0;${USER}@${HOSTNAME%%.*}:${PWD/#$HOME/\~}\007"'
		;;
	screen*)
		PROMPT_COMMAND='echo -ne "\033_${USER}@${HOSTNAME%%.*}:${PWD/#$HOME/\~}\033\\"'
		;;
esac

use_color=true

# Set colorful PS1 only on colorful terminals.
# dircolors --print-database uses its own built-in database
# instead of using /etc/DIR_COLORS.  Try to use the external file
# first to take advantage of user additions.  Use internal bash
# globbing instead of external grep binary.
safe_term=${TERM//[^[:alnum:]]/?}   # sanitize TERM
match_lhs=""
[[ -f ~/.dir_colors   ]] && match_lhs="${match_lhs}$(<~/.dir_colors)"
[[ -f /etc/DIR_COLORS ]] && match_lhs="${match_lhs}$(</etc/DIR_COLORS)"
[[ -z ${match_lhs}    ]] \
	&& type -P dircolors >/dev/null \
	&& match_lhs=$(dircolors --print-database)
[[ $'\n'${match_lhs} == *$'\n'"TERM "${safe_term}* ]] && use_color=true

if ${use_color} ; then
	# Enable colors for ls, etc.  Prefer ~/.dir_colors #64489
	if type -P dircolors >/dev/null ; then
		if [[ -f ~/.dir_colors ]] ; then
			eval $(dircolors -b ~/.dir_colors)
		elif [[ -f /etc/DIR_COLORS ]] ; then
			eval $(dircolors -b /etc/DIR_COLORS)
		fi
	fi

	if [[ ${EUID} == 0 ]] ; then
		PS1='\[\033[01;31m\][\h\[\033[01;36m\] \W\[\033[01;31m\]]\$\[\033[00m\] '
	else
		PS1='\[\033[01;32m\][\u@\h\[\033[01;37m\] \W\[\033[01;32m\]]\$\[\033[00m\] '
	fi
  
  # enabling colors
	alias ls='ls --color=auto'
	alias grep='grep --colour=auto'
	alias egrep='egrep --colour=auto'
	alias fgrep='fgrep --colour=auto'
else
	if [[ ${EUID} == 0 ]] ; then
		# show root@ when we don't have colors
		PS1='\u@\h \W \$ '
	else
		PS1='\u@\h \w \$ '
	fi
fi

unset use_color safe_term match_lhs sh

alias cp="cp -i"                          # confirm before overwriting something
alias df='df -h'                          # human-readable sizes
alias free='free -m'                      # show sizes in MB
alias np='nano -w PKGBUILD'
alias more=less

xhost +local:root > /dev/null 2>&1

complete -cf sudo

# Bash won't get SIGWINCH if another process is in the foreground.
# Enable checkwinsize so that bash will check the terminal size when
# it regains control.  #65623
# http://cnswww.cns.cwru.edu/~chet/bash/FAQ (E11)
shopt -s checkwinsize

shopt -s expand_aliases

# export QT_SELECT=4

# Enable history appending instead of overwriting.  #139609
shopt -s histappend

#
# # ex - archive extractor
# # usage: ex <file>
ex ()
{
  if [ -f $1 ] ; then
    case $1 in
      *.tar.bz2)   tar xjf $1   ;;
      *.tar.gz)    tar xzf $1   ;;
      *.bz2)       bunzip2 $1   ;;
      *.rar)       unrar x $1     ;;
      *.gz)        gunzip $1    ;;
      *.tar)       tar xf $1    ;;
      *.tbz2)      tar xjf $1   ;;
      *.tgz)       tar xzf $1   ;;
      *.zip)       unzip $1     ;;
      *.Z)         uncompress $1;;
      *.7z)        7z x $1      ;;
      *)           echo "'$1' cannot be extracted via ex()" ;;
    esac
  else
    echo "'$1' is not a valid file"
  fi
}
if [ -f $HOME/git/linux-config/extra-bash ]; then
	. $HOME/git/linux-config/extra-bash
fi

source /usr/share/nvim/init-nvim.sh

#forground terminal colors
black=$(tput setaf 0) # \e[30m
red=$(tput setaf 1) # \e[31m
green=$(tput setaf 2) # \e[32m
yellow=$(tput setaf 3) # \e[33m
blue=$(tput setaf 4) # \e[34m
purple=$(tput setaf 5) # \e[35m
cyan=$(tput setaf 6) # \e[36m
grey=$(tput setaf 7) # \e[37m
defaultColor=$(tput setaf 9) # \e[39m

#background terminal colors
backgroundBlack=$(tput setaf 0) # \e[40m
backgroundRed=$(tput setaf 1) # \e[41m
backgroundGreen=$(tput setaf 2) # \e[42m
backgroundYellow=$(tput setaf 3) # \e[43m
backgroundBlue=$(tput setaf 4) # \e[44m
backgroundPurple=$(tput setaf 5) # \e[45m
backgroundCyan=$(tput setaf 6) # \e[46m
backgroundGrey=$(tput setaf 7) # \e[47m
backgroundDefaultColor=$(tput setaf 9) # \e[49m

# general terminal text attributes
# if desired with a color attribute then format like:
# \[$bright;$cyan\]
# with the semicolon (;)
reset=$(tput sgr0)   # \e[0m;
bright=$(tput bold) # \e[1m;
dim=$(tput dim) # \e[2m;
italics=$(tput smso) # \e[3m;
underscore=$(tput smul) # \e[4m;
blink=$(tput blink) # \e[5m;

function defaultPrompt () {
export PS1="\
${purple}\A${reset}\
${grey} [${reset}\
${blue}\u${reset}\
${grey}@${reset}\
${orange}\h${reset}\
${blue} \w${reset}\
${grey}]${reset}\
${green} λ ${reset}"
}
function simplePrompt () {
export PS1="\
${grey}[${reset}\
${blue}\W${reset}\
${grey}]${reset}\
${green} λ ${reset}"
}


splitPrompt
# set gpg-agent as default
unset SSH_AGENT_PID
if [ "${gnupg_SSH_AUTH_SOCK_by:-0}" -ne $$ ]; then
  export SSH_AUTH_SOCK="$(gpgconf --list-dirs agent-ssh-socket)"
fi
export GPG_TTY=$(tty)
gpg-connect-agent updatestartuptty /bye >/dev/null
EOF
source ~/.bashrc
