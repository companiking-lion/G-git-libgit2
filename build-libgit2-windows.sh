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

#########################
##    Path Variables   ##
#########################

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

LIBSSH2_INCLUDE_DIR=$LIBSSH2_INSTALL_DIR/include
LIBSSH2_LIB_DIR=$LIBSSH2_INSTALL_DIR/lib

#LibGIT2
LIBGIT2_SRC_DIR=$VENDOR_ROOT/libgit2
LIBGIT2_INSTALL_DIR=$LIB_OUTPUT_DIR/libgit2

#########################
##    Echo Functions   ##
#########################

function echoMain {

    echo "** $1 **"
}

function echoSub {

    echo "=> $1"
}

#########################
##   Build Functions   ##
#########################

function buildZLIB {

    echoMain "Building ZLIB with $CMAKE_GENERATOR_ARG"

    cd "$ZLIB_SRC_DIR"
    
    echoSub "Cleaning zlib Build Directory"

    rm -rf "build"

    echoSub "Creating zlib Build Directory"

    mkdir "build"
    
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
    
    echoSub "Cleaning: $OPEN_SSL_INSTALL_DIR"
    rm -rf $OPEN_SSL_INSTALL_DIR
    
    echoSub "Copying from $OPEN_SSL_SRC_DIR"
    cp -r "$OPEN_SSL_SRC_DIR" "$OPEN_SSL_INSTALL_DIR"
}

function buildLIBSSH2 {

    echoMain "Building LIBSSH2 with $CMAKE_GENERATOR_ARG"

    cd "$LIBSSH2_SRC_DIR"
    
    echoSub "Cleaning LibSSH2 Build Directory"

    rm -rf build

    echoSub "Creating LibSSH2 Build Directory"

    mkdir "build"
    
    cd build

    echoSub "Generating Windows CMAKE files"

    #build with OPENSSL and ZLIB
    
    OPEN_SSL_ARGS="-D OPENSSL_ROOT_DIR=\"$OPEN_SSL_INSTALL_DIR\""
    ZLIB_ARGS="-D ENABLE_ZLIB_COMPRESSION=TRUE -D ZLIB_LIBRARY_RELEASE=\"$ZLIB_LIB_DIR/zlib.lib\" -D ZLIB_INCLUDE_DIR=\"$ZLIB_INCLUDE_DIR\""
    
    eval "cmake .. -G \"$CMAKE_GENERATOR_ARG\" -D BUILD_SHARED_LIBS=TRUE  $OPEN_SSL_ARGS $ZLIB_ARGS -D CMAKE_INSTALL_PREFIX=\"$LIBSSH2_INSTALL_DIR\""
    
    echoSub "Building"
    cmake --build . --config $CMAKE_BUILD_TYPE

    echoSub "Installing to: $LIBSSH2_INSTALL_DIR"
    cmake --install .
}


function buildLIBGIT2 {
    echoMain "Building LIBGIT2 with $CMAKE_GENERATOR_ARG"

    cd "$LIBGIT2_SRC_DIR"
    
    echoSub "Cleaning LibGIT2 Build Directory"

    rm -rf build

    echoSub "Creating LibGIT2 Build Directory"

    mkdir "build"
    
    cd build

    echoSub "Generating Windows CMAKE files"

    #build with OPENSSL, SSH and ZLIB

    OPEN_SSL_ARGS="-D LIB_EAY_RELEASE=\"$OPEN_SSL_LIB_DIR/libcrypto.lib\" -D SSL_EAY_RELEASE=\"$OPEN_SSL_LIB_DIR/libssl.lib\""
    ZLIB_ARGS="-D ZLIB_INCLUDE_DIR=\"$ZLIB_INCLUDE_DIR\" -D ZLIB_LIBRARY_RELEASE=\"$ZLIB_LIB_DIR/zlib.lib\""
    # USE_SSH=False to prevent search for library
    SSH_ARGS="-D USE_SSH=False -D LIBSSH2_FOUND=True -D LIBSSH2_INCLUDE_DIRS=\"$LIBSSH2_INCLUDE_DIR\" -D LIBSSH2_LIBRARY_DIRS=\"$LIBSSH2_LIB_DIR\" -D LIBSSH2_LIBRARIES=\"$LIBSSH2_LIB_DIR/libssh2.lib\""
    
    eval "cmake .. -G \"$CMAKE_GENERATOR_ARG\" -D CMAKE_INSTALL_PREFIX=\"$LIBGIT2_INSTALL_DIR\" $OPEN_SSL_ARGS $ZLIB_ARGS $SSH_ARGS "
    
    echoSub "Building"

    cmake --build . --config $CMAKE_BUILD_TYPE

    echoSub "Installing to: $LIBGIT2_INSTALL_DIR"
    cmake --install .
}

#########################
##    Script Build     ##
#########################

echoMain "synchronizing git submodules"
./sync-submodules.sh


echoMain "Building ZLIB, OPENSSL, LIBSSH2 and LIBGIT2"

# Build Librarires in Dependency-Order
buildZLIB
copyOPENSSL
buildLIBSSH2
buildLIBGIT2

# Done!
echoMain "All Libraries Built to: $LIB_OUTPUT_DIR"