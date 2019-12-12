if [[ -f /sys/firmware/efi/efivars ]];
then
  echo "uefi confirmed"
  let uefi=1
else
  echo "Not UEFI exiting...."
  let uefi=0
#  exit 1
fi

internet=$(ip link)
echo $internet
if [[ "$internet" =~ ^.*([state UP])+.*$ ]]
then
  echo "Internet confirmed"
else
  echo "No internet, use ethernet or manually setup wifi"
  exit 1
fi


timedatectl set-ntp true

echo "==========================================="

if sudo fdisk -l >> /dev/null;
then
  sudo fdisk -l
  echo "Which disk to use? input format 'sd'letter or sd[a-z]"
  read disk
else
  echo "fdisk not supported on this version of linux"
  exit 1
fi

let efiPartition=${disk}1
let swapParitition=${disk}2
let rootParitition=${disk}3



echo "==========================================="

#create mnt directory
if [[ ! -d /mnt ]];
then
  sudo mkdir /mnt
fi
if [[ ! -d /mnt ]];
then
  sudo mkdir /mnt
fi

#create efi directory
if [[ ! -d /mnt/efi ]];
then
  sudo mkdir /mnt/efi
fi
if [[ ! -d /mnt/efi ]];
then
  sudo mkdir /mnt/efi
fi

#mount partitions
mount /dev/$rootPartition /mnt
mount /dev/$efiPartition /mnt/efi

