# error out if there is an error in the script
trap_msg='s=${?}; echo "${0}: Error on line "${LINENO}": ${BASH_COMMAND}"; exit ${s}'
set -uo pipefail
trap "${trap_msg}" ERR


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
sudo pacman -S --noconfirm git firefox udisks2 ripgrep pavucontrol

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

echo "creating file for new ssh connections to fix termite issue"
cat << EOF >> ~/newSSHConnection.sh
infocmp > termite.terminfo
scp termite.terminfo \$1:
ssh \$1 'tic -x termite.terminfo'
EOF

echo "If you would like to use eatthoselemons linux config run eatthoselemonsLinuxConfig.sh"
echo "To start a display manager run 'startx {display manager}'"
echo "so you could run 'startx xmonad' to start the xmonad display manager"
echo "if you need to enable termite on a remote server run: bash ~/newSSHConnection.sh <ip address>"
