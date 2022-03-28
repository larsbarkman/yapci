#!/bin/bash

# Increase font size
setfont ter-128n

# Make sure the script is not accidentally run
read -p 'Are you sure that you want to run the script? [y/N]: ' shrun
if ! [ $shrun = 'y' ] && ! [ $shrun = 'Y' ]
then 
    echo "The script will not run"
    exit
fi

# Set variables
cryptsetup_passphrase = "Set cryptsetup passphrase here"
hostname = "Set hostname here"
root_passphrase = "Set root passphrase here"

# Memory cell clearing of the disk
pacman -Sy nvme-cli --noconfirm
nvme format /dev/nvme0 -s 1 -n 1 -f

# Partition the drive
sgdisk --zap-all /dev/nvme0n1
sgdisk -n 0:0:+1GiB -t 0:ef00 -c 0:boot /dev/nvme0n1
sgdisk -n 0:0:0 -t 0:8300 -c 0:lvm /dev/nvme0n1

# Make file system
mkfs.msdos -F32 /dev/nvme0n1p1
mkfs.ext4 /dev/nvme0n1p2

# Enable Network Time Sync
timedatectl set-ntp true

# Setup encryption on the partition
echo -n "$cryptsetup_passphrase" | cryptsetup luksFormat -q --type luks2 /dev/nvme0n1p2 -
echo -n "$cryptsetup_passphrase" | cryptsetup open /dev/nvme0n1p2 luks -

# Create logical volumes 
pvcreate /dev/mapper/luks
vgcreate vg0 /dev/mapper/luks
# Swap size for hibernation, 2xRam
lvcreate -L 32G vg0 -n swap
lvcreate -L 100G vg0 -n root
lvcreate -l +100%FREE vg0 -n home

# Create file systems and directories then mount them  
mkfs.ext4 /dev/vg0/root
mkfs.ext4 /dev/vg0/home
mkswap /dev/vg0/swap
mount /dev/vg0/root /mnt
mkdir /mnt/boot /mnt/home
mount /dev/nvme0n1p1 /mnt/boot
mount /dev/vg0/home /mnt/home
swapon /dev/vg0/swap

# Download needed packages and install with pacstrap
pacstrap /mnt base base-devel linux linux-firmware lvm2 intel-ucode man-db man-pages iproute2 dhcpcd networkmanager firewalld reflector vi powertop git

# Create file systems table (fstab) 
genfstab -U /mnt >> /mnt/etc/fstab

# Changes the root directory for the current running process
arch-chroot /mnt

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
echo "$hostname" >> /etc/hostname
echo "127.0.0.1	localhost" >> /etc/hosts
echo "::1 localhost" >> /etc/hosts
echo "127.0.1.1	${hostname}.localdomain	${hostname}" >> /etc/hosts

# Set a root password
echo -n "$root_passphrase" | passwd

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