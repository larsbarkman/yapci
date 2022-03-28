#!/bin/bash

# Make sure the script is not accidentally run
read -p 'Are you sure that you want to run the script? [y/N]: ' shrun
if ! [ $shrun = 'y' ] && ! [ $shrun = 'Y' ]
then 
    echo "The script will not run"
    exit
fi

# Create a hostname and hosts file
echo "set hostname here" > /etc/hostname
echo "127.0.0.1	localhost" >> /etc/hosts
echo "::1 localhost" >> /etc/hosts
echo "127.0.1.1	<set hostname here>.localdomain	<set hostname here>" >> /etc/hosts

# Set a root password
echo -n "Set root passphrase here" | passwd

# Configure mkinitcpio with modules needed for the initrd image
sed -i 's/MODULES=.*/MODULES=(ext4)/' /etc/mkinitcpio.conf
sed -i 's/HOOKS=.*/MODULES=HOOKS=(base udev autodetect keyboard keymap consolefont modconf block encrypt lvm2 filesystems resume fsck)/' /etc/mkinitcpio.conf

# Regenerate initrd image
mkinitcpio -p linux

# Get UUID of /dev/nvme0n1p2
UUID=$(blkid -s UUID -o value /dev/nvme0n1p2)

# Print to see that it worked
echo "${UUID}"

# Install boot loader (systemd-boot)
bootctl --path=/boot install

# Check content of "/boot/loader/loader.conf" to determine how to handle the file (create lines or change them)
# Check content of "/boot/loader/entries/arch.conf" to determine how to handle the file (create lines or change them)