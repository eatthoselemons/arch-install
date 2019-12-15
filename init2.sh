echo "you need region and city the regions and city can be found at: /usr/share/zoneinfo/region/city"

echo "What Region are you in?"
read region
echo "What city are you in?"
read city

echo "What is the system hostname?"
read hostname

echo "set root password"
passwd

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
  echo "you have $processor"
fi

#echo "/usr/share/zoneinfo/$region/$city"
ln -sf /usr/share/zoneinfo/$region/$city /etc/localtime
hwclock --systohc

echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen

touch /etc/locale.conf
echo "LANG=en_US.UTF-8" >> /etc/locale.conf

touch /etc/$hostname
echo $hostname >> /etc/$hostname

echo "127.0.0.1 localhost" >> /etc/hosts
echo "::1 localhost" >> /etc/hosts
echo "217.0.0.1 $hostname.localdomain $hostname" >> /etc/hosts

if [[ $processor == 1 ]]
then
  pacman -S intel-ucode
  bootctl --path=/efi install
  echo "initrd  /intel-ucode.img" >> /efi/loader/entries/entry.conf
  cp -a /boot/vmlinuz-linux /efi
  cp -a /boot/initramfs-linux.img /efi
  cp -a /boot/initramfs-linux-fallback.img /efi
  cp -a /boot/intel-ucode.img /efi
fi

if [[ $processor == 2 ]]
then
  pacman -S amd-ucode
  bootctl --path=/efi install
  echo "initrd  /amd-ucode.img" >> /efi/loader/entries/entry.conf
  cp -a /boot/vmlinuz-linux /efi
  cp -a /boot/initramfs-linux.img /efi
  cp -a /boot/initramfs-linux-fallback.img /efi
  cp -a /boot/amd-ucode.img /efi
fi
