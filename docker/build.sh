#!/bin/bash

docker build -t analogdevices/gnuradio-android-3.10 .

docker run -it --privileged --net=host --env="DISPLAY" --volume="$HOME/.Xauthority:/home/android/.Xauthority:rw"  analogdevices/gnuradio-android-3.10
