#!/usr/bin/env bash

# The required submodule commits are as follows:
ZLIB=v1.2.11
LIBSSH2=libssh2-1.9.0
OPENSSL=1.1.1d_2
LIBGIT2=v0.28.4

# get the scripts current directory to allow for calls from outside the top-level
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
VENDOR_PATH=vendor

# checkout zlib
echo checking out zlib...

cd $DIR/$VENDOR_PATH/zlib
# fetch and ensure all tags are avaliable locally
git fetch --all --tags --prune
# checkout
git checkout tags/$ZLIB

#checkout libssh2
echo checking out libssh2...
cd $DIR/$VENDOR_PATH/libssh2
# fetch and ensure all tags are avaliable locally
git fetch --all --tags --prune
# checkout
git checkout tags/$LIBSSH2

#checkout openssl
echo checking out openssl...
cd $DIR/$VENDOR_PATH/openssl-windows-binaries
# fetch and ensure all tags are avaliable locally
git fetch --all --tags --prune
# checkout
git checkout tags/$OPENSSL

#checkout libgit2
echo checking out libgit2...
cd $DIR/$VENDOR_PATH/libgit2
# fetch and ensure all tags are avaliable locally
git fetch --all --tags --prune
# checkout
git checkout tags/$LIBGIT2

echo "=> Synchronizing Submodules Complete"