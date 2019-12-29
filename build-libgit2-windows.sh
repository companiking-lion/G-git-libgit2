#!/usr/bin/env bash

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
LIB_OUTPUT_DIR=$DIR/build/libs

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
}


function buildOPENSSL{
    # this is going to be difficult
    # https://wiki.openssl.org/index.php/Compilation_and_Installation
    # https://stackoverflow.com/questions/40007633/how-to-compile-openssl-on-windows
    # nasm need to be installed and on the system path
    # https://www.nasm.us/



}


function buildLIBSSH2 {
    LIB_DIR="libssh2"

    echo "Building libssh2 with $CMAKE_GENERATOR_ARG"
    
    cd $BUILD_DIR

    # clean zlib directory
    rm -rf $LIB_DIR

    # create zlib build-dir
    mkdir $LIB_DIR
    cd $LIB_DIR

    # call cmake
    # use eval so arguments don't get truncated
    #eval "cmake ../../zlib -G \"$CMAKE_GENERATOR_ARG\" -D LIBRARY_OUTPUT_PATH=\"$ZLIB_LIB_OUTPUT_DIR\" -D INSTALL_INC_DIR=\"$ZLIB_LIB_OUTPUT_DIR\" -D INSTALL_LIB_DIR=\"$ZLIB_LIB_OUTPUT_DIR\""

    #cmake --build . --config $CMAKE_BUILD_TYPE
}

echo "synchronizing git submodules"
#$DIR/sync-submodules.sh

# create build dir
createDir $BUILD_DIR

#buildZLIB

#buildLIBSSH2


