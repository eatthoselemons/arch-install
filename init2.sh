echo "you need region and city the regions and city can be found at: /usr/share/zoneinfo/region/city"

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
mkdir /home/user
chown user:user /home/user

echo "what processor do you have AMD or Intel?"
read cpu

# processor 0=unknown 1=intel 2=amd
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
  echo "you have $cpu"
fi

#echo "/usr/share/zoneinfo/$region/$city"
ln -sf /usr/share/zoneinfo/$region/$city /etc/localtime
hwclock --systohc

echo "en_US.UTF-8 UTF-8" > /etc/locale.gen
locale-gen

touch /etc/locale.conf
echo "LANG=en_US.UTF-8" > /etc/locale.conf

touch /etc/hostname
echo $hostname > /etc/hostname

echo "127.0.0.1 localhost" > /etc/hosts
echo "::1 localhost" >> /etc/hosts
echo "127.0.1.1 $hostname.localdomain $hostname" >> /etc/hosts

if [[ ! -f /efi/loader/entries/entry.conf/ ]]
then
  mkdir -p /efi/loader/entries
fi


echo "default  arch" > /efi/loader/loader.conf
echo "timeout  4" >> /efi/loader/loader.conf
echo "console-mode max" >> /efi/loader/loader.conf
echo "editor   no" >> /efi/loader/loader.conf


echo "title   Arch Linux" > /efi/loader/entries/arch.conf
echo "linux   /vmlinuz-linux" >> /efi/loader/entries/arch.conf
echo "initrd  /initramfs-linux.img" >> /efi/loader/entries/arch.conf
echo "options root=/dev/sda3 rw" >> /efi/loader/entries/arch.conf


reflector --verbose --latest 10 --sort rate --save /etc/pacman.d/mirrorlist

if [[ $processor == 1 ]]
then
  pacman -S intel-ucode
  bootctl --path=/efi install
  echo "initrd  /intel-ucode.img" >> /efi/loader/entries/arch.conf
  cp -a /boot/vmlinuz-linux /efi
  cp -a /boot/initramfs-linux.img /efi
  cp -a /boot/initramfs-linux-fallback.img /efi
  cp -a /boot/intel-ucode.img /efi
fi

if [[ $processor == 2 ]]
then
  pacman -S amd-ucode
  bootctl --path=/efi install
  echo "initrd  /amd-ucode.img" >> /efi/loader/entries/arch.conf
  cp -a /boot/vmlinuz-linux /efi
  cp -a /boot/initramfs-linux.img /efi
  cp -a /boot/initramfs-linux-fallback.img /efi
  cp -a /boot/amd-ucode.img /efi
fi

echo "Your system is all setup! run 'shutdown now' to shutdown. Remove the installation media and then start the system"
