# error out if there is an error in the script
trap_msg='s=${?}; echo "${0}: Error on line "${LINENO}": ${BASH_COMMAND}"; exit ${s}'
set -uo pipefail
trap "${trap_msg}" ERR


# install graphics system
echo "installing xorg"
sudo pacman -S --noconfirm xorg xorg-xinit

# install display manager
echo "installing xmonad"
sudo pacman -S --noconfirm xmonad xmonad-contrib xterm

# install git
echo "installing git"
sudo pacman -S --noconfirm git

# allow 'startx' to start the xmonad display manager
echo "#!/bin/bash" > ~/.xinitrc
echo "exec xmonad" >> ~/.xinitr

# disable mouse acceleration
echo "disabling mouse acceleration"
sudo bash -c "cat << EOF > /etc/X11/xorg.conf.d/no-mouse-acceleration.conf
Section "InputClass"
  Identifier "MyMouse"
  MatchIsPointer "yes"
  # set the following to 1 1 0 respectively to disable acceleration
  Option "AccelerationNumerator" "1"
  Option "AccelerationDenominator" "1"
  Option "AccelerationThreshold" "0"
EndSection
EOF"

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
  rmdir ~/git/base16-termite
fi
git clone https://github.com/khamer/base16-termite.git

# move monokai termite theme to the termite config dir
echo "creating termite config dir and moving monokai into that dir"
mkdir -p ~/.config/termite/config
cp ~/git/base16-termite/themes/base16-monokai.config ~/.config/termite/config

# increase default termite size from 9 (default) to 13
echo "increasing default terminal font size"
cat << EOF >> ~/.config/termite/config
[options]
font = Monospace 13
scrollback_lines = 100000
EOF
