#!/bin/bash

sudo apt-get update;sudo apt-get upgrade -y
sudo apt-get install cmake -y

# wringPi install
git clone git://git.drogon.net/wiringPi
cd wiringPi
./build

cd ..

# SPI enable
sudo sed -i 's/blacklist spi-bcm2708/#blacklist spi-bcm2708/g' /etc/modprobe.d/raspi-blacklist.conf

# notro firmware update
sudo wget https://raw.github.com/Hexxeh/rpi-update/master/rpi-update -O /usr/bin/rpi-update && sudo chmod +x /usr/bin/rpi-update
sudo mv /lib/modules/$(uname -r) /lib/modules/$(uname -r).bak
sudo REPO_URI=https://github.com/notro/rpi-firmware rpi-update

# framebuffer tft-lcd fbx copy program
git clone https://github.com/tasanakorn/rpi-fbcp
cd rpi-fbcp
mkdir build
cd build
cmake ..
make
sudo install fbcp /usr/local/bin/fbcp

# Touch Pannel
# Touch Pannel
sudo apt-get install libts-bin evtest xinput python-dev python-pip -y
sudo pip install evdev
 
sudo TSLIB_FBDEVICE=/dev/fb1 TSLIB_TSDEVICE=/dev/input/event0 ts_calibrate
 
sudo sed -i "/Xsession/ i\DISPLAY=:0 xinput --set-prop 'ADS7846 Touchscreen' 'Evdev Axis Inversion' 0 0" /etc/X11/xinit/xinitrc

sudo sed -i "/fbdev/ s/^/#/" /usr/share/X11/xorg.conf.d/99-fbturbo.conf

sudo apt-mark hold raspberrypi-bootloader
sudo apt-get update
sudo apt-get upgrade
 
sudo REPO_URI=https://github.com/notro/rpi-firmware rpi-update
 
sudo FRAMEBUFFER=/dev/fb1 startx -- -dpi 60
