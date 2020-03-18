echo "installing xorg"
sudo pacman -S --noconfirm xorg xorg-xinit

echo "installing xmonad"
sudo pacman -S --noconfirm xmonad xmonad-contrib xterm

echo "#!/bin/bash" > ~/.xinitrc
echo "exec xmonad" >> ~/.xinitr

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

# setup termite
echo "installing termite terminal emulator"
sudo pacman -S --noconfirm termite

mkdir -p ~/git
cd ~/git

git clone https://github.com/khamer/base16-termite.git

cp ~/git/base16-termite/themes/base16-monokai.config ~/.config/termite/config

cat << EOF >> ~/.config/termite/config
[options]
font = Monospace 13
scrollback_lines = 100000
EOF
