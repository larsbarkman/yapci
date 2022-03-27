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
### /scripts/base-install.sh
- Base installation of Arch Linux
- Edit the appropriate values in the files

## Instructions
```sh
sudo pacman -Sy

sudo pacman -S git

git clone https://github.com/larsbarkman/yapci.git

cd yapci

chmod u+x /scripts/base-laptop.sh

# Please edit the appropriate values in the files before running them 

./scripts/base-laptop.sh
```

## Other scripts
- https://dev.to/krushndayshmookh/installing-arch-linux-the-scripted-way-236c
- https://github.com/LukeSmithxyz/LARBS
