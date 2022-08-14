source build_system_setup.sh

build_python() {
	pushd build-python-src
	./configure --disable-ipv6 --enable-optimizations --with-ensurepip=install --enable-shared --prefix="$GR4A_SCRIPT_DIR/build-python"
	make -j $JOBS
	make install
	ln -s $GR4A_SCRIPT_DIR/build-python/bin/pip3 $GR4A_SCRIPT_DIR/build-python/bin/pip
	popd
}

create_venv() {
	pushd $GR4A_SCRIPT_DIR

	export PATH=${GR4A_SCRIPT_DIR}/build-python/bin:$PATH
	export LD_LIBRARY_PATH=$GR4A_SCRIPT_DIR/build-python/lib:$LD_LIBRARY_PATH
	
	./build-python/bin/pip3 install crossenv

	if [ -d venv ]; then
		return 0;
	fi

	./build-python/bin/python3 -m crossenv $DEV_PREFIX/bin/python3.10 venv
	. $GR4A_SCRIPT_DIR/venv/bin/activate
	build-pip install setuptools --upgrade
	build-pip install numpy==1.21.2
	cross-pip install numpy==1.21.2 
	build-pip install sip
	cross-pip install sip
	build-pip install pyqt-builder
	cross-pip install pyqt-builder #need this ?
	
	cp venv/build/bin/sip-* venv/cross/bin/
	sed -i '0,/build/s/build/cross/' venv/cross/bin/sip-*
	#patch sip-build -- change shebang from build to cross

	popd
}

build_pyqt5() {
	pushd $GR4A_SCRIPT_DIR
	source android_toolchain.sh	
	popd
	pushd $GR4A_SCRIPT_DIR/PyQt5-5.15.7
	ANDROID_NDK_PLATFORM=android-30\
		/home/adi/src/gnuradio-android/venv/cross/bin/sip-build\
	       	--confirm-license\
	       	--jobs $JOBS\
	       	--no-tools\
	       	--no-dbus-python --no-qml-plugin\
	       	--no-designer-plugin\
	       	--target-dir ${DEV_PREFIX}/lib/python3.8\
	       	--build-dir ./build\
	       	--qmake=$QMAKE\
		--qmake-setting ANDROID_NDK_PLATFORM=android-30\
		--qmake-setting ANDROID_PLATFORM=android-30\
	       	--qmake-setting ANDROID_ABIS=arm64-v8a\
	       	--qmake-setting QMAKE_LFLAGS="-L$DEV_PREFIX/lib -lpython3.10"\
	       	--verbose\
	       	--no-make\
	       	--qt-shared\
	       	--android-abi arm64-v8a\
		--protected-is-public\
		--enable Qt\
	       	--enable QtCore \
		--enable QtGui \
		--enable QtNetwork \
		--enable QtWidgets  \
		--enable QtAndroidExtras\
		--disabled-feature PyQt_Desktop_OpenGL\
		--disabled-feature PyQt_Printer
		#--enable _QOpenGLFunctions_ES2\
		#--enable QtOpenGL\

	cd build
	make -j16
	make install
	popd
}

build_numpy() {
	pushd $GR4A_SCRIPT_DIR
	source android_toolchain.sh	
	popd
	pushd $GR4A_SCRIPT_DIR/numpy
	MATHLIB=m cross-python setup.py build
	cross-python setup.py install

}

install_deps() {

	sudo apt-get install build-essential zlib1g-dev libbz2-dev liblzma-dev libncurses5-dev libreadline6-dev libsqlite3-dev libssl-dev libgdbm-dev liblzma-dev tk8.6-dev lzma lzma-dev libgdbm-dev
	tar xvf PyQt5-5.15.2.tar.gz
}
install_venv () {
	source android_toolchain.sh
	cp -R $GR4A_SCRIPT_DIR/venv/cross/lib/* $DEV_PREFIX/lib
}

#install_deps
#build_python
create_venv
build_pyqt5
build_numpy
install_venv
