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
- Select: * x86_64 UEFI USB

### Load keyboard layout
`# loadkeys sv-latin1`  

### Connect to the Internet via wifi (optional)
`# iwctl`  
`[iwd]# device list`  
`[iwd]# station device scan`  
`[iwd]# station device get-networks`  
`[iwd]# station device connect SSID`  
`[iwd]# exit`  
`# ping -c 3 archlinux.org`  

### Get Git
`# pacman -Sy`  

`# pacman -S git`  

### Get installation scripts
`# git clone https://github.com/larsbarkman/yapci.git`  

`# cd yapci`  

`# chmod u+x /scripts/base-laptop.sh`  

### Please edit the appropriate values in the files before running them 

`# ./scripts/base-laptop.sh` 

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

`# chmod u+x /scripts/post-base.sh`  

### Please edit the appropriate values in the files before running them 

`# ./scripts/post-base.sh`  

## Other scripts
- https://dev.to/krushndayshmookh/installing-arch-linux-the-scripted-way-236c
- https://github.com/LukeSmithxyz/LARBS
