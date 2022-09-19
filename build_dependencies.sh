#!/bin/bash

source ./android_toolchain.sh $ARCH

set -xe

reset_build_env() {
	rm -rf $WORKDIR
	mkdir -p $WORKDIR
	cd $WORKDIR
}

create_build_status_file() {
	touch $BUILD_STATUS_FILE
	echo "NDK - $NDK_VERSION" >> $BUILD_STATUS_FILE
	echo "ANDROID API - $API" >> $BUILD_STATUS_FILE
	echo "ABI - $ABI" >> $BUILD_STATUS_FILE
	echo "JDK - $JDK" >> $BUILD_STATUS_FILE
	echo "Qt - $QT_VERSION_STRING" >> $BUILD_STATUS_FILE
	pushd $GR4A_SCRIPT_DIR
	echo "scopy-android-deps - $(git rev-parse --short HEAD)" >> $BUILD_STATUS_FILE
	pushd $GR4A_SCRIPT_DIR
	echo "gnuradio-android - $(git rev-parse --short HEAD)" >> $BUILD_STATUS_FILE
}

#export SYS_ROOT=$SYSROOT
export PATH=${TOOLCHAIN_BIN}:${PATH}
export PREFIX=$DEV_PREFIX
export BUILD_FOLDER=./$BUILDDIR
#export PREFIX=${GR4A_SCRIPT_DIR}/toolchain/$ABI

mkdir -p ${PREFIX}

echo $SYS_ROOT $GR4A_SCRIPT_DIR $PATH $PREFIX

build_with_cmake() {
        cp ${GR4A_SCRIPT_DIR}/android_cmake.sh .
        echo "$CURRENT_BUILD - $(git rev-parse --short HEAD)" >> $BUILD_STATUS_FILE
        rm -rf $BUILD_FOLDER
        mkdir -p $BUILD_FOLDER
        echo $PWD
        ./android_cmake.sh $@  \
        -DCMAKE_VERBOSE_MAKEFILE=ON .
        cd $BUILD_FOLDER
        make -j$JOBS
        make -j$JOBS install
}

android_configure() {
        cp ${GR4A_SCRIPT_DIR}/android_configure.sh .
        echo "$CURRENT_BUILD - $(git rev-parse --short HEAD)" >> $BUILD_STATUS_FILE
        ./android_configure.sh $@
        make -j$JOBS LDFLAGS="$LDFLAGS"
        make -j$JOBS install

        LDFLAGS="$LDFLAGS_COMMON"
}

#############################################################
### BOOST
#############################################################

build_boost() {

## ADI COMMENT PULL LATEST

pushd ${GR4A_SCRIPT_DIR}/Boost-for-Android
git clean -xdf
export CURRENT_BUILD=boost-for-android

#./build-android.sh --boost=1.69.0 --toolchain=llvm --prefix=$(dirname ${PREFIX}) --arch=$ABI --target-version=28 ${ANDROID_NDK_ROOT}


#BOOST_VERSION=1.69.0
BOOST_VERSION=1.76.0

./build-android.sh --boost=$BOOST_VERSION --layout=system --toolchain=llvm --prefix=${PREFIX} --arch=$ABI --target-version=${API} ${ANDROID_NDK_ROOT}
popd
}

move_boost_libs() {
	cp -R $DEV_PREFIX/$ABI/* $DEV_PREFIX
}

#############################################################
### ZEROMQ
#############################################################

build_libzmq() {
pushd ${GR4A_SCRIPT_DIR}/libzmq
git clean -xdf
export CURRENT_BUILD=libzmq

./autogen.sh
cp ../android_configure.sh .
./android_configure.sh --enable-shared --disable-static --build=x86_64-unknown-linux-gnu --host=$TARGET_PREFIX$API --prefix=${PREFIX} LDFLAGS="-L${PREFIX}/lib" CPPFLAGS="-fPIC -I${PREFIX}/include"

make -j ${JOBS}
make install

# CXX Header-Only Bindings
wget -O $PREFIX/include/zmq.hpp https://raw.githubusercontent.com/zeromq/cppzmq/master/zmq.hpp
popd
}

#############################################################
### FFTW
#############################################################
build_fftw() {
## ADI COMMENT: USE downloaded version instead (OCAML fail?)
pushd ${GR4A_SCRIPT_DIR}/fftw
#wget http://www.fftw.org/fftw-3.3.9.tar.gz
# rm -rf fftw-3.3.9
# tar xvf fftw-3.3.9.tar.gz
git clean -xdf
export CURRENT_BUILD=fftw

if [ "$ABI" = "armeabi-v7a" ] || [ "$ABI" = "arm64-v8a" ]; then
	NEON_FLAG=--enable-neon
else
	NEON_FLAG=""
fi
echo $NEON_FLAG

cp ../android_configure.sh .
./android_configure.sh --enable-single --enable-static --enable-threads \
  --enable-float  $NEON_FLAG --disable-doc --disable-dependency-tracking --disable-fortran \
  --host=$TARGET_BINUTILS \
  --prefix=$PREFIX

make -j ${JOBS}
make install
popd
}

#############################################################
### OPENSSL
#############################################################
build_openssl() {
pushd ${GR4A_SCRIPT_DIR}/openssl
git clean -xdf
export CURRENT_BUILD=openssl

export ANDROID_NDK_HOME=${ANDROID_NDK_ROOT}

if [ $ABI = "arm64-v8a" ]; then
./Configure shared android-arm64 --prefix=${PREFIX} -D__ANDROID_API__=21
else
./Configure shared android-arm --prefix=${PREFIX} -D__ANDROID_API__=21
fi
make -j ${JOBS}
make install
popd
}

#############################################################
### THRIFT
#############################################################
build_thrift() {
pushd ${GR4A_SCRIPT_DIR}/thrift
git clean -xdf
export CURRENT_BUILD=thrift
rm -rf ${PREFIX}/include/thrift

./bootstrap.sh

# CPPFLAGS="-I${PREFIX}/include" \
# CFLAGS="-fPIC" \
# CXXFLAGS="-fPIC" \
# LDFLAGS="-L${PREFIX}/lib" \
cp ../android_configure.sh .
./android_configure.sh --prefix=${PREFIX}   --disable-tests --disable-tutorial --with-cpp \
 --without-python --without-kotlin --without-qt4 --without-qt5 --without-py3 --without-go --without-nodejs --without-c_glib --without-php --without-csharp --without-java \
 --without-libevent --without-zlib \
 --with-boost=${PREFIX} --host=$TARGET_BINUTILS --build=x86_64-linux

sed -i '/malloc rpl_malloc/d' ./lib/cpp/src/thrift/config.h
sed -i '/realloc rpl_realloc/d' ./lib/cpp/src/thrift/config.h

make -j ${JOBS}
make install

sed -i '/malloc rpl_malloc/d' ${PREFIX}/include/thrift/config.h
sed -i '/realloc rpl_realloc/d' ${PREFIX}/include/thrift/config.h
popd
}

#############################################################
### GMP
#############################################################
build_libgmp() {
pushd ${GR4A_SCRIPT_DIR}/libgmp
ABI_BACKUP=$ABI
ABI=""
git clean -xdf
export CURRENT_BUILD=libgmp

./.bootstrap
./configure --enable-maintainer-mode --prefix=${PREFIX} \
            --host=$TARGET_BINUTILS \
            --enable-cxx
make -j ${JOBS}
make install
ABI=$ABI_BACKUP
popd
}

#############################################################
### LIBUSB
#############################################################
build_libusb() {
pushd ${GR4A_SCRIPT_DIR}/libusb/android/jni
# WE NEED TO USE BetterAndroidSupport PR from libusb
# this will be merged to mainline soon
# https://github.com/libusb/libusb/pull/874

git clean -xdf
export CURRENT_BUILD=libusb

export NDK=${ANDROID_NDK_ROOT}
${NDK}/ndk-build clean
${NDK}/ndk-build -B -r -R

cp ${GR4A_SCRIPT_DIR}/libusb/android/libs/$ABI/* ${PREFIX}/lib
cp ${PREFIX}/lib/libusb1.0.so $PREFIX/lib/libusb-1.0.so # IDK why this happens (?)
cp ${GR4A_SCRIPT_DIR}/libusb/libusb/libusb.h ${PREFIX}/include
popd
}

build_python() {
	pushd $GR4A_SCRIPT_DIR/host-python

	# Python should be cross-built with the same version that is available on host, if nothing is available, it should be built with the script ./build_host_python
	git clean -xdf
	export CURRENT_BUILD=host-python
      #  autoupdate
	#autoreconf
	export PATH=${GR4A_SCRIPT_DIR}/build-python/bin:$PATH
	export LD_LIBRARY_PATH=$GR4A_SCRIPT_DIR/build-python/lib:$LD_LIBRARY_PATH
	cp ../android_configure.sh .
	ac_cv_file__dev_ptmx=no  \
	ac_cv_file__dev_ptc=no \
	./android_configure.sh  --build=x86_64-linux-gnu --disable-ipv6 --disable-test-modules --enable-shared

	#ac_cv_func_pipe2=no ac_cv_func_fdatasync=no ac_cv_func_killpg=no ac_cv_func_waitid=no ac_cv_func_sigaltstack=no 


	sed -i "s/^#zlib/zlib/g" Modules/Setup
	sed -i "s/^#math/math/g" Modules/Setup
	sed -i "s/^#time/time/g" Modules/Setup
	sed -i "s/^#_struct/_struct/g" Modules/Setup
	sed -i "s/^#_datetime/_datetime/g" Modules/Setup

	if [ $ABI == "arm64-v8a" ]; then
		LINTL=-lintl
	fi

#$LINTL -liconv 	
	#LDFLAGS="$LDFLAGS -lz -lm" 
	make -j$JOBS  #HOSTPYTHON=$GR4a/build-python/python CROSS_COMPILE=$TARGET_PREFIX CROSS_COMPILE_TARGET=yes HOSTARCH=$TARGET_PREFIX BUILDARCH=$TARGET_PREFIX 
	make install
 
#	rm -rf $DEV_PREFIX/lib/python$PYTHON_VERSION/test

	popd
}



#############################################################
### HACK RF
#############################################################
build_hackrf() {
pushd ${GR4A_SCRIPT_DIR}/hackrf/host/
git clean -xdf
export CURRENT_BUILD=hackrf

build_with_cmake --trace --trace-source=/home/adi/src/scopy-android-deps/gnuradio-android/hackrf/host/libhackrf/CMakeLists.txt ../

popd
}


build_qwt() {
	pushd $GR4A_SCRIPT_DIR/qwt
	git clean -xdf
	export CURRENT_BUILD=qwt

	echo $ANDROID_NDK_ROOT
	$QMAKE ANDROID_ABIS="$ABI" ANDROID_MIN_SDK_VERSION=$API ANDROID_API_VERSION=$API INCLUDEPATH=$DEV_PREFIX/include LIBS=-L$DEV_PREFIX/lib qwt.pro
	make -j$JOBS
	make -j$JOBS INSTALL_ROOT=$DEV_PREFIX install
	popd

}

move_qwt_libs (){
	cp -R $DEV_PREFIX/usr/local/* $DEV_PREFIX/
	cp -R $DEV_PREFIX/libs/$ABI/* $DEV_PREFIX/lib # another hack
	cp -R $QT_INSTALL_PREFIX/lib/libQt${QT_MAJOR_VERSION}PrintSupport*.so $DEV_PREFIX/lib
}

move_boost_libs() {
	cp -R $DEV_PREFIX/$ABI/* $DEV_PREFIX
}



build_spdlog() {
	pushd ${GR4A_SCRIPT_DIR}/spdlog
	git clean -xdf
	export CURRENT_BUILD=spdlog

	rm -rf build
	mkdir build
	cd build
	build_with_cmake  \
	-DSPDLOG_BUILD_SHARED=ON \
	../


	make -j ${JOBS}
	make install
	popd

}

build_libsndfile() {

	pushd ${GR4A_SCRIPT_DIR}/libsndfile
	git clean -xdf
	export CURRENT_BUILD=libsndfile

	rm -rf build
	mkdir build
	cd build

	echo "$LDFLAGS_COMMON"

	build_with_cmake ../
	make
	make install
        popd

}

build_pybind() {
        pushd ${GR4A_SCRIPT_DIR}/pybind11
        git clean -xdf
        export CURRENT_BUILD=pybind11

        build_with_cmake  -DPYBIND11_TEST=OFF ../
        make -j ${JOBS}
        make install
        popd
}

build_gnuradio3.10() {
	pushd ${GR4A_SCRIPT_DIR}/gnuradio
	git clean -xdf
	export CURRENT_BUILD=gnuradio

	rm -rf build
	mkdir build
	cd build

	echo "$LDFLAGS_COMMON"

        export LDFLAGS="$LDFLAGS_COMMON -lpython3"
	. ${GR4A_SCRIPT_DIR}/venv/bin/activate

	build_with_cmake  \
	  -DENABLE_INTERNAL_VOLK=OFF \
	  -DCMAKE_CROSSCOMPILING=ON\
	  -DBOOST_ROOT=${PREFIX} \
	  -DBoost_COMPILER=-clang \
	  -DBoost_USE_STATIC_LIBS=ON \
	  -DBoost_ARCHITECTURE=-a32 \
	  -DCMAKE_FIND_ROOT_PATH=${PREFIX} \
	  -DPYTHON_EXECUTABLE=${GR4A_SCRIPT_DIR}/venv/cross/bin/python3\
	  -DENABLE_DOXYGEN=OFF \
	  -DENABLE_DEFAULT=ON \
	  -DENABLE_GNURADIO_RUNTIME=ON \
          -DENABLE_GR_QTGUI=ON \
	  -DENABLE_GR_ANALOG=ON\
	  -DENABLE_GR_BLOCKS=ON\
	  -DENABLE_GR_FFT=ON\
	  -DENABLE_GR_FILTER=ON\
	  -DENABLE_GR_IIO=ON \
          -DENABLE_TESTING=OFF \
          -DENABLE_GR_AUDIO=OFF \
          -DENABLE_PYTHON=ON\
	  -DENABLE_GR_DIGITAL=ON\
	  -DENABLE_GR_CHANNELS=ON\
	  -DENABLE_GR_FEC=ON\
	  -DENABLE_GR_DTV=ON\
 	   ../ -Wno-dev
	  #-Dpybind11_DIR=${DEV_PREFIX}/lib/python$PYTHON_VERSION/site-packages/pybind11/share/cmake/pybind11\
#	cp -R ${DEV_PREFIX}/../venv/build/lib/* ${DEV_PREFIX}/lib
	popd
}

# #############################################################
# ### VOLK
#############################################################
build_volk() {
pushd ${GR4A_SCRIPT_DIR}/volk
git clean -xdf
export CURRENT_BUILD=volk

mkdir build
cd build
$CMAKE -DCMAKE_INSTALL_PREFIX=${PREFIX} \
  -DCMAKE_BUILD_TYPE=$BUILD_TYPE \
  -DCMAKE_TOOLCHAIN_FILE=${ANDROID_NDK_ROOT}/build/cmake/android.toolchain.cmake \
  -DANDROID_ABI=$ABI -DANDROID_ARM_NEON=ON \
  -DANDROID_STL=c++_shared \
  -DANDROID_NATIVE_API_LEVEL=${API} \
  -DPYTHON_EXECUTABLE=${GR4A_SCRIPT_DIR}/venv/cross/bin/python3\
  -DBOOST_ROOT=${PREFIX} \
  -DBoost_COMPILER=-clang \
  -DBoost_USE_STATIC_LIBS=ON \
  -DBoost_ARCHITECTURE=-a32 \
  -DENABLE_STATIC_LIBS=False \
  -DCMAKE_FIND_ROOT_PATH=${PREFIX} \
  -DCMAKE_EXE_LINKER_FLAGS="$LDFLAGS_COMMON" \
  -DCMAKE_VERBOSE_MAKEFILE=ON \
  ../
make -j ${JOBS}
make install
popd
}

build_libm2k() {
	pushd $GR4A_SCRIPT_DIR/libm2k
	git clean -xdf
	export CURRENT_BUILD=libm2k

	build_with_cmake -DENABLE_PYTHON=OFF -DENABLE_TOOLS=ON

	popd
}

build_gr-m2k() {
	pushd $GR4A_SCRIPT_DIR/gr-m2k
	git clean -xdf
	export CURRENT_BUILD=gr-m2k

	build_with_cmake -DWITH_PYTHON=ON -DPYTHON_EXECUTABLE=${GR4A_SCRIPT_DIR}/venv/cross/bin/python3 -DGnuradio_DIR=$DEV_PREFIX/lib/cmake/gnuradio

	popd
}


#############################################################
### GR OSMOSDR
#############################################################
build_gr-osmosdr() {
pushd ${GR4A_SCRIPT_DIR}/gr-osmosdr
git clean -xdf
export CURRENT_BUILD=gr-osmosdr

mkdir build
cd build

$CMAKE -DCMAKE_INSTALL_PREFIX=${PREFIX} \
  -DCMAKE_BUILD_TYPE=$BUILD_TYPE \
  -DCMAKE_TOOLCHAIN_FILE=${ANDROID_NDK_ROOT}/build/cmake/android.toolchain.cmake \
  -DANDROID_ABI=$ABI -DANDROID_ARM_NEON=ON \
  -DANDROID_NATIVE_API_LEVEL=${API} \
  -DBOOST_ROOT=${PREFIX} \
  -DANDROID_STL=c++_shared \
  -DBoost_COMPILER=-clang \
  -DBoost_USE_STATIC_LIBS=ON \
  -DBoost_ARCHITECTURE=-a32 \
  -DGnuradio_DIR=${GR4A_SCRIPT_DIR}/toolchain/$ABI/lib/cmake/gnuradio \
  -DENABLE_REDPITAYA=OFF \
  -DENABLE_RFSPACE=OFF \
  -DCMAKE_FIND_ROOT_PATH=${PREFIX} \
  ../
make -j ${JOBS}
make install
popd
}

#############################################################
### GR GRAND
#############################################################
build_gr-grand() {
pushd ${GR4A_SCRIPT_DIR}/gr-grand
git clean -xdf
export CURRENT_BUILD=gr-grand

mkdir build
cd build

$CMAKE -DCMAKE_INSTALL_PREFIX=${PREFIX} \
  -DCMAKE_BUILD_TYPE=$BUILD_TYPE \
  -DCMAKE_TOOLCHAIN_FILE=${ANDROID_NDK_ROOT}/build/cmake/android.toolchain.cmake \
  -DANDROID_ABI=$ABI -DANDROID_ARM_NEON=ON \
  -DANDROID_NATIVE_API_LEVEL=${API} \
  -DANDROID_STL=c++_shared \
  -DBOOST_ROOT=${PREFIX} \
  -DBoost_COMPILER=-clang \
  -DBoost_USE_STATIC_LIBS=ON \
  -DBoost_ARCHITECTURE=-a32 \
  -DPYTHON_EXECUTABLE=${GR4A_SCRIPT_DIR}/venv/cross/bin/python3\
  -DGnuradio_DIR=${GR4A_SCRIPT_DIR}/toolchain/$ABI/lib/cmake/gnuradio \
  -DCMAKE_FIND_ROOT_PATH=${PREFIX} \
  -DCMAKE_VERBOSE_MAKEFILE=ON \
    ../
  #-Dpybind11_DIR=${DEV_PREFIX}/lib/python$PYTHON_VERSION/site-packages/pybind11/share/cmake/pybind11\

make -j ${JOBS}
make install
popd
}

#############################################################
### GR SCHED
#############################################################
build_gr-sched() {
pushd ${GR4A_SCRIPT_DIR}/gr-sched
git clean -xdf
export CURRENT_BUILD=gr-sched

mkdir build
cd build

$CMAKE -DCMAKE_INSTALL_PREFIX=${PREFIX} \
  -DCMAKE_BUILD_TYPE=$BUILD_TYPE \
  -DCMAKE_TOOLCHAIN_FILE=${ANDROID_NDK_ROOT}/build/cmake/android.toolchain.cmake \
  -DANDROID_ABI=$ABI -DANDROID_ARM_NEON=ON \
  -DANDROID_STL=c++_shared \
  -DANDROID_NATIVE_API_LEVEL=${API} \
  -DBOOST_ROOT=${PREFIX} \
  -DBoost_COMPILER=-clang \
  -DBoost_USE_STATIC_LIBS=ON \
  -DBoost_ARCHITECTURE=-a32 \
  -DGnuradio_DIR=${GR4A_SCRIPT_DIR}/toolchain/$ABI/lib/cmake/gnuradio \
  -DCMAKE_FIND_ROOT_PATH=${PREFIX} \
  ../

make -j ${JOBS}
make install
popd
}


#############################################################
### LIBXML2
#############################################################
build_libxml2 () {
        pushd ${GR4A_SCRIPT_DIR}/libxml2
        git clean -xdf
        export CURRENT_BUILD=libxml2

	build_with_cmake -DLIBXML2_WITH_LZMA=OFF -DLIBXML2_WITH_PYTHON=OFF -DLIBXML2_WITH_TESTS=OFF -DLIBXML2_WITH_ZLIB=OFF

        popd
}

#############################################################
### LIBIIO
#############################################################
build_libiio () {
        pushd ${GR4A_SCRIPT_DIR}/libiio
        git clean -xdf
        export CURRENT_BUILD=libiio

	build_with_cmake -DHAVE_DNS_SD=OFF

        popd
}

#############################################################
### LIBAD9361
#############################################################
build_libad9361 () {
        pushd ${GR4A_SCRIPT_DIR}/libad9361-iio
        git clean -xdf
        export CURRENT_BUILD=libad9361-iio

	build_with_cmake

        popd
}

#############################################################
### LIBICONV
#############################################################
build_libiconv () {

        pushd ${GR4A_SCRIPT_DIR}/libiconv
	git clean -xdf
        export CURRENT_BUILD=libiconv

        LDFLAGS="$LDFLAGS_COMMON"
        android_configure --enable-static=no --enable-shared=yes

        popd
}

#############################################################
### LIBFFI
#############################################################
build_libffi() {
        pushd ${GR4A_SCRIPT_DIR}/libffi
        git clean -xdf
        export CURRENT_BUILD=libffi

#        ./autogen.sh
        LDFLAGS="$LDFLAGS_COMMON"
        android_configure --disable-docs --cache-file=android.cache --disable-multi-os-directory

        popd
}


#############################################################
### GETTEXT
#############################################################
build_gettext() {
        pushd ${GR4A_SCRIPT_DIR}/gettext
        git clean -xdf
        export CURRENT_BUILD=gettext

        export LDFLAGS="$LDFLAGS_COMMON"
	#NOCONFIGURE=yes ./autogen.sh
	#aclocal
        #autoreconf
        android_configure --disable-c++ --disable-java --disable-dependency-tracking --disable-curses
        popd
}

#############################################################
### UHD
#############################################################
build_uhd() {
cd ${GR4A_SCRIPT_DIR}/uhd/host
git clean -xdf
export CURRENT_BUILD=uhd

mkdir build
cd build
cmake -DCMAKE_INSTALL_PREFIX=${PREFIX} \
  -DCMAKE_TOOLCHAIN_FILE=${ANDROID_NDK_ROOT}/build/cmake/android.toolchain.cmake \
  -DANDROID_ABI=arm64-v8a -DANDROID_ARM_NEON=ON \
  -DANDROID_NATIVE_API_LEVEL=${API} \
  -DANDROID_STL=c++_shared \
  -DBOOST_ROOT=${PREFIX} \
  -DBoost_DEBUG=OFF \
  -DBoost_COMPILER=-clang \
  -DBoost_USE_STATIC_LIBS=ON \
  -DBoost_USE_DEBUG_LIBS=OFF \
  -DBoost_ARCHITECTURE=-a64 \
  -DENABLE_STATIC_LIBS=OFF \
  -DENABLE_EXAMPLES=OFF \
  -DENABLE_TESTS=OFF \
  -DENABLE_UTILS=OFF \
  -DENABLE_PYTHON_API=OFF \
  -DENABLE_MANUAL=OFF \
  -DENABLE_DOXYGEN=OFF \
  -DENABLE_MAN_PAGES=OFF \
  -DENABLE_OCTOCLOCK=OFF \
  -DENABLE_E300=OFF \
  -DENABLE_E320=OFF \
  -DENABLE_N300=OFF \
  -DENABLE_N320=OFF \
  -DENABLE_X300=OFF \
  -DENABLE_USRP2=OFF \
  -DENABLE_N230=OFF \
  -DENABLE_MPMD=OFF \
  -DENABLE_B100=OFF \
  -DENABLE_USRP1=OFF \
  -DCMAKE_FIND_ROOT_PATH=${PREFIX} \
  ../
make -j ${NCORES}
make install
}

#############################################################
### RTL SDR
#############################################################
build_rtl-sdr() {
cd ${GR4A_SCRIPT_DIR}/rtl-sdr
git clean -xdf
export CURRENT_BUILD=rtl-sdr
build_with_cmake -DDETACH_KERNEL_DRIVER=ON ../

make -j ${NCORES}
make install
}


#############################################################
### GR IEEE 802.15.4
#############################################################
build_gr-ieee-802-15-4() {
cd ${GR4A_SCRIPT_DIR}/gr-ieee802-15-4
git clean -xdf
export CURRENT_BUILD=gr-ieee-802-15-4

mkdir build
cd build

cmake -DCMAKE_INSTALL_PREFIX=${PREFIX} \
  -DCMAKE_TOOLCHAIN_FILE=${ANDROID_NDK_ROOT}/build/cmake/android.toolchain.cmake \
  -DANDROID_ABI=arm64-v8a -DANDROID_ARM_NEON=ON \
  -DANDROID_NATIVE_API_LEVEL=${API_LEVEL} \
  -DANDROID_STL=c++_shared \
  -DBOOST_ROOT=${PREFIX} \
  -DBoost_DEBUG=OFF \
  -DBoost_COMPILER=-clang \
  -DBoost_USE_STATIC_LIBS=ON \
  -DBoost_USE_DEBUG_LIBS=OFF \
  -DBoost_ARCHITECTURE=-a64 \
  -DGnuradio_DIR=${GR4A_SCRIPT_DIR}/toolchain/arm64-v8a/lib/cmake/gnuradio \
  -DCMAKE_FIND_ROOT_PATH=${PREFIX} \
  ../

make -j ${NCORES}
make install
}

#############################################################
### GR IEEE 802.11
#############################################################
build_gr-ieee-802-11() {
cd ${GR4A_SCRIPT_DIR}/gr-ieee802-11
git clean -xdf
export CURRENT_BUILD=gr-ieee802-11

mkdir build
cd build

cmake -DCMAKE_INSTALL_PREFIX=${PREFIX} \
  -DCMAKE_TOOLCHAIN_FILE=${ANDROID_NDK_ROOT}/build/cmake/android.toolchain.cmake \
  -DANDROID_ABI=arm64-v8a -DANDROID_ARM_NEON=ON \
  -DANDROID_NATIVE_API_LEVEL=${API_LEVEL} \
  -DANDROID_STL=c++_shared \
  -DBOOST_ROOT=${PREFIX} \
  -DBoost_DEBUG=OFF \
  -DBoost_COMPILER=-clang \
  -DBoost_USE_STATIC_LIBS=ON \
  -DBoost_USE_DEBUG_LIBS=OFF \
  -DBoost_ARCHITECTURE=-a64 \
  -DGnuradio_DIR=${GR4A_SCRIPT_DIR}/toolchain/arm64-v8a/lib/cmake/gnuradio \
  -DCMAKE_FIND_ROOT_PATH=${PREFIX} \
  ../

make -j ${NCORES}
make install
}

# #############################################################
# ### GR CLENABLED
# #############################################################
build_gr-clenabled() {
 cd ${GR4A_SCRIPT_DIR}/gr-clenabled
 git clean -xdf
 export CURRENT_BUILD=gr-clenabled

 mkdir build
 cd build

 cmake -DCMAKE_INSTALL_PREFIX=${PREFIX} \
   -DCMAKE_TOOLCHAIN_FILE=${ANDROID_NDK_ROOT}/build/cmake/android.toolchain.cmake \
   -DANDROID_ABI=arm64-v8a -DANDROID_ARM_NEON=ON \
   -DANDROID_NATIVE_API_LEVEL=${API_LEVEL} \
   -DANDROID_STL=c++_shared \
   -DBOOST_ROOT=${PREFIX} \
   -DBoost_DEBUG=OFF \
   -DBoost_COMPILER=-clang \
   -DBoost_USE_STATIC_LIBS=ON \
   -DBoost_USE_DEBUG_LIBS=OFF \
   -DBoost_ARCHITECTURE=-a64 \
   -DGnuradio_DIR=${GR4A_SCRIPT_DIR}/toolchain/arm64-v8a/lib/cmake/gnuradio \
   -DCMAKE_FIND_ROOT_PATH=${PREFIX} \
   ../

 make -j ${NCORES}
 make install


}

build_libsigrokdecode() {
        pushd $GR4A_SCRIPT_DIR/libsigrokdecode
        git clean -xdf
        export CURRENT_BUILD=libsigrokdecode

        export PATH=${GR4A_SCRIPT_DIR}/build-python/bin:$PATH
	export LD_LIBRARY_PATH=$GR4A_SCRIPT_DIR/build-python/lib:$LD_LIBRARY_PATH
	
	NOCONFIGURE=yes ./autogen.sh
        android_configure

        popd
}

build_glib() {
        pushd $GR4A_SCRIPT_DIR/glib
        git clean -xdf
        export CURRENT_BUILD=glib

        #CPPFLAGS=/path/to/standalone/include LDFLAGS=/path/to/standalone/lib ./configure \
        #--prefix=/path/to/standalone --bindir=$AS_BIN --build=i686-pc-linux-gnu --host=arm-linux-androideabi \
        #--cache-file=android.cache

echo "glib_cv_stack_grows=no
glib_cv_uscore=no
ac_cv_func_posix_getpwuid_r=no
ac_cv_func_posix_getgrgid_r=no " > android.cache

        NOCONFIGURE=yes ./autogen.sh

        LDFLAGS="$LDFLAGS_COMMON -lffi -lz"
        android_configure --cache-file=android.cache --with-libiconv=gnu --disable-dtrace --disable-xattr --disable-systemtap --with-pcre=internal --enable-libmount=no

        popd
}



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

test() {
echo This works
}

second_stage() {
build_qwt
move_qwt_libs
build_boost
move_boost_libs
build_libzmq
build_fftw
#build_thrift
build_libgmp
build_libusb
build_libiio
build_libad9361
build_libm2k
#build_hackrf
#build_uhd
#build_rtl-sdr
build_spdlog
build_libsndfile
build_volk
build_pybind
build_gnuradio3.10
build_gr-m2k
#build_gr-osmosdr
build_gr-grand 
# build_gr-sched
# build_gr-ieee-802-15-4
# build_gr-ieee-802-11
# build_gr-clenabled
}

$@


