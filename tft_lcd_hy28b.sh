#!/bin/bash

# wringPi install
sudo apt-get update;sudo apt-get upgrade -y
git clone git://git.drogon.net/wiringPi
cd wiringPi
./build

# SPI enable
sudo sed -i 's/blacklist spi-bcm2708/#blacklist spi-bcm2708/g' /etc/modprobe.d/raspi-blacklist.conf

# notro firmware update
sudo wget https://raw.github.com/Hexxeh/rpi-update/master/rpi-update -O /usr/bin/rpi-update && sudo chmod +x /usr/bin/rpi-update
sudo mv /lib/modules/$(uname -r) /lib/modules/$(uname -r).bak
sudo REPO_URI=https://github.com/notro/rpi-firmware rpi-update

# TFT LCD Module active
sudo sed -i "a\modprobe fb_ili9325 dma" /etc/modules
sudo sed -i "a\fbtft_device name=hy28b rotate=90 speed=48000000 fps=20" /etc/modules
sudo sed -i "a\ads7846_device pressure_max=255 y_min=190 y_max=3850 gpio_pendown=17 x_max=3850 x_min=230 x_plate_ohms=100 swap_xy=1 verbose=3" /etc/modules
sudo sed -i "a\ads7846" /etc/modules

# TFT-LCD enable
sudo sed -i "a\con2fbmap 1 1" /etc/profile
sudo sed -i "a\con2fbmap 1" /etc/profile

#sudo nano /boot/cmdline.txt
sudo sed -i "1s/rootwait/rootwait fbcon=map:10 fbcon=font:ProFont6x11/" /boot/cmdline.txt

sudo reboot
