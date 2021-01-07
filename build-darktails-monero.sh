#!/bin/sh
SCRIPTPATH=$(cd $(dirname $0) && pwd)
MODULEPATH=$SCRIPTPATH/submodules/darktails-monero
BUILDPATH=$MODULEPATH/build/release/bin
SKELPATH=$MODULEPATH/dist/deb/skel
DESTPATH=$SCRIPTPATH/config/chroot_local-includes
echo "BUILD PATH : $BUILDPATH"
echo "SKEL PATH  : $SKELPATH"
echo "DEST PATH  : $DESTPATH"
git submodule update --init --recursive
git submodule update --remote --recursive
(
	cd $MODULEPATH
	./build-darktails.sh
)
cp -r $SKELPATH/*  $DESTPATH
cp -r $BUILDPATH/* $DESTPATH/usr/local/bin

