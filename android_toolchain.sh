#!/bin/bash

source ./build_system_setup.sh $ARCH

# Non-exhaustive lists of compiler + binutils
# Depending on what you compile, you might need more binutils than that
#export CC=$TOOLCHAIN/bin/clang
export SYSROOT=$TOOLCHAIN/sysroot
export CC=$TOOLCHAIN/bin/$TARGET$API-clang
export CXX=$TOOLCHAIN/bin/$TARGET$API-clang++
export CPP="$CC -E"
export AR=$TOOLCHAIN/bin/llvm-ar
export AS=${CC}
export NM=$TOOLCHAIN/bin/llvm-nm
export STRIP=$TOOLCHAIN/bin/llvm-strip
export READELF=$TOOLCHAIN/bin/llvm-readelf
export LD=$TOOLCHAIN/bin/ld.lld
export RANLIB=$TOOLCHAIN/bin/llvm-ranlib
export STRIPLINK=$TOOLCHAIN/bin/${TARGET_BINUTILS}-strip
export LDD=$TOOLCHAIN/bin/llvm-ldd

export CFLAGS="-I${SYSROOT}/include -I${SYSROOT}/usr/include -I${TOOLCHAIN}/include -I${DEV_PREFIX}/include -fPIC"
export STAGING_DIR=${DEV_PREFIX}
export CPPFLAGS="-fexceptions -frtti ${CFLAGS} "
export LDFLAGS_COMMON="-L${SYSROOT}/usr/lib/$TARGET_BINUTILS/$API -L${TOOLCHAIN}/lib -L${DEV_PREFIX} -L${DEV_PREFIX}/lib"
export LDFLAGS="$LDFLAGS_COMMON"
# Don't mix up .pc files from your host and build target
export PKG_CONFIG_PATH=${DEV_PREFIX}/lib/pkgconfig
export PATH=$QT_INSTALL_PREFIX/bin:$PATH



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

