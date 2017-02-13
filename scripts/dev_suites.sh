#!/bin/sh

function _color_echo {
  if [[ "$2" == "-n" ]]; then echo -ne "\033[${1}${@:3}\033[0m"
  else echo -e "\033[${1}${@:2}\033[0m"; fi }
function blackecho    { _color_echo "1;30m" "${@}"; }
function redecho      { _color_echo "1;31m" "${@}"; }
function greenecho    { _color_echo "1;32m" "${@}"; }
function yellowecho   { _color_echo "1;33m" "${@}"; }
function blueecho     { _color_echo "1;34m" "${@}"; }
function magentaecho  { _color_echo "1;35m" "${@}"; }
function cyanecho     { _color_echo "1;36m" "${@}"; }
function whiteecho    { _color_echo "1;37m" "${@}"; }

# yum
## ==================================================
sudo yum install cmake clang boost rubygems curl-devel htop
sudo yum groupinstall "Development Tools"
sudo yum install gettext-devel openssl-devel perl-CPAN perl-devel zlib-devel \
    curl-devel xorg-x11-xauth
sudo yum install kernel-devel make ncurses-devel
sudo yum install bzip2-devel sqlite-devel readline readline-devel
sudo yum install python-devel openssl
sudo yum install ruby ruby-devel lua lua-devel luajit \
    luajit-devel ctags git python python-devel \
    python3 python3-devel tcl-devel \
    perl perl-devel perl-ExtUtils-ParseXS \
    perl-ExtUtils-XSpp perl-ExtUtils-CBuilder \
    perl-ExtUtils-Embed
sudo yum install gcc gcc-c++
sudo yum install wget tar gzip ncurses-devel texinfo svn python-devel

# vim
## ==================================================
## wiki/Development_Environment/Vim/
sudo ln -s /usr/lib64/libpython2.7.so.1.0 /usr/lib64/libpython2.6.so.1.0
sudo yum install fb-ycm-1.1-fb4.x86_64
/usr/share/vim/vim74/bundle/YouCompleteMe/setup-ycm.sh

