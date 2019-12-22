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
#echo $internet
if [[ "$internet" =~ ^.*([state UP])+.*$ ]]
then
  echo "Internet confirmed"
else
  echo "No internet, use ethernet or manually setup wifi"
  exit 1
fi

wget https://raw.githubusercontent.com/eatthoselemons/arch-install/master/init2.sh

timedatectl set-ntp true

echo "==========================================="

if fdisk -l >> /dev/null;
then
  fdisk -l
  echo "Which disk to use? input format 'sd'letter or sd[a-z]"
  read disk
else
  echo "fdisk not supported on this version of linux"
  exit 1
fi

efiPartition=${disk}1
swapPartition=${disk}2
rootPartition=${disk}3

# stolen from "How to create and format partition using a bash script" from superUser
# to create the partitions programatically (rather than manually)
# we're going to simulate the manual input to fdisk
# The sed script strips off all the comments so that we can 
# document what we're doing in-line with the actual commands
# Note that a blank line (commented as "defualt" will send a empty
# line terminated with a newline to take the fdisk default.
sed -e 's/\s*\([\+0-9a-zA-Z]*\).*/\1/' << EOF | fdisk /dev/${disk}
  d # delete partition
    # confirm
  d # delete partition (maybe if not just continues)
    # confirm
  d # delete parittion
    # confirm
  g # make GPT partition table
  n # new partition
    # partition number 1
    # default - start at beginning of disk 
  +500M # 500 MB boot parttion
  y # y in case it asks if we want to remove the previous partition table
  n # new partition
    # partion number 2
    # default, start immediately after preceding partition
  +2G # 2 Gigabyte swap partition
  n # new partition
    # partion number 3
    # default, start immediately after preceding partition
    # default, extend partition to end of disk
  t # change partition table type
  1 # select partition 1
  1 # set partition 1 to EFI
  t # change partition table type
  2 # select partition 2
  19 # set partition to swap
  t # change partition table type
  3 # select partition 3
  20 # change partition to linux filesystem
  p # print the in-memory partition table
  w # write the partition table
EOF






echo "==========================================="

#create mnt directory
if [[ ! -d /mnt ]];
then
  mkdir /mnt
fi
if [[ ! -d /mnt ]];
then
  mkdir /mnt
fi

#create efi directory
if [[ ! -d /mnt/efi ]];
then
  mkdir /mnt/efi
fi
if [[ ! -d /mnt/efi ]];
then
  mkdir /mnt/efi
fi

#format partitions
mkfs.ext4 /dev/${rootPartition}

mkswap /dev/${swapPartition}
swapon /dev/${swapPartition}

mkfs.fat /dev/${efiPartition}

#mount partitions
mount /dev/${rootPartition} /mnt
mount /dev/${efiPartition} /mnt/efi

#Install essential packages
pacstrap --noconfirm /mnt base linux linux-firmware vim vi dhcpcd sudo iputils

#fstab
if [[ -f /mnt/etc/fstab ]]
then
  rm /mnt/etc/fstab
fi
genfstab -U /mnt >> /mnt/etc/fstab

echo "setup complete, chroot with 'arch-chroot /mnt' and run the init2.sh script"



