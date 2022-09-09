# GNU Radio C++ Flow Graph CMakeLists.txt
#
# Title: SignalLoopback
# GNU Radio version: 3.10.3.0


cmake_minimum_required(VERSION 3.8)
set(CMAKE_CXX_STANDARD 14)

project(SignalLoopback)

find_package(Gnuradio "3.10" COMPONENTS
    blocks
    fec
    fft
    filter
    analog
    dtv
    audio
    channels
    pdu
    iio
    qtgui
    vocoder
    network
)

find_package(Qt5Widgets REQUIRED)
set(CMAKE_AUTOMOC TRUE)



add_executable(SignalLoopback SignalLoopback.cpp)
target_link_libraries(SignalLoopback
    gnuradio::gnuradio-blocks
    gnuradio::gnuradio-qtgui
    gnuradio::gnuradio-qtgui
    gnuradio::gnuradio-analog

)

