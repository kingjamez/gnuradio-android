source build_system_setup.sh

build_python() {
	pushd build-python-src
	./configure --disable-ipv6 --enable-optimizations --with-ensurepip=install --enable-shared --prefix="$GR4A_SCRIPT_DIR/build-python"
	make -j $JOBS
	make install
	popd
}

install_pip_deps() {
	pushd $GR4A_SCRIPT_DIR
	pip install crossenv
	./build-python/bin/python3 -m crossenv ./build_aarch64-linux-android_api26_ndk23_Debug/out/bin/python3.8 venv
	. $GR4A_SCRIPT_DIR/venv/bin/activate
	build-pip install setuptools --upgrade
	build-pip install numpy==1.21.2
	cross-pip install numpy==1.21.2 
	build-pip install sip
	cross-pip install sip
	build-pip install pyqt-builder
	cross-pip install pyqt-builder #need this ?
	
	# cp venv/build/bin/sip-build venv/cross/bin/sip-build
	# patch sip-build -- change shebang from build to cross

	cp -R $GR4A_SCRIPT_DIR/venv/cross/lib/* $DEV_PREFIX/lib/
	popd
}

build_pyqt5() {
	pushd $GR4A_SCRIPT_DIR/PyQt5-5.15.2
	/home/adi/src/gnuradio-android/venv/cross/bin/sip-build --confirm-license --jobs $JOBS --no-tools --no-dbus-python --no-qml-plugin --no-designer-plugin --target-dir ${DEV_PREFIX}/lib/python3.8 --build-dir ./build --qmake=$QMAKE --qmake-setting ANDROID_ABIS=arm64-v8a --qmake-setting QMAKE_LFLAGS="-L$DEV_PREFIX/lib -lpython3.8" --verbose
	cd build
	make install
	popd
}


install_deps() {

	sudo apt-get install build-essential zlib1g-dev libbz2-dev liblzma-dev libncurses5-dev libreadline6-dev libsqlite3-dev libssl-dev libgdbm-dev liblzma-dev tk8.6-dev lzma lzma-dev libgdbm-dev
	tar xvf PyQt5-5.15.2.tar.gz
}

#install_deps
build_python
