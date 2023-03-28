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
function whiteecho    { _color_echo "2;37m" "${@}"; }

cd ~/.vim/
/bin/rm -rf ./bundle/YouCompleteMe
vim +PluginInstall +qall
cd ~/.vim/bundle/YouCompleteMe
# git checkout 4117a99861b537830d717c3113e3d584523bc573


sudo dnf install gcc-toolset-9

export PATH=/usr/local/bin:/usr/local/sbin:/opt/rh/gcc-toolset-9/root/usr/bin:$PATH

redecho "installing..."

FBCODE_DIR="$(hg root --cwd ~/fbsource/fbcode)"/fbcode
FBCODE_PLATFORM=platform010
TP2="$FBCODE_DIR"/third-party-buck/"$FBCODE_PLATFORM"/build
PYTHON_VERSION=3.10
PYTHON_MAJOR_VERSION=3
PYTHON_DIR=${TP2}/python/${PYTHON_VERSION}

CMAKE_ARGS="-DCMAKE_C_COMPILER=gcc.par"
CMAKE_ARGS+=" -DCMAKE_CXX_COMPILER=g++.par"
CMAKE_ARGS+=" -DCMAKE_C_FLAGS=\"--platform=$FBCODE_PLATFORM\""
CMAKE_ARGS+=" -DCMAKE_CXX_FLAGS=\"--platform=$FBCODE_PLATFORM\""
CMAKE_ARGS+=" -DPYTHON_LIBRARY=${PYTHON_DIR}/lib/libpython${PYTHON_VERSION}.so"
CMAKE_ARGS+=" -DEXTERNAL_LIBCLANG_PATH=$TP2/llvm-fb/15/lib/libclang.so"

https_proxy='fwdproxy:8080' http_proxy='fwdproxy:8080' EXTRA_CMAKE_ARGS=${CMAKE_ARGS} \
  ${PYTHON_DIR}/bin/python${PYTHON_VERSION} ./install.py --clang-completer

redecho 'setup symlink ...'
/bin/rm -rf /data/users/${USER}/YouCompleteMe
mv ${HOME}/.vim/bundle/YouCompleteMe /data/users/${USER}/
ln -s /data/users/${USER}/YouCompleteMe ${HOME}/.vim/bundle/YouCompleteMe
