if [[ -f /sys/firmware/efi/efivars ]];
then
  echo "uefi confirmed"
else
  echo "Not UEFI exiting...."
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
