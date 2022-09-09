This folder contains helper files to build Gnuradio Android applications

Simply copy this folder on top of an app built from the gnuradio companion
A short description of the files

```
- android folder contains Android specific packaging information such as assets, deployed libraries, AndroidManifest.xml as well as the Java code that loads the Qt app

- CMakelists.txt - An example cmakelists file to build a C++ android application that links all the necessary libraries as well as configures the android packaging

All scripts require sourcing androidi\_toolchain.sh from /gnuradio-android - This will load envvars

- android_cmake.sh - a cmake wrapper that sets all the necessary variables for Android compilation - will create a build folder where you can run make
- android_deploy_libs.sh - copies libraries from the sysroot to the appropriate folders for packaging
- android_deploy_qt.sh - once the android app library is built, this script creates an apk or an aab. It also handles signing of the app
- android_clean_libs.sh - cleans the libs from the /android folder
```

If USB with libusb is required by your application, add the following lines in the initialization (first thing in main() )

```
#ifdef __ANDROID__ // LIBUSB WEAK_AUTHORITY
    libusb_set_option(NULL,LIBUSB_OPTION_ANDROID_JAVAVM,jnienv->javaVM());
    libusb_set_option(NULL,LIBUSB_OPTION_WEAK_AUTHORITY,NULL);
#endif
```


jnienv is a pointer to the QAndroidJniEnvironment() - an example of this can be found here:

https://github.com/adisuciu/gr-flowgraph-runner/blob/main/src/mainwindow.cpp#L34-L36

https://github.com/adisuciu/gr-flowgraph-runner/blob/main/src/mainwindow.cpp#L57-L59

This is required because at the time of writing, libusb support for android is still work in progress so I used a version that was working for me. When the pull request is merged to master, this "hack" will no longer be required.

You can track the progress of the PR here:
https://github.com/libusb/libusb/pull/874
