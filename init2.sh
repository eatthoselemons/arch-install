# error out if there is an error in the script
trap_msg='s=${?}; echo "${0}: Error on line "${LINENO}": ${BASH_COMMAND}"; exit ${s}'
set -uo pipefail
trap "${trap_msg}" ERR

echo "you need region and city the regions and city can be found at: /usr/share/zoneinfo/region/city"

# grab zone info for clock
ls /usr/share/zoneinfo
echo "regions ^^"
echo "What Region are you in?"
read region
ls /usr/share/zoneinfo/$region
echo "cities ^^"
echo "What city are you in?"
read city

echo "What is the system hostname?"
read hostname

echo "set root password"
passwd

echo "what is the user account name?"
read regularUsername

useradd $regularUsername
passwd $regularUsername
echo "$regularUsername ALL=(ALL) ALL" >> /etc/sudoers
mkdir /home/$regularUsername
chown $regularUsername:$regularUsername /home/$regularUsername

# make sure system has wget
pacman -S wget

cd /home/$regularUsername/

wget https://raw.githubusercontent.com/eatthoselemons/arch-install/master/firstStartup.sh



echo "what processor do you have AMD or Intel?"
read cpu

# processor 0=unknown 1=intel 2=amd
# case insensitive regex selection
let processor=0
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


echo "what graphics do you have AMD, nVidia, or Intel?"
read gpu

# graphics 0=unknown 1=intel 2=amd 3=nvidia
# case insensitive regex selection
let graphics=0

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

# set clock zone
ln -sf /usr/share/zoneinfo/$region/$city /etc/localtime
hwclock --systohc

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
echo "default  arch" > /efi/loader/loader.conf
echo "timeout  4" >> /efi/loader/loader.conf
echo "console-mode max" >> /efi/loader/loader.conf
echo "editor   no" >> /efi/loader/loader.conf


echo "title   Arch Linux" > /efi/loader/entries/arch.conf
echo "linux   EFI/kernels/vmlinuz-linux" >> /efi/loader/entries/arch.conf
echo "initrd  EFI/kernels/initramfs-linux.img" >> /efi/loader/entries/arch.conf
echo "options root=/dev/sda3 rw" >> /efi/loader/entries/arch.conf

# grab top 100 mirrors and sort by how fast they are
reflector --verbose --latest 100 --sort rate --save /etc/pacman.d/mirrorlist

# manually copy the boot files from the non-UEFI location /boot
# to the UEFI location /efi
# superceeded by mount --bind
# cp -a /boot/vmlinuz-linux /efi/EFI/kernels
# cp -a /boot/initramfs-linux.img /efi/EFI/kernels
# cp -a /boot/initramfs-linux-fallback.img /efi/EFI/kernels

# grab ucode based on processor type
if [[ $processor == 1 ]]
then
  pacman -S intel-ucode
  bootctl --path=/efi install
  echo "initrd  EFI/kernels/intel-ucode.img" >> /efi/loader/entries/arch.conf
 # cp -a /boot/intel-ucode.img /efi/EFI/kernels
fi

if [[ $processor == 2 ]]
then
  pacman -S amd-ucode
  bootctl --path=/efi install
  echo "initrd  EFI/kernels/amd-ucode.img" >> /efi/loader/entries/arch.conf
 # cp -a /boot/amd-ucode.img /efi/EFI/kernels
fi

# bind /boot/* to /efi/EFI/kernels/
# /efi/EFI/kernels is where the systemd boot loader
# is looking for the boot files
mount --bind /boot /efi/EFI/kernels

# save bind mount for future reboots
echo "/boot /efi/EFI/kernels none defaults,bind 0 0" >> /etc/fstab

# install graphics driver based on previously input gpu manufacturer
if [[ $graphics == 1 ]]
then
  pacman -S xf86-video-intel
fi
if [[ $graphics == 2 ]]
then
  pacman -S xf86-video-amdgpu
fi
if [[ $graphics == 3 ]]
then
  pacman -S xf86-video-nouveau
fi

# Make sure that dhcp will be enabled on restart,
# is not enabled by default
sudo systemctl enable dhcpcd.service

echo "Your system is all setup! run 'exit' then 'shutdown now' to shutdown. Remove the installation media and then start the system"
echo "for xmonad, sound configuration, terminal size changes, and no mouse acceleration run 'bash firstStartup.sh' when you log in"
echo "if you want my full linux config then run 'bash eatthoselemonsLinuxConfig.sh' after running 'firstStartup.sh'"
