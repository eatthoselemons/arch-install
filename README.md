# Arch-install

This is an install script for installing arch and getting everything set up

Last tested April, 2019

Broken March, 2020 - current arch forum question to fix errors
error: "reboot and select proper boot device"

**Note** there are lots of commits as that was the easiest way to pull down the script to the arch installation

# Usage:
### Get Arch installer
grab the arch iso from one of the iso mirrors. An example url is provided below
http://mirror.arizona.edu/archlinux/iso/

### Install to a USB
Download Balena Etcher, which has become the default iso buring software.

https://www.balena.io/etcher/

Use Balena Etcher to install the downloaded iso to a usb

### Boot Into the ISO

Use the boot screen to boot into the iso (Once powered on repeatedly press the boot key) (F12 on some computers)

### In the boot Screen
run the following command:
`wget https://raw.githubusercontent.com/eatthoselemons/arch-install/master/init.sh`

Then run `bash init.sh` and follow the prompts

### After the First One Finishes

chroot into the new system with `arch-chroot /mnt` and run:
`bash /root/init2.sh`

Follow the prompts and once that script finishes then you will be all setup!

### End

Shutdown the machine with `shutdown now`
Remove the USB
Restart into Arch Linux!

### First boot

To setup xorg and display manager as well as a better terminal than the default run:
`bash firstStartup.sh`
