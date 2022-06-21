#!/bin/bash

############### SYSTEM SPECIFIC DEFINES ############
export USER_DIR=$1
export ANDROID_SDK_ROOT=$HOME/Android/Sdk
export CMAKE=$HOME/Qt/Tools/CMake/bin/cmake
export QT_VERSION_STRING=5.15.2
export QT_INSTALL_PREFIX_NO_POSTFIX=$HOME/Qt/$QT_VERSION_STRING/android
export JDK=$HOME/jdk-14
export JAVA_HOME=$JDK
export PATH=$JAVA_HOME/bin:$PATH
export PYTHON_VERSION=3.8.10
export GR4A_SCRIPT_DIR=$HOME/src/scopy-android-deps/gnuradio-android
export DEPS_SRC_PATH=$GR4A_SCRIPT_DIR/downloads
#export BUILD_TYPE=Release
export BUILD_TYPE=Debug
#export BUILD_TYPE=RelWithDebInfo
