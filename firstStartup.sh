sudo systemctl enable dhcpcd.service
sudo systemctl start dhcpcd.service

echo "installing xorg"
sudo pacman -S --noconfirm xorg xorg-xinit

echo "installing kde plasma"
sudo pacman -S --noconfirm plasma-desktop sddm git qt

mkdir ~/git
cd ~/git
git clone https://github.com/Match-Yang/sddm-deepin.git

cd sddm-deepin

bash install.sh




