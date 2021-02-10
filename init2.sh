# error out if there is an error in the script
trap_msg='s=${?}; echo "${0}: Error on line "${LINENO}": ${BASH_COMMAND}"; exit ${s}'
set -uo pipefail
trap "${trap_msg}" ERR

printf "\n===========================================\n"
echo "you need region and city the regions and city can be found at: /usr/share/zoneinfo/region/city"

# grab zone info for clock
ls /usr/share/zoneinfo
echo "regions ^^"
echo "What Region are you in?"
read region
correctedRegion=$(echo "$region" | awk '{ print toupper(substr($0,1,1)) tolower(substr($0,2)); }')
printf "\n===========================================\n"
ls /usr/share/zoneinfo/$correctedRegion
echo "cities ^^"
echo "What city are you in?"
read city
correctedCity=$(echo "$city" | awk '{ print toupper(substr($0,1,1)) tolower(substr($0,2)); }')

# set clock zone
ln -sf /usr/share/zoneinfo/$correctedRegion/$correctedCity /etc/localtime
hwclock --systohc

printf "\n===========================================\n"
echo "What is the system hostname?"
read hostname

printf "\n===========================================\n"
echo "what processor do you have AMD or Intel?"
read cpu

# read what the selected drive was to install to
# stored file
file="/root/rootPartition"
rootPartition=$(cat "$file")

# processor 0=unknown 1=intel 2=amd
# case insensitive regex selection
processor=0
if [[ "$cpu" =~ ^[Aa][Mm][Dd]$ ]]
then
  processor=2
fi

if [[ "$cpu" =~ ^[Ii][Nn][Tt][Ee][Ll]$ ]]
then
  processor=1
fi

if [[ $processor == 0 ]]
then
  echo "retype processor or unsupported processor"
  exit 1
else
  echo "you have cpu $cpu"
fi


printf "\n===========================================\n"
echo "what graphics do you have AMD, nVidia, or Intel?"
read gpu

# graphics 0=unknown 1=intel 2=amd 3=nvidia
# case insensitive regex selection
graphics=0

if [[ "$gpu" =~ ^[Ii][Nn][Tt][Ee][Ll]$ ]]
then
  graphics=1
fi

if [[ "$gpu" =~ ^[Aa][Mm][Dd]$ ]]
then
  graphics=2
fi

if [[ "$gpu" =~ ^[Nn][Vv][Ii][Dd][Ii][Aa]$ ]]
then
  graphics=3
fi

if [[ $graphics == 0 ]]
then
  echo "retype gpu or unsupported gpu"
  exit 1
else
  echo "you have gpu $gpu"
fi
printf "\n===========================================\n"
echo "set root password"
until passwd
do
  echo "non matching try again"
  sleep 1
done

echo "what is the user account name?"
read regularUsername
if ! id "$regularUsername"
then
  useradd -m $regularUsername
else
  echo "user already exists, not creating a new user"
fi

# check if already in the sudoers file if not then add
if ( ! grep -Fxq "$regularUsername ALL=(ALL) ALL" /etc/sudoers )
then
  echo "adding $regularUsername to sudoers"
  echo "$regularUsername ALL=(ALL) ALL" >> /etc/sudoers
else
  echo "$regularUsername already in sudoers"
fi

until passwd $regularUsername
do
  echo "non matching try again"
  sleep 1
done
# make sure system has wget
pacman -S --noconfirm wget reflector

cd /home/$regularUsername/

echo "downloading next step, firstStartup.sh"
wget https://raw.githubusercontent.com/eatthoselemons/arch-install/master/firstStartup.sh
chown $regularUsername:$regularUsername /home/$regularUsername/firstStartup.sh
wget https://raw.githubusercontent.com/eatthoselemons/arch-install/master/eatthoselemonsLinuxConfig.sh
chown $regularUsername:$regularUsername /home/$regularUsername/eatthoselemonsLinuxConfig.sh


if [[ ! -f /etc/locale.conf ]]
then
  touch /etc/locale.conf
fi
echo "en_US.UTF-8 UTF-8" > /etc/locale.gen
locale-gen


touch /etc/hostname
echo $hostname > /etc/hostname

echo "127.0.0.1 localhost" > /etc/hosts
echo "::1 localhost" >> /etc/hosts
echo "127.0.1.1 $hostname.localdomain $hostname" >> /etc/hosts

if [[ ! -d /efi/loader/entries ]]
then
  mkdir -p /efi/loader/entries
fi

if [[ ! -d /efi/loader/kernels ]]
then
  mkdir -p /efi/EFI/kernels
fi

# systemd boot loader config
cat << EOF > /efi/loader/loader.conf
default arch
timeout 4
console-mode max
editor no
EOF

cat << EOF > /efi/loader/entries/arch.conf
title Arch Linux
linux EFI/kernels/vmlinuz-linux
initrd EFI/kernels/initramfs-linux.img
options root=/dev/$rootPartition rw
EOF

# grab top 100 mirrors and sort by how fast they are
reflector --verbose --latest 100 --sort rate --save /etc/pacman.d/mirrorlist

# manually copy the boot files from the non-UEFI location /boot
# to the UEFI location /efi/EFI/kernels
# need to copy first then bind mount for further instances
cp -a /boot/vmlinuz-linux /efi/EFI/kernels
cp -a /boot/initramfs-linux.img /efi/EFI/kernels
cp -a /boot/initramfs-linux-fallback.img /efi/EFI/kernels

# grab ucode based on processor type
if [[ $processor == 1 ]]
then
  pacman -S --noconfirm intel-ucode
  bootctl --path=/efi install
  echo "initrd  EFI/kernels/intel-ucode.img" >> /efi/loader/entries/arch.conf
  cp -a /boot/intel-ucode.img /efi/EFI/kernels
fi

if [[ $processor == 2 ]]
then
  pacman -S --noconfirm amd-ucode
  bootctl --path=/efi install
  echo "initrd  EFI/kernels/amd-ucode.img" >> /efi/loader/entries/arch.conf
  cp -a /boot/amd-ucode.img /efi/EFI/kernels
fi

# bind /boot/* to /efi/EFI/kernels/
# /efi/EFI/kernels is where the systemd boot loader
# is looking for the boot files
mount --bind /efi/EFI/kernels /boot

# save bind mount for future reboots
echo "/efi/EFI/kernels /boot none defaults,bind 0 0" >> /etc/fstab

# install graphics driver based on previously input gpu manufacturer
if [[ $graphics == 1 ]]
then
  pacman -S --noconfirm xf86-video-intel
fi
if [[ $graphics == 2 ]]
then
  pacman -S --noconfirm xf86-video-amdgpu
fi
if [[ $graphics == 3 ]]
then
  pacman -S --noconfirm xf86-video-nouveau
fi

# Make sure that dhcp will be enabled on restart,
# is not enabled by default
sudo systemctl enable dhcpcd.service

# cleaning up
echo "cleaning up"
rm /root/rootPartition

echo "Your system is all setup! run 'exit' then 'shutdown now' to shutdown. Remove the installation media and then start the system"
echo "for xmonad, sound configuration, terminal size changes, and no mouse acceleration run 'bash firstStartup.sh' when you log in"
echo "if you want my full linux config then run 'bash eatthoselemonsLinuxConfig.sh' after running 'firstStartup.sh'"
