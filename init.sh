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

# stolen from "How to create and format partition using a bash script" from superUser
# to create the partitions programatically (rather than manually)
# we're going to simulate the manual input to fdisk
# The sed script strips off all the comments so that we can 
# document what we're doing in-line with the actual commands
# Note that a blank line (commented as "defualt" will send a empty
# line terminated with a newline to take the fdisk default.
sed -e 's/\s*\([\+0-9a-zA-Z]*\).*/\1/' << EOF | fdisk ${TGTDEV}
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
  n # new partition
    # partion number 2
    # default, start immediately after preceding partition
  +2G # 2 Gigabyte swap partition
  n # new partition
    # default, start immediately after preceding partition
    # default, extend partition to end of disk
  p # print the in-memory partition table
  w # write the partition table
EOF






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

#format partitions
mkfs.ext4 /dev/$rootPartition

mkswap /dev/$swapPartition
swapon /dev/$swapPartition

mkfs.fat /dev/$efiPartition

#mount partitions
mount /dev/$rootPartition /mnt
mount /dev/$efiPartition /mnt/efi

#Install essential packages
pacstrap /mnt base linux linux-firmware vim dhcpd

#fstab
genfstab -U /mnt >> /mnt/etc/fstab

echo "setup complete, chroot with 'arch-chroot /mnt' and run the init2.sh script"



