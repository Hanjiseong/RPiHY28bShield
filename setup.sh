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
