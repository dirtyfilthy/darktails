#!/bin/sh
SCRIPTPATH=$(cd $(dirname $0) && pwd)
MODULEPATH=$SCRIPTPATH/submodules/darktails-monero
( cd $MODULEPATH && ./build-darktails-deb.sh )
DEBPATH=$MODULEPATH/dist/deb/build/darktails-monero-gui.deb
cp $DEBPATH config/chroot_local-packages/
