#!/bin/bash

cd ~

sudo curl -L https://copr.fedorainfracloud.org/coprs/mcepl/vim8/repo/epel-7/mcepl-vim8-epel-7.repo -o /etc/yum.repos.d/mcepl-vim8-epel-7.repo

export http_proxy=fwdproxy:8080
export https_proxy=fwdproxy:8080

sudo yum update "vim*"
# sudo rm -rf /etc/yum.repos.d/mcepl-vim8-epel-7.repo

# sudo yum install -y ruby ruby-devel lua lua-devel luajit \
#     luajit-devel ctags git python python-devel \
#     python3 python3-devel tcl-devel \
#     perl perl-devel perl-ExtUtils-ParseXS \
#     perl-ExtUtils-XSpp perl-ExtUtils-CBuilder \
#     perl-ExtUtils-Embed
# cd ~
# ver=7.4.1952
# curl -OL https://github.com/vim/vim/archive/v$ver.tar.gz
# tar -zxvf v$ver.tar.gz
# cd vim-$ver
# ./configure --prefix=/usr/local \
#             --with-features=huge \
#             --enable-multibyte \
#             --enable-rubyinterp \
#             --enable-pythoninterp \
#             --with-python-config-dir=/usr/local/lib/python2.7/config \
#             --enable-perlinterp \
#             --enable-luainterp \
#             --enable-gui=gtk2 --enable-cscope \
#             LDFLAGS="-L/usr/local/lib -Wl,-rpath=/usr/local/lib"
# make VIMRUNTIMEDIR=/usr/local/share/vim/vim74
# make install
# /usr/local/bin/vim --version
# cd ~
# rm -rf vim-$ver
