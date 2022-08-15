#!/bin/bash
source ./android_toolchain.sh $1 $2
source ./include_dependencies.sh

clean() {
reset_build_env
create_build_status_file
}

first_stage() {

clean
build_libiconv
build_libffi
build_gettext # no longer needed ?
build_libiconv # HANDLE CIRCULAR DEP
#build_openssl
build_glib
build_libxml2
build_python
build_libsigrokdecode
}

second_stage() {
#build_qwt
#move_qwt_libs
#build_boost
#move_boost_libs
## build_libzmq
#build_fftw
## build_thrift
#build_libgmp
#build_libusb
#build_libiio
#build_libad9361
#build_libm2k
## build_hackrf
## build_uhd
## build_rtl-sdr
#build_spdlog
#build_libsndfile
### #build_portaudio # not sure if this will work ??
## build_pybind
#build_volk
build_gnuradio3.10
build_gr-m2k
#build_gr-osmosdr
#build_gr-grand  # - need to be ported to gr 3.10 or repull ?
# build_gr-sched
# build_gr-ieee-802-15-4
# build_gr-ieee-802-11
# build_gr-clenabled
}

#first_stage
second_stage


