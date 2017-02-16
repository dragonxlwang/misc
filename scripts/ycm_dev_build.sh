#!/bin/bash

cd ~/.vim/
/bin/rm -rf ./bundle/YouCompleteMe
vim +PluginInstall +qall

DEST_ROOT=~/.vim/bundle/YouCompleteMe/third_party/ycmd # change this directory to your heart's cotent. Keep it in local disk, however.
git clone https://github.com/Valloric/ycmd.git $DEST_ROOT
cd $DEST_ROOT
git submodule update --init --recursive

TMP_DIR=/tmp/ycm_build
rm -rf $TMP_DIR
mkdir -p $TMP_DIR

BUILD_DIR=$TMP_DIR/build
mkdir -p $BUILD_DIR

cd $BUILD_DIR


FBCODE_DIR="$(hg root --cwd ~/fbsource/fbcode)"/fbcode # set this
FBCODE_PLATFORM=gcc-5-glibc-2.23
TP2="$FBCODE_DIR"/third-party-buck/"$FBCODE_PLATFORM"/build

env -i PATH=/bin:/usr/bin:/usr/local/bin \
   cmake \
   -G "Unix Makefiles" \
  -DCMAKE_C_COMPILER=gcc.par \
  -DCMAKE_CXX_COMPILER=g++.par \
  -DCMAKE_C_FLAGS="--platform=$FBCODE_PLATFORM" \
  -DCMAKE_CXX_FLAGS="--platform=$FBCODE_PLATFORM" \
  -DPYTHON_LIBRARY="$TP2"/python/2.7/lib/libpython2.7.so \
  -DPATH_TO_LLVM_ROOT="$TP2"/llvm-fb \
   . $DEST_ROOT/cpp

cmake -G Ninja
env -i PATH=/bin:/usr/bin:/usr/local/bin \
  cmake --build . --target ycm_core --config Release -- -j55

ln -s $TP2/glibc/lib64/libc.so.6 $DEST_ROOT/
ln -s $TP2/libgcc/lib/libstdc++.so.6 $DEST_ROOT/

mv ${HOME}/.vim/bundle/YouCompleteMe /data/users/${USER}/

ln -s /data/users/${USER}/YouCompleteMe ${HOME}/.vim/bundle/YouCompleteMe

