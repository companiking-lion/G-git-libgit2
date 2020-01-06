#!/usr/bin/env bash

RUNTIME="x86"
# RUNTIME="x64"

# VS2015 Generators
CMAKE_GENERATOR_ARG="Visual Studio 14 2015"
#CMAKE_GENERATOR_ARG=\"Visual Studio 14 2015 Win64\"

# Alternative Generators for VS2019 (not tested)
#CMAKE_GENERATOR_ARG="Visual Studio 16 2019" -A "Win32"
#CMAKE_GENERATOR_ARG="Visual Studio 16 2019" -A "x64"

#CMAKE_BUILD_TYPE=Debug
CMAKE_BUILD_TYPE="Release"

## TODO - Add command line arguments to specify build

# get the scripts current directory to allow for calls from outside the top-level
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

####################
## Path Variables ##
####################

# Library Output Path
LIB_OUTPUT_DIR=$DIR/build/$RUNTIME

# Vendor Library Path
VENDOR_ROOT=$DIR/vendor

# zlib
ZLIB_SRC_DIR=$VENDOR_ROOT/zlib
ZLIB_INSTALL_DIR=$LIB_OUTPUT_DIR/zlib

ZLIB_INCLUDE_DIR=$ZLIB_INSTALL_DIR/include
ZLIB_LIB_DIR=$ZLIB_INSTALL_DIR/lib

# OpenSSL
OPEN_SSL_SRC_DIR=$VENDOR_ROOT/openssl-windows-binaries/build/$RUNTIME
OPEN_SSL_INSTALL_DIR=$LIB_OUTPUT_DIR/OpenSSL

OPEN_SSL_INCLUDE_DIR=$OPEN_SSL_INSTALL_DIR/include
OPEN_SSL_LIB_DIR=$OPEN_SSL_INSTALL_DIR/lib
OPEN_SSL_BIN_DIR=$OPEN_SSL_INSTALL_DIR/bin

#LibSSH2
LIBSSH2_SRC_DIR=$VENDOR_ROOT/libssh2
LIBSSH2_INSTALL_DIR=$LIB_OUTPUT_DIR/libssh2

#LIBSSH2_INCLUDE_DIR=$LIBSSH2_BASE_DIR/include
#LIBSSH2_LIB_DIR=$LIB_OUTPUT_DIR

####################
##    Functions   ##
####################

function createDir {

    # create directory but silence stderr by redirecting it
    { output=$(mkdir -p $1 2>&1 1>&3-) ;} 3>&1
}

function echoMain {

    echo "** $1 **"
}

function echoSub {

    echo "=> $1"
}

function buildZLIB {

    echoMain "Building ZLIB with $CMAKE_GENERATOR_ARG"

    cd "$ZLIB_SRC_DIR"
    
    echoSub "Making sure zlib build directory exists"
    createDir "build"
    
    cd build

    echoSub "Generating Windows CMAKE files"

    # use eval so arguments don't get truncated
    eval "cmake .. -G \"$CMAKE_GENERATOR_ARG\" -D CMAKE_INSTALL_PREFIX=\"$ZLIB_INSTALL_DIR\""

    echoSub "Building"
    cmake --build . --config $CMAKE_BUILD_TYPE

    echoSub "Installing to: $ZLIB_INSTALL_DIR"
    cmake --install .
}

function copyOPENSSL {

    echoMain "Copying Pre-Built OpenSSL Binaries"
    echoSub "Copying to: $OPEN_SSL_INSTALL_DIR"
    cp -r "$OPEN_SSL_SRC_DIR" "$OPEN_SSL_INSTALL_DIR"
}

function buildLIBSSH2 {

    echoMain "Building LIBSSH2 with $CMAKE_GENERATOR_ARG"

    cd "$LIBSSH2_SRC_DIR"
    
    echoSub "Making sure LibSSH2 build directory exists"

    createDir "build"
    
    cd build

    echoSub "Generating Windows CMAKE files"

    #build with OPENSSL and ZLIB
    # use eval so arguments don't get truncated
    
    # Note OpenSSL Releases from 1.1 renamed libeay.dll to libcrypto-x_x.dll and ssleay.dll to libssl-x_x.dll

    OPEN_SSL_ARGS="-D SSL_EAY_RELEASE=\"$OPEN_SSL_LIB_DIR/libcrypto.lib\" -D SSL_EAY_RELEASE=\"$OPEN_SSL_LIB_DIR/libssl.lib\" -D OPENSSL_INCLUDE_DIR=\"$OPEN_SSL_INCLUDE_DIR\" -D DLL_LIBEAY32=\"$OPEN_SSL_BIN_DIR/libcrypto-1_1.dll\" -D DLL_SSLEAY32=\"$OPEN_SSL_BIN_DIR/libssl-1_1.dll\""
    ZLIB_ARGS="-D ENABLE_ZLIB_COMPRESSION=TRUE -D ZLIB_LIBRARY_RELEASE=\"$ZLIB_LIB_DIR/zlib.lib\" -D ZLIB_INCLUDE_DIR=\"$ZLIB_INCLUDE_DIR\""
    
    eval "cmake ../../libssh2 -G \"$CMAKE_GENERATOR_ARG\" -D BUILD_SHARED_LIBS=TRUE  $OPEN_SSL_ARGS $ZLIB_ARGS -D CMAKE_INSTALL_PREFIX=\"$LIBSSH2_INSTALL_DIR\""
    
    echoSub "Building"
    cmake --build . --config $CMAKE_BUILD_TYPE

    echoSub "Installing to: $ZLIB_INSTALL_DIR"
    cmake --install .


#######################

    # LIB_DIR="libssh2"

    # echo "** Building libssh2 with $CMAKE_GENERATOR_ARG **"
    
    # cd $BUILD_DIR

    # echo ". Cleaning Build Directory"
    # # clean lib directory
    # rm -rf $LIB_DIR

    # echo ". Creating Build Directory"
    # # create lib build-dir
    # mkdir $LIB_DIR
    # cd $LIB_DIR

    # #build with OPENSSL and ZLIB
    # # use eval so arguments don't get truncated
    
    # # Note OpenSSL Releases from 1.1 renamed libeay.dll to libcrypto-x_x.dll and ssleay.dll to libssl-x_x.dll

    # OPEN_SSL_ARGS="-D SSL_EAY_RELEASE=\"$OPEN_SSL_LIB_DIR/libcrypto.lib\" -D SSL_EAY_RELEASE=\"$OPEN_SSL_LIB_DIR/libssl.lib\" -D OPENSSL_INCLUDE_DIR=\"$OPEN_SSL_INCLUDE_DIR\" -D DLL_LIBEAY32=\"$OPEN_SSL_BIN_DIR/libcrypto-1_1.dll\" -D DLL_SSLEAY32=\"$OPEN_SSL_BIN_DIR/libssl-1_1.dll\""
    # ZLIB_ARGS="-D ENABLE_ZLIB_COMPRESSION=TRUE -D ZLIB_LIBRARY_RELEASE=\"$ZLIB_LIB_DIR/zlib.lib\" -D ZLIB_INCLUDE_DIR=\"$ZLIB_INCLUDE_DIR\""
    
    # eval "cmake ../../libssh2 -G \"$CMAKE_GENERATOR_ARG\" -D BUILD_SHARED_LIBS=TRUE $OPEN_SSL_ARGS $ZLIB_ARGS -D CMAKE_INSTALL_PREFIX=\"$LIB_OUTPUT_DIR/libssh2\""
    
    # #build
    # cmake --build . --config $CMAKE_BUILD_TYPE

    # # copy build files
    # OUTPUT_DIR=$LIB_OUTPUT_DIR/../$RUNTIME
    # createDir $OUTPUT_DIR

    # # copy build files to Lib-Output Directory
    # #cp -r "./src/$CMAKE_BUILD_TYPE" "$OUTPUT_DIR"
}

function buildLIBGIT2 {
    LIB_DIR="libgit2"

    echo "** Building libgit2 with $CMAKE_GENERATOR_ARG **"
    
    cd $BUILD_DIR

    echo ". Cleaning Build Directory"
    # clean lib directory
    #rm -rf $LIB_DIR

    echo ". Creating Build Directory"
    # create lib build-dir
   # mkdir $LIB_DIR
    cd $LIB_DIR

    #build with OPENSSL and ZLIB
    # use eval so arguments don't get truncated
    
    # Note OpenSSL Releases from 1.1 renamed libeay.dll to libcrypto-x_x.dll and ssleay.dll to libssl-x_x.dll

    OPEN_SSL_ARGS="-D LIB_EAY_RELEASE=\"$OPEN_SSL_LIB_DIR/libcrypto.lib\" -D SSL_EAY_RELEASE=\"$OPEN_SSL_LIB_DIR/libssl.lib\""
    ZLIB_ARGS="-D ZLIB_INCLUDE_DIR=\"$ZLIB_INCLUDE_DIR\" -D ZLIB_LIBRARY_RELEASE=\"$ZLIB_LIB_DIR/zlib.lib\" "
    
    SSH_ARGS="-D EMBED_SSH_PATH=\"\""
    
    #SSH_ARGS="-D LIBSSH2_FOUND=True -D LIBSSH2_INCLUDE_DIRS=\"$LIBSSH2_INCLUDE_DIR\" -D LIBSSH2_LIBRARY_DIRS=\"$LIBSSH2_LIB_DIR\" -D LIBSSH2_LIBRARIES=\"$LIBSSH2_LIB_DIR/libssh2.lib\""
    

   # eval "cmake ../../libgit2 -G \"$CMAKE_GENERATOR_ARG\" -D BUILD_SHARED_LIBS=TRUE $OPEN_SSL_ARGS $ZLIB_ARGS $SSH_ARGS"
    
    #build
    #cmake --build . --config $CMAKE_BUILD_TYPE

    # # copy build files
    # OUTPUT_DIR=$LIB_OUTPUT_DIR/../$RUNTIME
    # createDir $OUTPUT_DIR

}


echo "synchronizing git submodules"
#$DIR/sync-submodules.sh

#buildZLIB
#copyOPENSSL
buildLIBSSH2
#buildLIBGIT2

# echo $OPEN_SSL_SRC_DIR
# echo $OPEN_SSL_INSTALL_DIR

# echo $OPEN_SSL_INCLUDE_DIR
# echo $OPEN_SSL_LIB_DIR
# echo $OPEN_SSL_BIN_DIR