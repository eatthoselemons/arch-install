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
