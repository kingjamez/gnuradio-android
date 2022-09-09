#!/bin/bash
set -xe
source ./android_toolchain.sh $ARCH

install_android_sdk() {
	pushd $GR4A_SCRIPT_DIR/download
	wget https://dl.google.com/android/repository/commandlinetools-linux-6200805_latest.zip

	unzip commandlinetools-linux-6200805_latest.zip -d $ANDROID_SDK_ROOT

	yes | ./sdkmanager --sdk_root=${ANDROID_SDK_ROOT} --licenses
	./sdkmanager --sdk_root=${ANDROID_SDK_ROOT} "platforms;android-26"
	./sdkmanager --sdk_root=${ANDROID_SDK_ROOT} "platforms;android-28"
	./sdkmanager --sdk_root=${ANDROID_SDK_ROOT} "ndk;21.3.6528147"
	./sdkmanager --sdk_root=${ANDROID_SDK_ROOT} "ndk;23.1.7779620"
	./sdkmanager --sdk_root=${ANDROID_SDK_ROOT} "platform-tools"
	./sdkmanager --sdk_root=${ANDROID_SDK_ROOT} "build-tools;28.0.3"
	./sdkmanager --sdk_root=${ANDROID_SDK_ROOT} "build-tools;30.0.3"
	./sdkmanager --sdk_root=${ANDROID_SDK_ROOT} "cmdline-tools;latest"
}

install_qt() {
	apt-get install python3-pip
	pip3 install aqtinstall
	python3 -m aqt install-qt linux android 5.15.2 --outputdir $QT_HOME
	python3 -m aqt install-qt linux desktop 5.15.2 --outputdir $QT_HOME
}

install_cmake() {
	pushd $HOME
	tar xvf $GR4A_SCRIPT_DIR/cmake-3.23.2-linux-x86_64.tar.gz
	popd
}

rm_libs() {
        pushd $ANDROID_SDK_ROOT/ndk/$NDK_VERSION/toolchains/llvm/prebuilt/linux-x86_64/sysroot/usr/lib/x86_64-linux-android
        rm -f *.so

        if [ $ABI = "armeabi-v7a" ]; then
                find . ! -name 'libunwind.a' -type f -exec rm -f {} +
        else
                rm -f *.a
        fi
	popd
}
create_strip_symlink() {
#needed in NDK r23
#NDK r23 gradle uses wrong binary for stripping so we create a symlink to workaround it
rm -rf $STRIPLINK
ln -s $STRIP $STRIPLINK
}

recurse_submodules() {
pushd $GR4A_SCRIPT_DIR
git submodule update --init --recursive --jobs $JOBS

popd
}

download_deps() {
	pushd $GR4A_SCRIPT_DIR
	mkdir -p download
	wget https://files.pythonhosted.org/packages/28/6c/640e3f5c734c296a7193079a86842a789edb7988dca39eab44579088a1d1/PyQt5-5.15.2.tar.gz
	wget https://github.com/Kitware/CMake/releases/download/v3.23.2/cmake-3.23.2-linux-x86_64.tar.gz
	wget https://download.java.net/openjdk/jdk14/ri/openjdk-14+36_linux-x64_bin.tar.gz
	popd
}

install_jdk() {
	cd $HOME
#	we're using gradle 6.3 so we need to use jdk 14 at most
#	https://docs.gradle.org/current/userguide/compatibility.html

	tar xvf $GR4A_SCRIPT_DIR/download/openjdk-14+36_linux-x64_bin.tar.gz
}

rename_gradle() {
	echo "Patching to use gradle-6.3"

	pushd $QT_INSTALL_PREFIX/src/3rdparty/gradle/gradle/wrapper
	sed -i "s|https\\\:\/\/services\.gradle\.org\/distributions\/gradle.*\.zip|https\://services.gradle.org/distributions/gradle-6.3-all.zip|g" gradle-wrapper.properties
	popd
}

patch_sdk_build_tools_revision() {
	echo "Patching qt android to support sdkBuildToolsRevision"
	# https://bugreports.qt.io/browse/QTBUG-84302

	pushd $QT_INSTALL_PREFIX/lib/cmake/Qt5Core/
	cp Qt5AndroidSupport.cmake Qt5AndroidSupport.cmake.backup
	sed '59 a "sdkBuildToolsRevision": "@ANDROID_SDK_BUILD_TOOLS_REVISION@",' Qt5AndroidSupport.cmake.backup  > Qt5AndroidSupport.cmake
	rm -rf Qt5AndroidSupport.cmake.backup
	popd
}

#download_deps

#install_android_sdk
#install_qt
#install_cmake

#rename_gradle
#patch_sdk_build_tools_revision
#recurse_submodules
#install_jdk
#rm_libs
#create_strip_symlink
$@
