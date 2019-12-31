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

# create some path variables
# base paths
VENDOR_PATH=vendor
BUILD_DIR=$DIR/$VENDOR_PATH/build

#lib output paths
LIB_OUTPUT_DIR=$DIR/build/libs/$RUNTIME

ZLIB_BASE_DIR=$DIR/build/libs/$RUNTIME/
ZLIB_INCLUDE_DIR=$DIR/$VENDOR_PATH/zlib
ZLIB_LIB_DIR=$ZLIB_BASE_DIR/Release

OPEN_SSL_BASE_DIR=$DIR/$VENDOR_PATH/openssl-windows-binaries/build/$RUNTIME
OPEN_SSL_INCLUDE_DIR=$OPEN_SSL_BASE_DIR/include
OPEN_SSL_LIB_DIR=$OPEN_SSL_BASE_DIR/lib



function createDir {
    # create directory but silence stderr by redirecting it
    { output=$(mkdir $1 2>&1 1>&3-) ;} 3>&1
}

function buildZLIB {
    LIB_DIR="zlib"

    echo "Building ZLIB with $CMAKE_GENERATOR_ARG"
    
    cd $BUILD_DIR

    # clean zlib directory
    rm -rf $LIB_DIR

    # create zlib build-dir
    mkdir $LIB_DIR
    cd $LIB_DIR

    # call cmake
    # use eval so arguments don't get truncated
    eval "cmake ../../zlib -G \"$CMAKE_GENERATOR_ARG\" -D LIBRARY_OUTPUT_PATH=\"$LIB_OUTPUT_DIR\" -D INSTALL_INC_DIR=\"$LIB_OUTPUT_DIR\" -D INSTALL_LIB_DIR=\"$LIB_OUTPUT_DIR\""

    cmake --build . --config $CMAKE_BUILD_TYPE

    # rename the zconf.h.include file to zconf.h
    mv "../../zlib/zconf.h.included" "../../zlib/zconf.h"
}

function buildLIBSSH2 {
    LIB_DIR="libssh2"

    echo "Building libssh2 with $CMAKE_GENERATOR_ARG"
    
    cd $BUILD_DIR

    # clean lib directory
    rm -rf $LIB_DIR

    # create lib build-dir
    mkdir $LIB_DIR
    cd $LIB_DIR


    eval "cmake ../../libssh2 -G \"$CMAKE_GENERATOR_ARG\" -D BUILD_SHARED_LIBS=TRUE -D LIB_EAY_RELEASE=\"$OPEN_SSL_LIB_DIR/libcrypto.lib\" -D SSL_EAY_RELEASE=\"$OPEN_SSL_LIB_DIR/libssl.lib\" -D OPENSSL_INCLUDE_DIR=\"$OPEN_SSL_INCLUDE_DIR\" -D ENABLE_ZLIB_COMPRESSION=TRUE -D ZLIB_LIBRARY_RELEASE=\"$ZLIB_LIB_DIR/zlib.lib\" -D ZLIB_INCLUDE_DIR=\"$ZLIB_INCLUDE_DIR\""
    cmake --build . --config $CMAKE_BUILD_TYPE
}

echo "synchronizing git submodules"
#$DIR/sync-submodules.sh

# create build dir
createDir $BUILD_DIR

#buildZLIB

buildLIBSSH2
