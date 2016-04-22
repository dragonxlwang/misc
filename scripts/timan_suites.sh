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
redecho "install devtoolset-2 and yum packages"
cd ~
wget -O /etc/yum.repos.d/slc6-devtoolset.repo http://linuxsoft.cern.ch/cern/devtoolset/slc6-devtoolset.repo
yum install devtoolset-2
source /opt/rh/devtoolset-2/enable
yum install cmake clang boost rubygems curl-devel htop
export PATH="/opt/rh/devtoolset-2/root/usr/bin:/usr/local/bin:/usr/local/sbin:/opt/rh/devtoolset-2/root/usr/bin:/software/matlab-R2011a-x86_64/bin:/software/sun-jdk-1.6.0-latest-el6-x86_64/bin:/srv/adm/bin:/usr/lib64/qt-3.3/bin:/usr/NX/bin:/usr/bin:/bin:/usr/sbin:/sbin"

# timan-install-gist
## ==================================================
redecho "install gist"
gem install gist
chmod -R a+rx /usr/bin/gist
chmod -R a+rx /usr/lib

# timan-install-git
## ==================================================
redecho "install git"
yum groupinstall "Development Tools"
yum install gettext-devel openssl-devel perl-CPAN perl-devel zlib-devel curl-devel
# for gga git gui
yum install xorg-x11-xauth
cd ~
ver=2.8.0
curl -L https://github.com/git/git/archive/v$ver.tar.gz -o git-$ver.tar.gz
tar -zxf git-$ver.tar.gz
cd git-$ver
make configure
./configure --prefix=/usr/local
make all doc
make install install-doc install-html install-man install-info
make install
/usr/local/bin/git --version
cd ~
rm -rf git-$ver

# Install tmux on Centos release 6.5
## ==================================================
redecho "install tmux"
# install deps
yum install gcc kernel-devel make ncurses-devel
# DOWNLOAD SOURCES FOR LIBEVENT AND MAKE AND INSTALL
cd ~
ver=2.0.21
curl -OL https://github.com/downloads/libevent/libevent/libevent-$ver-stable.tar.gz
tar -xvzf libevent-$ver-stable.tar.gz
cd libevent-$ver-stable
./configure --prefix=/usr/local
make
make install
cd ~
rm -rf libevent-$ver-stable
# DOWNLOAD SOURCES FOR TMUX AND MAKE AND INSTALL
cd ~
ver=2.1
curl -OL https://github.com/tmux/tmux/releases/download/$ver/tmux-$ver.tar.gz
tar -xvzf tmux-$ver.tar.gz
cd tmux-$ver
LDFLAGS="-L/usr/local/lib -Wl,-rpath=/usr/local/lib" ./configure --prefix=/usr/local
make
make install
# pkill tmux
# close your terminal window (flushes cached tmux executable)
# open new shell and check tmux version
/usr/local/bin/tmux -V
cd ~
rm -rf tmux-$ver

# timan-install-python
## ==================================================
redecho "install python"
yum groupinstall "Development tools"
yum install zlib-devel bzip2-devel openssl-devel ncurses-devel sqlite-devel readline readline-devel
yum -y install python-devel openssl openssl-devel gcc sqlite-devel
cd ~
ver=2.7.11
wget --no-check-certificate https://www.python.org/ftp/python/$ver/Python-$ver.tgz
tar -zxvf Python-$ver.tgz
cd Python-$ver
./configure --prefix=/usr/local --with-threads --enable-shared LDFLAGS="-Wl,--rpath=/usr/local/lib"
make
make install
/usr/local/bin/python --version
cd ~
rm -rf Python-$ver
cd ~
curl -fsSL https://bootstrap.pypa.io/get-pip.py | /usr/local/bin/python -
curl -fsSL https://bootstrap.pypa.io/ez_setup.py | /usr/local/bin/python -
cd ~
/usr/local/bin/pip install --upgrade "ipython[all]"
/usr/local/bin/pip install --upgrade numpy scipy matplotlib jupyter
/usr/local/bin/pip install --upgrade basemap numba pillow pygame sympy nose
/usr/local/bin/pip install --upgrade nltk
/usr/local/bin/pip install --upgrade flake8 pep8 autopep8 yapf jedi psutil

# timan-install-vim
## ==================================================
sudo yum install -y ruby ruby-devel lua lua-devel luajit \
    luajit-devel ctags git python python-devel \
    python3 python3-devel tcl-devel \
    perl perl-devel perl-ExtUtils-ParseXS \
    perl-ExtUtils-XSpp perl-ExtUtils-CBuilder \
    perl-ExtUtils-Embed
cd ~
ver=7.4.1724
curl -OL https://github.com/vim/vim/archive/v$ver.tar.gz
tar -zxvf v$ver.tar.gz
cd vim-$ver
./configure --prefix=/usr/local \
            --with-features=huge \
            --enable-multibyte \
            --enable-rubyinterp \
            --enable-pythoninterp \
            --with-python-config-dir=/usr/local/lib/python2.7/config \
            --enable-perlinterp \
            --enable-luainterp \
            --enable-gui=gtk2 --enable-cscope \
            LDFLAGS="-L/usr/local/lib -Wl,-rpath=/usr/local/lib"
make VIMRUNTIMEDIR=/usr/local/share/vim/vim74
make install
/usr/local/bin/vim --version
cd ~
rm -rf vim-$ver

# timan-install-gdb
## ==================================================
redecho "install gdb"
yum install gcc gcc-c++
yum install wget tar gzip ncurses-devel texinfo svn python-devel
ver=7.11
curl -OL http://ftp.gnu.org/gnu/gdb/gdb-$ver.tar.xz
tar xf gdb-$ver.tar.xz
cd gdb-$ver
CC=gcc ./configure --with-python=yes --prefix=/usr/local LDFLAGS="-L/usr/local/lib -Wl,-rpath=/usr/local/lib"
make && make install
/usr/local/bin/gdb --version
cd ~
rm -rf gdb-$ver

#####################################################
echo "chmod -R a+rx /usr/local"
chmod -R a+rx /usr/local
