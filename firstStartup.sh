# error out if there is an error in the script
trap_msg='s=${?}; echo "${0}: Error on line "${LINENO}": ${BASH_COMMAND}"; exit ${s}'
set -uo pipefail
trap "${trap_msg}" ERR

# install required utilities
echo "installing prerequisite utilities"
sudo pacman -S --noconfirm git vim

# install graphics system
echo "installing xorg"
sudo pacman -S --noconfirm xorg xorg-xinit dmenu

# install display manager
echo "installing xmonad"
sudo pacman -S --noconfirm xmonad xmonad-contrib xterm

# install other display manager
echo "installing deepin"
sudo pacman -S --noconfirm deepin

# install deepin login page
if [[ -d $HOME/git/sddm-deepin ]];
then
	rm -rf "$HOME/git/sddm-deepin"
fi
git clone https://github.com/Match-Yang/sddm-deepin.git ~/git/sddm-deepin
cd ~/git/sddm-deepin
bash install.sh

# install other useful programs
echo "installing other programs, git, firefox etc"
sudo pacman -S --noconfirm git firefox udisks2 ripgrep pavucontrol gnupg usbutils

# allow 'startx' to start the xmonad display manager
cat << EOF > ~/.xinitrc
case "\$2" in
  xmonad)
    exec xmonad
    ;;
  deepin)
    exec startdde
    ;;
  *)
    echo "failure"
    ;;
esac
EOF


# disable mouse acceleration
echo "disabling mouse acceleration"
sudo bash -c 'cat << EOF > /etc/X11/xorg.conf.d/no-mouse-acceleration.conf
Section "InputClass"
  Identifier "MyMouse"
  MatchIsPointer "yes"
  # set the following to 1 1 0 respectively to disable acceleration
  Option "AccelerationNumerator" "1"
  Option "AccelerationDenominator" "1"
  Option "AccelerationThreshold" "0"
EndSection
EOF'

# install termite
echo "installing termite terminal emulator"
sudo pacman -S --noconfirm termite


# get termite color schemes
echo "cloning termite color schemes"
echo "making git directory"
mkdir -p ~/git
cd ~/git
if [[ -d ~/git/base16-termite ]]
then
  echo "removing existing termite color scheme directories"
  rm -rf ~/git/base16-termite
fi
git clone https://github.com/khamer/base16-termite.git

# move monokai termite theme to the termite config dir
echo "creating termite config dir and moving monokai into that dir"
mkdir -p ~/.config/termite
cp ~/git/base16-termite/themes/base16-monokai.config ~/.config/termite/config

# other gree color options:
# b1be2c, a8b14c, b7c42d
# increase default termite size from 9 (default) to 13
echo "increasing default terminal font size"
cat << EOF >> ~/.config/termite/config
[options]
font = Monospace 13
scrollback_lines = 100000
EOF

# replacing the comments with my green color
sed -ri 's:color6\s*=\s*#[a-z0-9]{6}:color6  = #afbc2b:g' ~/.config/termite/config
sed -ri 's:color14\s*=\s*#[a-z0-9]{6}:color14 = #afbc2b:g' ~/.config/termite/config
sed -ri 's:(cursor\s*)=\s*#[a-z0-9]{6}:\1= #939390:g' ~/.config/termite/config
sed -ri 's:(color7\s*)=\s*#[a-z0-9]{6}:\1= #a8a9a6:g' ~/.config/termite/config

#enabling ls colors
echo "alias ls='ls --color=auto'" | sudo tee -a /etc/bash.bashrc

# add other prompt options
cat << EOF >> ~/.bashrc
#forground terminal colors
black=$(tput setaf 0) # \e[30m
red=$(tput setaf 1) # \e[31m
green=$(tput setaf 2) # \e[32m
yellow=$(tput setaf 3) # \e[33m
blue=$(tput setaf 4) # \e[34m
magenta=$(tput setaf 5) # \e[35m
cyan=$(tput setaf 6) # \e[36m
white=$(tput setaf 7) # \e[37m
defaultColor=$(tput setaf 9) # \e[39m

#background terminal colors
backgroundBlack=$(tput setaf 0) # \e[40m
backgroundRed=$(tput setaf 1) # \e[41m
backgroundGreen=$(tput setaf 2) # \e[42m
backgroundYellow=$(tput setaf 3) # \e[43m
backgroundBlue=$(tput setaf 4) # \e[44m
backgroundMagenta=$(tput setaf 5) # \e[45m
backgroundCyan=$(tput setaf 6) # \e[46m
backgroundWhite=$(tput setaf 7) # \e[47m
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
export PS1="\[$magenta\]\A\[$reset\] \[$white\][\[$reset\]\[$cyan\]\u\[$reset\]\[$white\]@\[$reset\]\[$yellow\]\h\[$reset\] \[$blue\]\w\[$reset\]\[$white\]]\[$reset\] \[$green\]λ\[$reset\] "
}
function simplePrompt () {
  export PS1="[\[$blue\]\W\[$reset\]] \[$green\]λ \[$reset\]"
}

defaultPrompt
EOF

echo "creating file for new ssh connections to fix termite issue"
cat << EOF >> ~/newSSHConnection.sh
infocmp > termite.terminfo
scp termite.terminfo \$1:
ssh \$1 'tic -x termite.terminfo'
EOF

# adding gnupg for gpg-agent to manage ssh keys
cat << 'EOF' >> $HOME/.bashrc
# set gpg-agent as default
unset SSH_AGENT_PID
if [ "${gnupg_SSH_AUTH_SOCK_by:-0}" -ne $$ ]; then
  export SSH_AUTH_SOCK="$(gpgconf --list-dirs agent-ssh-socket)"
fi
export GPG_TTY=$(tty)
gpg-connect-agent updatestartuptty /bye >/dev/null
EOF

# set program for ssh key passphrase entering
# also set the pinentry program to start in the active terminal not the first terminal
mkdir -p $HOME/.gnupg
echo "pinentry-program /usr/bin/pinentry-curses" > $HOME/.gnupg/gpg-agent.conf
echo 'Match host * exec "gpg-connect-agent UPDATESTARTUPTTY /bye"' >> ~/.ssh/config

echo "If you would like to use eatthoselemons linux config run eatthoselemonsLinuxConfig.sh"
echo "To start a display manager run 'startx {display manager}'"
echo "so you could run 'startx xmonad' to start the xmonad display manager"
echo "if you need to enable termite on a remote server run: bash ~/newSSHConnection.sh <ip address>"
