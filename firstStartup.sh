# install graphics system
echo "installing xorg"
sudo pacman -S --noconfirm xorg xorg-xinit

# install display manager
echo "installing xmonad"
sudo pacman -S --noconfirm xmonad xmonad-contrib xterm

# allow 'startx' to start the xmonad display manager
echo "#!/bin/bash" > ~/.xinitrc
echo "exec xmonad" >> ~/.xinitr

# disable mouse acceleration
cat << EOF > /etc/X11/xorg.conf.d/no-mouse-acceleration.conf
Section "InputClass"
  Identifier "MyMouse"
  MatchIsPointer "yes"
  # set the following to 1 1 0 respectively to disable acceleration
  Option "AccelerationNumerator" "1"
  Option "AccelerationDenominator" "1"
  Option "AccelerationThreshold" "0"
EndSection
EOF

# install termite
echo "installing termite terminal emulator"
sudo pacman -S --noconfirm termite

mkdir -p ~/git
cd ~/git

# get termite color schemes
git clone https://github.com/khamer/base16-termite.git

# move monokai termite theme to the termite config dir
cp ~/git/base16-termite/themes/base16-monokai.config ~/.config/termite/config

# increase default termite size from 9 (default) to 13
cat << EOF >> ~/.config/termite/config
[options]
font = Monospace 13
scrollback_lines = 100000
EOF
