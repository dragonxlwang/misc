#!/bin/bash

# print with or without newline
function _color_echo {
  if [[ "$2" == "-n" ]]; then
    echo -ne "\033[${1}${@:3}\033[0m"
  else
    echo -e "\033[${1}${@:2}\033[0m";
  fi
}
function blackecho    { _color_echo "1;30m" "${@}"; }
function redecho      { _color_echo "1;31m" "${@}"; }
function greenecho    { _color_echo "1;32m" "${@}"; }
function yellowecho   { _color_echo "1;33m" "${@}"; }
function blueecho     { _color_echo "1;34m" "${@}"; }
function magentaecho  { _color_echo "1;35m" "${@}"; }
function cyanecho     { _color_echo "1;36m" "${@}"; }
function whiteecho    { _color_echo "1;37m" "${@}"; }

cd ~/.vim/
/bin/rm -rf ./bundle/YouCompleteMe
vim +PluginInstall +qall
cd ~/.vim/bundle/YouCompleteMe

sudo dnf install gcc-toolset-9

export PATH=/usr/local/bin:/usr/local/sbin:/opt/rh/gcc-toolset-9/root/usr/bin:$PATH

redecho "downloading ..."
DEST_ROOT=~/.vim/bundle/YouCompleteMe/third_party/ycmd
git clone https://github.com/Valloric/ycmd.git $DEST_ROOT
cd $DEST_ROOT
git submodule update --init --recursive


TMP_DIR=/tmp/ycm_build
rm -rf $TMP_DIR
mkdir -p $TMP_DIR

BUILD_DIR=$TMP_DIR/build
mkdir -p $BUILD_DIR

cd $BUILD_DIR

FBCODE_DIR="$(hg root --cwd ~/fbsource/fbcode)"/fbcode
FBCODE_PLATFORM=platform009
TP2="$FBCODE_DIR"/third-party-buck/"$FBCODE_PLATFORM"/build
PYTHON_VERSION=3.8
PYTHON_MAJOR_VERSION=3
PYTHON_DIR=${TP2}/python/${PYTHON_VERSION}



ln -s $TP2/glibc/lib64/libc.so.6 $DEST_ROOT/
ln -s $TP2/libgcc/lib/libstdc++.so.6 $DEST_ROOT/
ln -s $TP2/llvm-fb/lib/libclang.so $DEST_ROOT/
ln -s $TP2/llvm-fb/lib/libclang.so $DEST_ROOT/libclang.so.4
ln -s $TP2/llvm-fb/lib/libclang.so $DEST_ROOT/libclang.so.4.0
ln -s $TP2/llvm-fb/lib/libclang.so $DEST_ROOT/libclang.so.5

redecho "cmake ..."
env -i PATH=/bin:/usr/bin:/usr/local/bin \
  cmake \
  -G "Unix Makefiles" \
  -DCMAKE_C_COMPILER=gcc.par \
  -DCMAKE_CXX_COMPILER=g++.par \
  -DCMAKE_C_FLAGS="--platform=$FBCODE_PLATFORM" \
  -DCMAKE_CXX_FLAGS="--platform=$FBCODE_PLATFORM" \
  -DPYTHON_LIBRARY=${PYTHON_DIR}/lib/libpython${PYTHON_MAJOR_VERSION}.so \
  -DEXTERNAL_LIBCLANG_PATH="$DEST_ROOT"/libclang.so \
  . $DEST_ROOT/cpp

redecho "build ..."
# cmake -G Ninja
env -i PATH=/bin:/usr/bin:/usr/local/bin \
  cmake --build . --target ycm_core --config Release


redecho "watchdog ..."
cd ~/.vim/bundle/YouCompleteMe/third_party/ycmd/third_party/watchdog_deps/watchdog
rm -rf build/lib3
python setup.py build --build-base=build/3 --build-lib=build/lib3


redecho 'delete existing ...'
[[ -e /data/users/${USER}/YouCompleteMe ]] && \
  rm -rf /data/users/${USER}/YouCompleteMe

redecho 'setup symlink ...'
mv ${HOME}/.vim/bundle/YouCompleteMe /data/users/${USER}/
ln -s /data/users/${USER}/YouCompleteMe ${HOME}/.vim/bundle/YouCompleteMe
