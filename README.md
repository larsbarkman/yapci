# Yet another PC Installer (yapci)

**WARNING!! This repository is work in progress and is not in any way, shape or form complete or even functional!**

## Introduction
This repository contains my personal scripts for installing/reinstalling my laptops and desktops.

## Why
To be able to make frequent changes to my PCs it's easier if the installation is automated. 

## How
By having a single repository containing all files needed to automatically install everything it's very easy to clone the repo to a machine and run the scripts one by one.

## What
### Prerequisites
- The script is intended for a Dell XPS 15 (9570) but might work on other machines as well
- Arch Linux ISO booted on the machine
- Machine has internet connection

### Content
#### /scripts/base-install.sh
- Base installation of Arch Linux
- Edit the appropriate values in the files

## Instructions
### Update Bios to most recent version
- [Flash bios](https://www.dell.com/support/article/ca/en/cadhs1/sln171755/updating-the-dell-bios-in-linux-and-ubuntu-environments)

### Create bootable media
- Create bootable USB with the latest [Arch Linux ISO](https://www.archlinux.org/download/) (don't forget to validate checksum)

### Boot from USB
- Enter Bios settings (F2 on boot)
  - SATA Operation = AHCI (Settings/System Configuration)
  - Turn Touchscreen off (Settings/System Configuration) (Optional)
  - Turn Secure Boot off (Settings/Secure Boot)    
  - Change boot sequence to boot from USB first (Settings/General)
  - Apply and Exit
- Select: "*x86_64, UEFI*"

### Load keyboard layout
`# loadkeys sv-latin1`  

### Connect to the Internet via wifi (optional)
`# iwctl`  
`[iwd]# device list`  
`[iwd]# station <wlan id> scan`  
`[iwd]# station <wlan id> get-networks`  
`[iwd]# station <wlan id> connect <SSID>`  
`[iwd]# exit`  

`# ping -c 3 archlinux.org`  

### Get Git
`# pacman -Sy`  

`# pacman -S git`  

### Get installation scripts
`# git clone https://github.com/larsbarkman/yapci.git`  

`# cd yapci`  

### Make the scripts executable
`# chmod u+x ./scripts/*`  

### Edit the appropriate values in the files 
`# vim ./scripts/base-laptop-stage1.sh`  
`# vim ./scripts/base-laptop-stage2.sh`  

### Run first stage 
`# ./scripts/base-laptop-stage1.sh` 

### Changes the root directory for the current running process
`# arch-chroot /mnt`  

### Set root password
`# passwd`  

### Run second stage 
`# ./home/yapci/dmesgscripts/base-laptop-stage2.sh` 

### Reboot
`# exit`  
`# reboot`  

### LOGIN
- Log in again with root user

### Download scripts again
`# cd cd ~`  

`# mkdir git`  

`# cd git`  

`# git clone https://github.com/larsbarkman/yapci.git`  

`# cd yapci`  

### Make the scripts executable
`# chmod u+x ./scripts/*`  

### Edit the appropriate values in the file 
`# vim ./scripts/post-base.sh`  

### Run script
`# ./scripts/post-base.sh` 

## Other scripts and guides
- https://dev.to/krushndayshmookh/installing-arch-linux-the-scripted-way-236c
- https://github.com/tom5760/arch-install
- https://github.com/classy-giraffe/easy-arch
- https://primalcortex.wordpress.com/2018/11/23/arch-linux-with-full-encrypted-disk/
- https://www.mpilote.com/computer/2019/10/19/install-arch-linux-on-thinkpad-x1-yoga-gen-4
- https://medium.com/@lylejfranklin/arch-linux-install-defense-in-depth-1f788d1bf3a5
- https://gist.github.com/stevepet/cc18f091b7cc3d4bc904515d00c86ec9
- https://austinmorlan.com/posts/arch_linux_install/
- https://www.nerdstuff.org/posts/2020/2020-004_arch_linux_luks_btrfs_systemd-boot/
- https://gist.github.com/ansulev/7cdf38a3d387599adf9addd248b09db8
- https://github.com/LukeSmithxyz/LARBS
- https://gist.github.com/marc-fez/ca7ad54af72d353f595d08b4304fe0df
