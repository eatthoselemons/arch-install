# error out if there is an error in the script
trap_msg='s=${?}; echo "${0}: Error on line "${LINENO}": ${BASH_COMMAND}"; exit ${s}'
set -uo pipefail
trap "${trap_msg}" ERR

# check for UEFI files existance as recommended by
# the arch wiki
if [[ -d /sys/firmware/efi/efivars ]];
then
  echo "uefi confirmed"
  let uefi=1
else
  echo "Not UEFI exiting...."
  let uefi=0
  exit 1
fi

# check for existance of internet based on if an interface is "UP"
internet=$(ip link)
if [[ "$internet" =~ ^.*([state UP])+.*$ ]]
then
  echo "Internet confirmed"
else
  echo "No internet, use ethernet or manually setup wifi"
  exit 1
fi

# download the next step in the install process
curl -o init2.sh https://raw.githubusercontent.com/eatthoselemons/arch-install/master/init2.sh

# set time to use network time protocol
timedatectl set-ntp true

# simple vs detailed, lsblk vs fdisk
printf "\n===========================================\n"
echo "select a disk"
echo "simple or detailed disk information? (simple(s)/detailed(d)"
read diskShowTypeInput
diskShowType=detailed

if [[ $diskShowTypeInput =~ ^.*simple.*$ ]]
then
  $diskShowType=simple
fi

if [[ $diskShowtypeInput =~ ^.*s.*$ ]]
then
  $diskShowType=simple
fi
 
# detailed disk format uses fdisk
if [[ $diskShowType = "detailed" ]]
then
  printf "\n===========================================\n"
  echo "now running fdisk"
  # select disk to be overwritten
  if fdisk -l >> /dev/null;
  then
    fdisk -l
    printf "\n\n===========================================\n"
    echo "Which disk to use? input format 'sd'letter or sd[a-z]"
    echo "nvme format 'nvme[0-9]n[0-9]' example 'nvme0n1'"
    read disk
  else
    echo "fdisk not supported on this version of linux"
    exit 1
  fi
fi

# simple disk show format, uses lsblk
if [[ $diskShowType = "simple" ]]
then
  printf "\n===========================================\n"
  echo "now running lsblk"
  # select disk to be overwritten
  if lsblk >> /dev/null;
  then
    lsblk
    printf "\n\n===========================================\n"
    echo "Which disk to use? input format 'sd'letter or sd[a-z]"
    echo "nvme format 'nvme[0-9]n[0-9]' example 'nvme0n1'"
    read disk
  else
    echo "lsblk not supported on this version of linux"
    exit 1
  fi
fi

# check if is nvme drive, set partitions appropriately
if [[  $disk =~ ^.*nvme.*$ ]]
then
  efiPartition=${disk}p1
  swapPartition=${disk}p2
  rootPartition=${disk}p3
fi

# check if in sd[a-z] format and set partitions appropriately
if [[ $disk =~ ^.*sd.*$ ]]
then
  efiPartition=${disk}1
  swapPartition=${disk}2
  rootPartition=${disk}3
fi

# unmount any partitions that are mounted
# unmount /mnt/efi (efiPartition) before
# /mnt due to /mnt/efi relying on /mnt so /mnt is
# busy if you try to mount
mounts=$(mount -l)
swaps=$(cat /proc/swaps)
if [[ $mounts =~ ^.*$efiPartition.*$ ]]
then
  echo "efi already mounted, unmounting"
  umount /dev/$efiPartition
else
  echo "no need to unmount efi"
fi
if [[ $mounts =~ ^.*$rootPartition.*$ ]]
then
  echo "root already mounted, unmounting"
  umount /dev/$rootPartition
else
  echo "no need to unmount root"
fi
if [[ $swaps =~ ^.*partition.*$ ]]
then
  echo "removing swap"
  swapoff -a
else
  echo "no swap"
fi



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
  d # delete partition
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
  y # y in case it asks if we want to remove the previous partition table
  n # new partition
    # partion number 3
    # default, start immediately after preceding partition
    # default, extend partition to end of disk
  y # y in case it asks if we want to remove the previous partition table
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

# create mount directory and
# create efi directory needed for UEFI boot
# no need to create mount directory as they are in
# arch by default
# mkdir -p /mnt/efi

#format partitions
mkfs.ext4 -F /dev/${rootPartition}

# enable and turn on swap
mkswap /dev/${swapPartition}
swapon /dev/${swapPartition}

mkfs.fat /dev/${efiPartition}

#mount partitions
mkdir -p /mnt
mount /dev/${rootPartition} /mnt
mkdir -p /mnt/efi
mount /dev/${efiPartition} /mnt/efi

# install reflector for checking package repos
pacman -Sy reflector

# check latest 100 package mirrors and sort by the fastest
reflector --verbose --latest 100 --sort rate --save /etc/pacman.d/mirrorlist

#Install essential packages
pacstrap /mnt base linux linux-firmware vim vi dhcpcd sudo iputils

#fstab
if [[ -f /mnt/etc/fstab ]]
then
  rm /mnt/etc/fstab
fi
genfstab -U /mnt >> /mnt/etc/fstab

# move downloaded next step to a defined location 
# that can be reached from arch-chroot
mv init2.sh /mnt/root/
echo "$rootPartition" > /mnt/root/rootPartition

echo "setup complete, chroot with 'arch-chroot /mnt' and run the init2.sh script"
