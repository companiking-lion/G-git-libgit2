#!/usr/bin/env bash

# get the scripts current directory to allow for calls from outside the top-level
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
VENDOR_PATH=vendor
BUILD_DIR=$DIR/$VENDOR_PATH/build

function createDir {
    # create directory but silence stderr by redirecting it
    { output=$(mkdir $1 2>&1 1>&3-) ;} 3>&1
}

function buildZLIB {
    echo "Building ZLIB"
    cd $BUILD_DIR

    # create zlib build-dir
    createDir "zlib"
    cd "zlib"

    # call cmake
    cmake ../../zlib
}

echo "synchronizing git submodules"
#$DIR/sync-submodules.sh

# create build dir
createDir $BUILD_DIR

buildZLIB


