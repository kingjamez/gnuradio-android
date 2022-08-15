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
#	build-pip install setuptools --upgrade
#	build-pip install numpy==1.23.2 # install python only on build-pip so crosscompile checks for numpy pass
#	cross-pip install numpy==1.23.2 

	cross-pip install pytest
#	build-pip install pybind11
	cross-pip install pybind11
	build-pip install packaging
	cross-pip install packaging
	build-pip install cython
	cross-pip install cython
	build-pip install mako
	cross-pip install mako
	build-pip install sip
	cross-pip install sip
	build-pip install pyqt-builder
	cross-pip install pyqt-builder #need this ?
	
	build-pip install pyqt5-sip
	cross-pip install pyqt5-sip
	cp venv/build/bin/sip-* venv/cross/bin/
	#patch sip-build -- change shebang from build to cross
	sed -i '0,/build/s/build/cross/' venv/cross/bin/sip-*

	popd
}
build_pyqt5-sip() {
	pushd $GR4A_SCRIPT_DIR
	source android_toolchain.sh	
	popd
	pushd $GR4A_SCRIPT_DIR/PyQt5_sip-12.11.0
	rm -rf build
	LDFLAGS='-lpython3' cross-python setup.py bdist
	
	#hack as i don't know how to disable egg install
	mkdir -p /home/adi/src/gnuradio-android/venv/cross/lib/python3.10/PyQt5/
	cp build/lib.linux-aarch64-cpython-310/PyQt5/sip.cpython-310.so /home/adi/src/gnuradio-android/venv/cross/lib/python3.10/PyQt5/
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
	       	--target-dir ${DEV_PREFIX}/lib/python3.10\
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
	git clean -xdf
	LDFLAGS='-lpython3' MATHLIB=m cross-python setup.py build
	cross-python setup.py install

	build-pip install numpy==1.22.4
}

install_deps() {

	sudo apt-get install build-essential zlib1g-dev libbz2-dev liblzma-dev libncurses5-dev libreadline6-dev libsqlite3-dev libssl-dev libgdbm-dev liblzma-dev tk8.6-dev lzma lzma-dev libgdbm-dev
	tar xvf PyQt5-5.15.2.tar.gz
}
install_venv () {
	pushd $GR4A_SCRIPT_DIR
	source android_toolchain.sh
	cp -R $GR4A_SCRIPT_DIR/venv/cross/lib/* $DEV_PREFIX/lib
	popd
}

#install_deps
#build_python
#create_venv
#build_numpy
build_pyqt5-sip
#build_pyqt5
install_venv
