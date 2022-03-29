#!/bin/bash

# Make sure the script is not accidentally run
read -p 'Are you sure that you want to run the script? [y/N]: ' shrun
if ! [ $shrun = 'y' ] && ! [ $shrun = 'Y' ]
then 
    echo "The script will not run"
    exit
fi

# Set variables for the scripts here
hostname="set hostname here"

# Set local time zone to Stockholm
ln -sf /usr/share/zoneinfo/Europe/Stockholm /etc/localtime
echo "TZ='Europe/Stockholm'; export TZ" > $HOME/.profile
hwclock --systohc

# Set locale to US English and UTF-8
sed -i '/en_US.UTF-8 UTF-8/s/^#//g' /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf

# Set keyboard layout to Swedish
echo KEYMAP=sv-latin1 > /etc/vconsole.conf

# Set font
echo FONT=ter-128n >> /etc/vconsole.conf

# Create a hostname and hosts file
echo "$hostname" > /etc/hostname
echo "127.0.0.1	localhost" >> /etc/hosts
echo "::1 localhost" >> /etc/hosts
echo "127.0.1.1	$hostname.localdomain $hostname" >> /etc/hosts

# Configure mkinitcpio with modules needed for the initrd image
sed -i 's/MODULES=.*/MODULES=(ext4)/' /etc/mkinitcpio.conf
#sed -i 's/HOOKS=.*/MODULES=HOOKS=(base systemd autodetect keyboard keymap sd-vconsole modconf block sd-encrypt lvm2 filesystems resume fsck)' /etc/mkinitcpio.conf
sed -i 's/HOOKS=.*/MODULES=HOOKS=(base udev autodetect keyboard keymap consolefont modconf block encrypt lvm2 filesystems resume fsck)' /etc/mkinitcpio.conf

# Regenerate initrd image
mkinitcpio -p linux

# Get UUID of /dev/nvme0n1p2
UUID=$(blkid -s UUID -o value /dev/nvme0n1p2)
printf $UUID

# update /etc/default/grub (grub bootloader)
sed -i 's/#GRUB_ENABLE_CRYPTODISK=y/GRUB_ENABLE_CRYPTODISK=y/' /etc/default/grub
GRUB_CMDLINE_LINUX="GRUB_CMDLINE_LINUX="cryptdevice=UUID=$UUID:cryptlvm root=/dev/vg0/root resume=/dev/vg0/swap rw quiet""
sed -i 's/GRUB_CMDLINE_LINUX=""/$GRUB_CMDLINE_LINUX/' /etc/default/grub

# Install GRUB to the mounted ESP for UEFI booting
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
#Generate the main configuration file
grub-mkconfig -o /boot/grub/grub.cfg

# Update /boot/loader/loader.conf
#echo "timeout 5" > /boot/loader/loader.conf
#echo "#console-mode keep" >> /boot/loader/loader.conf
#echo "default arch-*" >> /boot/loader/loader.conf
#echo "editor no " >> /boot/loader/loader.conf

# Update /boot/loader/entries/arch.conf
#echo "title   Arch Linux" > /boot/loader/entries/arch.conf
#echo "linux   /vmlinuz-linux" >> /boot/loader/entries/arch.conf
#echo "initrd  /intel-ucode.img" >> /boot/loader/entries/arch.conf
#echo "initrd  /initramfs-linux.img" >> /boot/loader/entries/arch.conf
#echo "options cryptdevice=UUID=$UUID:cryptlvm root=/dev/vg0/root resume=/dev/vg0/swap rw quiet" >> /boot/loader/entries/arch.conf
#echo "options cryptdevice=UUID=$UUID:root root=/dev/vg0/root resume=/dev/vg0/swap rw quiet" >> /boot/loader/entries/arch.conf
#echo "options cryptdevice=UUID=$UUID:lvm root=/dev/vg0/root resume=/dev/vg0/swap rw quiet" >> /boot/loader/entries/arch.conf