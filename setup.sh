#!/bin/bash
DIRECTORY=/home/pi/RPiHY28bShield
LOGFILE=$DIRECTORY/setup.log
DRIVER=$1

echo $DIRECTORY
echo $LOGFILE
echo $DRIVER

if [ -z $1 ]; then
    echo "Usage : setup.sh [model]"
    echo "model : hy28a, hy28b"
    exit 0
else
    if [ $1 = "hy28a" ]; then
        echo "Select hy28a" >> $LOGFILE
    else 
        if [ $1 = "hy28b" ]; then
            echo "Select hy28b" >> $LOGFILE
        else
            echo "model : hy28a, hy28b"
            exit 0
        fi
    fi
fi

if [ ! -f $LOGFILE ]; then
    touch $LOGFILE
    chmod 666 $LOGFILE
fi

date >> $LOGFILE

grep -q 'setup.sh' /etc/rc.local
if [ ! $? -eq 0 ] ; then
    echo "Update rc.local" >> $LOGFILE
    sudo sed -i "/^fi/ a\su -c 'sh $DIRECTORY/setup.sh $DRIVER' pi" /etc/rc.local
fi

if [ ! -f "/usr/local/lib/libwiringPi.so" ]; then
    echo "cmake install Process" >> $LOGFILE
    sudo apt-get update;sudo apt-get upgrade -y
    sudo apt-get install cmake -y

    # wringPi install
    echo "wiringPi Build Process" >> $LOGFILE
    cd $DIRECTORY
    git clone git://git.drogon.net/wiringPi
    cd wiringPi
    ./build
    cd $DIRECTORY
    echo "wiringPi Build Done" >> $LOGFILE
fi

if [ ! -d "$DIRECTORY/rpi-fbcp" ]; then
    echo "rpi-fbcp Process" >> $LOGFILE
    # SPI enable
    sudo sed -i 's/blacklist spi-bcm2708/#blacklist spi-bcm2708/g' /etc/modprobe.d/raspi-blacklist.conf
    echo "SPI enabled" >> $LOGFILE

    # notro firmware update
    echo "rpi-firmware rpi-update Process" >> $LOGFILE
    sudo wget https://raw.github.com/Hexxeh/rpi-update/master/rpi-update -O /usr/bin/rpi-update && sudo chmod +x /usr/bin/rpi-update
    sudo mv /lib/modules/$(uname -r) /lib/modules/$(uname -r).bak
    sudo REPO_URI=https://github.com/notro/rpi-firmware UPDATE_SELF=0 rpi-update
    echo "rpi-firmware rpi-update Done" >> $LOGFILE

    # framebuffer tft-lcd fbx copy program
    echo "rpi-fbcp build Process" >> $LOGFILE
    cd $DIRECTORY
    git clone https://github.com/tasanakorn/rpi-fbcp
    cd rpi-fbcp
    mkdir build
    cd build
    cmake ..
    make
    sudo install fbcp /usr/local/bin/fbcp
    echo "rpi-fbcp build Done" >> $LOGFILE
    echo "System Reboot" >> $LOGFILE
    sudo reboot
    exit 0
fi

# HY28B Pannel
grep -q 'ads7846' /etc/modules
if [ ! $? -eq 0 ] ; then
    echo "TFT Process" >> $LOGFILE
    sh $DIRECTORY/$DRIVER.sh
    echo "TFT Done" >> $LOGFILE
    sudo reboot
    exit 0
fi

# Touch Pannel
grep -q 'DISPLAY' /etc/X11/xinit/xinitrc
if [ ! $? -eq 0 ] ; then
    echo "Touch Pannel Process" >> $LOGFILE
    sudo apt-get install libts-bin evtest xinput python-dev python-pip -y
    sudo pip install evdev
    ## Moved ##
    #echo "Touch Pannel Calibration" >> $LOGFILE
    #sudo TSLIB_FBDEVICE=/dev/fb1 TSLIB_TSDEVICE=/dev/input/event0 ts_calibrate
    ## Moved ##
    sudo sed -i "/Xsession/ i\DISPLAY=:0 xinput --set-prop 'ADS7846 Touchscreen' 'Evdev Axis Inversion' 0 0" /etc/X11/xinit/xinitrc
    sudo sed -i "/fbdev/ s/^/#/" /usr/share/X11/xorg.conf.d/99-fbturbo.conf
    sudo reboot
    exit 0
fi

echo "Touch Pannel rpi-firmware rpi-update Process" >> $LOGFILE
sudo apt-mark hold raspberrypi-bootloader
sudo apt-get update
sudo apt-get upgrade -y
sudo REPO_URI=https://github.com/notro/rpi-firmware UPDATE_SELF=0 rpi-update

echo "Almost Done..Touch Pannel Calibration" >> $LOGFILE
echo "Almost Done..Touch Pannel Calibration"
sudo TSLIB_FBDEVICE=/dev/fb1 TSLIB_TSDEVICE=/dev/input/event0 ts_calibrate

sudo sed -i '/setup.sh/d' /etc/rc.local

echo "Touch Pannel rpi-firmware rpi-update Done" >> $LOGFILE
date >> $LOGFILE

sudo reboot
exit 0

#sudo FRAMEBUFFER=/dev/fb1 startx -- -dpi 60

