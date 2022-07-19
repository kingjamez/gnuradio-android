#!/bin/bash

############### SYSTEM SPECIFIC DEFINES ############
export USER_DIR=$1
export ANDROID_SDK_ROOT=$HOME/Android/Sdk
export CMAKE=$HOME/cmake-3.23.2-linux-x86_64/bin/cmake
export QT_VERSION_STRING=5.15.2
export QT_HOME=$HOME/Qt
export QT_INSTALL_PREFIX_NO_POSTFIX=${QT_HOME}/${QT_VERSION_STRING}/android
export JDK=$HOME/jdk-14
export JAVA_HOME=$JDK
export PATH=$JAVA_HOME/bin:$PATH
export PYTHON_VERSION=3.8.10
export GR4A_SCRIPT_DIR=$HOME/src/gnuradio-android
export DEPS_SRC_PATH=$GR4A_SCRIPT_DIR/downloads
#export BUILD_TYPE=Release
export BUILD_TYPE=Debug
#export BUILD_TYPE=RelWithDebInfo
export NDK_VERSION=23.1.7779620
#export NDK_VERSION=21.3.6528147
export API=26 # need ABI at least 28 for glob from my tests
export JOBS=16
export HOST_ARCH=linux-x86_64
export ANDROID_SDK_BUILD_TOOLS=30.0.2
export ANDROID_NDK_ROOT=$ANDROID_SDK_ROOT/ndk/$NDK_VERSION
