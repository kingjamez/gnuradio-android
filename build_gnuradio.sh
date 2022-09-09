#!/bin/bash

install_deps() {
	sudo apt install -y git cmake g++ libboost-all-dev libgmp-dev swig python3-numpy \
python3-mako python3-sphinx python3-lxml doxygen libfftw3-dev \
libsdl1.2-dev libgsl-dev libqwt-qt5-dev libqt5opengl5-dev python3-pyqt5 \
liblog4cpp5-dev libzmq3-dev python3-yaml python3-click python3-click-plugins \
python3-zmq python3-scipy python3-gi python3-gi-cairo gir1.2-gtk-3.0 \
libcodec2-dev libgsm1-dev
	sudo apt install -y pybind11-dev python3-matplotlib libsndfile1-dev \
python3-pip libsoapysdr-dev soapysdr-tools
	sudo apt install -y libiio-dev libad9361-dev libspdlog-dev python3-packaging python3-jsonschema

}

build_volk() {
pushd volk_x86
mkdir build_x86-64 && cd build_x86-64
cmake ../
make -j9 
sudo make install
}

build_deps() {
	build_volk
}

build_gr() {
pushd gnuradio_x86
mkdir build_x86-64 && cd build_x86-64
cmake ../
make -j9
sudo make install
popd
}

$@
