#!/bin/bash
DIRECTORY=~/RPiHY28bShield

echo $DIRECTORY

touch setup.log

grep -q 'setup.sh' /etc/rc.local
if [ ! $? -eq 0 ] ; then
    echo "Update rc.local" >> $DIRECTORY/setup.log
    sudo sed -i "/^fi/ a\su -c 'sh $DIRECTORY/setup.sh' pi" /etc/rc.local
fi

if [ ! -f "/usr/local/lib/libwiringPi.so"]; then
    echo "wiringPi Build Process" >> $DIRECTORY/setup.log
    sudo apt-get update;sudo apt-get upgrade -y
    sudo apt-get install cmake -y

    # wringPi install
    cd $DIRECTORY
    git clone git://git.drogon.net/wiringPi
    cd wiringPi
    ./build
    cd $DIRECTORY
    echo "wiringPi Build Done" >> $DIRECTORY/setup.log
fi 

if [ ! -d "$DIRECTORY/rpi-fbcp"]; then
    echo "rpi-fbcp Process" >> $DIRECTORY/setup.log
    # SPI enable
    sudo sed -i 's/blacklist spi-bcm2708/#blacklist spi-bcm2708/g' /etc/modprobe.d/raspi-blacklist.conf
    echo "SPI enabled" >> $DIRECTORY/setup.log

    # notro firmware update
    sudo wget https://raw.github.com/Hexxeh/rpi-update/master/rpi-update -O /usr/bin/rpi-update && sudo chmod +x /usr/bin/rpi-update
    sudo mv /lib/modules/$(uname -r) /lib/modules/$(uname -r).bak
    sudo REPO_URI=https://github.com/notro/rpi-firmware rpi-update
    echo "rpi-firmware rpi-update Done" >> $DIRECTORY/setup.log

    # framebuffer tft-lcd fbx copy program
    echo "rpi-fbcp build Process" >> $DIRECTORY/setup.log
    cd $DIRECTORY
    git clone https://github.com/tasanakorn/rpi-fbcp
    cd rpi-fbcp
    mkdir build
    cd build
    cmake ..
    make
    sudo install fbcp /usr/local/bin/fbcp
    echo "rpi-fbcp build Done" >> $DIRECTORY/setup.log
    echo "System Reboot" >> $DIRECTORY/setup.log
    sudo reboot
    exit 0
fi

# Touch Pannel
grep -q 'DISPLAY' /etc/X11/xinit/xinitrc
if [ ! $? -eq 0 ] ; then
    echo "Touch Pannel Process" >> $DIRECTORY/setup.log
    sudo apt-get install libts-bin evtest xinput python-dev python-pip -y
    sudo pip install evdev
    echo "Touch Pannel Calibration" >> $DIRECTORY/setup.log
    sudo TSLIB_FBDEVICE=/dev/fb1 TSLIB_TSDEVICE=/dev/input/event0 ts_calibrate
    sudo sed -i "/Xsession/ i\DISPLAY=:0 xinput --set-prop 'ADS7846 Touchscreen' 'Evdev Axis Inversion' 0 0" /etc/X11/xinit/xinitrc
    sudo sed -i "/fbdev/ s/^/#/" /usr/share/X11/xorg.conf.d/99-fbturbo.conf
    sudo reboot
    exit 0
fi

sudo apt-mark hold raspberrypi-bootloader
sudo apt-get update
sudo apt-get upgrade -y
sudo REPO_URI=https://github.com/notro/rpi-firmware rpi-update

sudo sed -i '/setup.sh/d' /etc/rc.local

sudo reboot
exit 0


#sudo FRAMEBUFFER=/dev/fb1 startx -- -dpi 60

