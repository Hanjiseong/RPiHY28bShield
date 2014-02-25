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
