#!/bin/bash

# Make sure the script is not accidentally run
read -p 'Are you sure that you want to run the script? [y/N]: ' shrun
if ! [ $shrun = 'y' ] && ! [ $shrun = 'Y' ]
then 
    echo "The script will not run"
    exit
fi

# Set local time zone to Stockholm
ln -sf /usr/share/zoneinfo/Europe/Stockholm /etc/localtime
echo "TZ='Europe/Stockholm'; export TZ" >> $HOME/.profile
hwclock --systohc

# Set locale to US English and UTF-8
sed -i '/en_US.UTF-8 UTF-8/s/^#//g' /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" >> /etc/locale.conf

# Set keyboard layout to Swedish
echo KEYMAP=sv-latin1 >> /etc/vconsole.conf

# Set font
echo FONT=ter-128n >> /etc/vconsole.conf

# Create a hostname and hosts file
echo "set hostname here" > /etc/hostname
echo "127.0.0.1	localhost" >> /etc/hosts
echo "::1 localhost" >> /etc/hosts
echo "127.0.1.1	<set hostname here>.localdomain	<set hostname here>" >> /etc/hosts

# Set a root password
echo -n "Set root passphrase here" | passwd --stdin

# Configure mkinitcpio with modules needed for the initrd image
sed -i 's/MODULES=.*/MODULES=(ext4)/' /etc/mkinitcpio.conf
sed -i 's/HOOKS=.*/MODULES=HOOKS=(base udev autodetect keyboard keymap consolefont modconf block encrypt lvm2 filesystems resume fsck)/' /etc/mkinitcpio.conf

# Regenerate initrd image
mkinitcpio -p linux

# Install boot loader (systemd-boot)
bootctl --path=/boot install

# vi /boot/loader/loader.conf
echo "timeout 5" > /boot/loader/loader.conf
echo "#console-mode keep" >> /boot/loader/loader.conf
echo "default arch-*" >> /boot/loader/loader.conf
echo "editor no " >> /boot/loader/loader.conf

# Get UUID of /dev/nvme0n1p2
UUID=$(blkid -s UUID -o value /dev/nvme0n1p2)

# vi /mnt/boot/loader/entries/arch.conf
echo "title   Arch Linux" >> /boot/loader/entries/arch.conf
echo "linux   /vmlinuz-linux" >> /boot/loader/entries/arch.conf
echo "initrd  /intel-ucode.img" >> /boot/loader/entries/arch.conf
echo "initrd  /initramfs-linux.img" >> /boot/loader/entries/arch.conf
echo "options cryptdevice=UUID=${UUID}:luks root=/dev/vg0/root resume=/dev/vg0/swap rw quiet" >> /boot/loader/entries/arch.conf