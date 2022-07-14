#!/bin/bash

source ./build_system_setup.sh $2

export APP_PLATFORM=${API}
#export JOBS=$(getconf _NPROCESSORS_ONLN)

if [ $# -lt 1 ]; then
	ARG1=aarch64
else
	ARG1=$1
fi

TARGET_PREFIX=NO_ABI
export QT_INSTALL_PREFIX=${QT_INSTALL_PREFIX_NO_POSTFIX}


if [ $ARG1 = "aarch64" ]; then
############ aarch64 #########
export ABI=arm64-v8a
export ABI_BITS=64
export TARGET_PREFIX=aarch64-linux-android
export TARGET_BINUTILS=aarch64-linux-android
export QT_MAJOR_VERSION=${QT_VERSION_STRING:0:1}
if [ ${QT_MAJOR_VERSION} -eq 6 ]; then
	export QT_INSTALL_PREFIX=${QT_INSTALL_PREFIX}_arm64_v8a
	export CMAKE_TOOLCHAIN_FILE=$QT_INSTALL_PREFIX/lib/cmake/Qt${QT_MAJOR_VERSION}/qt.toolchain.cmake
else
	export CMAKE_TOOLCHAIN_FILE=$ANDROID_NDK_ROOT/build/cmake/android.toolchain.cmake

fi
#############################
fi

if [ $ARG1 = "arm" ]; then
############# armv7a ##########
export ABI=armeabi-v7a
export ABI_BITS=32
export TARGET_PREFIX=armv7a-linux-androideabi
export TARGET_BINUTILS=arm-linux-androideabi
if [ ${QT_MAJOR_VERSION} -eq 6 ]; then
	export QT_INSTALL_PREFIX=${QT_INSTALL_PREFIX}_armv7
	export CMAKE_TOOLCHAIN_FILE=$QT_INSTALL_PREFIX/lib/cmake/Qt${QT_MAJOR_VERSION}/qt.toolchain.cmake
else
	export CMAKE_TOOLCHAIN_FILE=$ANDROID_NDK_ROOT/build/cmake/android.toolchain.cmake

fi
###############################
fi

if [ $ARG1 = "x86_64" ]; then
############# x86_64 ###########
export TARGET_BINUTILS=x86_64-linux-android
export ABI=x86_64
export TARGET_PREFIX=x86_64-linux-android
if [ ${QT_MAJOR_VERSION}  -eq 6 ]; then
	export QT_INSTALL_PREFIX=${QT_INSTALL_PREFIX}_x86_64
	export CMAKE_TOOLCHAIN_FILE=$QT_INSTALL_PREFIX/lib/cmake/Qt6/qt.toolchain.cmake
else
	export CMAKE_TOOLCHAIN_FILE=$ANDROID_NDK_ROOT/build/cmake/android.toolchain.cmake

fi
#################################
fi

if [ $ARG1 = "x86" ]; then
######## x86 - i686 ############
export TARGET_PREFIX=i686-linux-android
export ABI=x86
export TARGET_BINUTILS=i686-linux-android
if [ ${QT_MAJOR_VERSION}  -eq 6 ]; then
	export QT_INSTALL_PREFIX=${QT_INSTALL_PREFIX}_x86
	export CMAKE_TOOLCHAIN_FILE=$QT_INSTALL_PREFIX/lib/cmake/Qt6/qt.toolchain.cmake
else
	export CMAKE_TOOLCHAIN_FILE=$ANDROID_NDK_ROOT/build/cmake/android.toolchain.cmake

fi
#################################
fi

export BUILDDIR=build_${TARGET_PREFIX}_api${API}_ndk${NDK_VERSION:0:2}_${BUILD_TYPE}
export WORKDIR=$GR4A_SCRIPT_DIR/$BUILDDIR

# This is just an empty directory where I want the built objects to be installed
export DEV_PREFIX=$WORKDIR/out
export TOOLCHAIN=${ANDROID_NDK_ROOT}/toolchains/llvm/prebuilt/$HOST_ARCH
export TOOLCHAIN_BIN=${ANDROID_NDK_ROOT}/toolchains/llvm/prebuilt/${HOST_ARCH}/bin
export QMAKE=$QT_INSTALL_PREFIX/bin/qmake
export ANDROID_QT_DEPLOY=$QT_INSTALL_PREFIX/bin/androiddeployqt
export BUILD_STATUS_FILE=$WORKDIR/build-status


# Non-exhaustive lists of compiler + binutils
# Depending on what you compile, you might need more binutils than that
#export CC=$TOOLCHAIN/bin/clang
export SYSROOT=$TOOLCHAIN/sysroot
export CC=$TOOLCHAIN/bin/$TARGET_PREFIX$API-clang
export CXX=$TOOLCHAIN/bin/$TARGET_PREFIX$API-clang++
export CPP="$CC -E"
export AR=$TOOLCHAIN/bin/llvm-ar
export AS=${CC}
export NM=$TOOLCHAIN/bin/llvm-nm
export STRIP=$TOOLCHAIN/bin/llvm-strip
export READELF=$TOOLCHAIN/bin/llvm-readelf
export LD=$TOOLCHAIN/bin/ld.lld
export RANLIB=$TOOLCHAIN/bin/llvm-ranlib
export STRIPLINK=$TOOLCHAIN/bin/${TARGET_BINUTILS}-strip

export CFLAGS="-I${SYSROOT}/include -I${SYSROOT}/usr/include -I${TOOLCHAIN}/include -I${DEV_PREFIX}/include -fPIC"
export STAGING_DIR=${DEV_PREFIX}
export CPPFLAGS="-fexceptions -frtti ${CFLAGS} "
export LDFLAGS_COMMON="-L${SYSROOT}/usr/lib/$TARGET_BINUTILS/$API -L${TOOLCHAIN}/lib -L${DEV_PREFIX} -L${DEV_PREFIX}/lib"
export LDFLAGS="$LDFLAGS_COMMON"
# Don't mix up .pc files from your host and build target
export PKG_CONFIG_PATH=${DEV_PREFIX}/lib/pkgconfig
export PATH=$QT_INSTALL_PREFIX/bin:$PATH

#deinit_toolchain() {
#export CC=""
#export CXX=""
#export CPP=""
#export AR=""
#export AS=""
#export NM=""
#export STRIP=""
#export READELF=""
#export LD=""
#export RANLIB=""
#export STRIPLINK=""
#export CFLAGS=""
#export CPP_FLAGS=""
#export LDFLAGS=""
#export SYSROOT=""
#export PKG_CONFIG_PATH=""
#}


echo ANDROID_SDK_ROOT=$ANDROID_SDK_ROOT
echo ANDORID_NDK_ROOT=$ANDROID_NDK_ROOT
echo CMAKE=$CMAKE
echo QT_INSTALL_PREFIX=${QT_INSTALL_PREFIX}
echo JDK=$JDK
echo NDK_VERSION=$NDK_VERSION
echo JOBS=$JOBS
echo GR4A_SCRIPT_DIR=$GR4A_SCRIPT_DIR
#echo
echo $TARGET_PREFIX$API
#if [ $TARGET_PREFIX = "NO_ABI" ]; then
#	exit 22 # Invalid argument
#fi

