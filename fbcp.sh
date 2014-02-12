#!/bin/bash
# framebuffer tft-lcd fbx copy program

git clone https://github.com/tasanakorn/rpi-fbcp
cd rpi-fbcp
mkdir build
cd build
cmake ..
make