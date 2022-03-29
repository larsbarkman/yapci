#!/bin/bash

# Include static variables
source /variables.conf

# Make sure the script is not accidentally run
read -p 'Are you sure that you want to run the script? [y/N]: ' shrun
if ! [ $shrun = 'y' ] && ! [ $shrun = 'Y' ]
then 
    echo "The script will not run"
    exit
fi

# Increase font size
setfont ter-128n

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
echo -n "Set cryptsetup passphrase here" | cryptsetup luksFormat -q --type luks2 /dev/nvme0n1p2 -
echo -n "Set cryptsetup passphrase here" | cryptsetup open /dev/nvme0n1p2 luks -

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

# Copy installation repo over to /home/yapci
mkdir /mnt/home/yapci
cp -R * /mnt/home/yapci
chmod u+x /mnt/home/yapci/scripts/*