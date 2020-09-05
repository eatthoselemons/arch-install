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


echo "If you would like to use eatthoselemons linux config run eatthoselemonsLinuxConfig.sh"
echo "To start a display manager run 'startx {display manager}'"
echo "so you could run 'startx xmonad' to start the xmonad display manager"
