echo "installing xorg"
sudo pacman -S --noconfirm xorg xorg-xinit

echo "installing xmonad"
sudo pacman -S --noconfirm xmonad xmonad-contrib xterm

mkdir ~/git
cd ~/git
git clone https://github.com/Match-Yang/sddm-deepin.git

cd sddm-deepin

bash install.sh




