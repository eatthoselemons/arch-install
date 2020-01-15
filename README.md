# Arch-install

This is an install script for installing arch and getting everything set up

Last tested Dec, 2019

# Usage:
### Get Arch installer
grab the arch iso from one of the mirrors an example url is provided below
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
`bash /home/init2.sh`

Follow the prompts and once that script finishes then you will be all setup!

### End

Shutdown the machine with `shutdown now`
Remove the USB
Restart into Arch Linux!


# Notes

Thinks to keep in mind:
When asked for the disk use the format `sda` or for a regex sd[a-z]