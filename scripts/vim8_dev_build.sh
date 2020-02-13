#!/bin/bash

cd ~

# sudo curl -L https://copr.fedorainfracloud.org/coprs/mcepl/vim8/repo/epel-7/mcepl-vim8-epel-7.repo -o /etc/yum.repos.d/mcepl-vim8-epel-7.repo

# export http_proxy=fwdproxy:8080
# export https_proxy=fwdproxy:8080

# sudo yum update "vim*"

# https://github.com/Valloric/YouCompleteMe/wiki/Building-Vim-from-source

sudo rm -rf /etc/yum.repos.d/mcepl-vim8-epel-7.repo

sudo yum install -y ruby ruby-devel lua lua-devel luajit \
    luajit-devel ctags git python python-devel \
    python3 python3-devel tcl-devel \
    perl perl-devel perl-ExtUtils-ParseXS \
    perl-ExtUtils-XSpp perl-ExtUtils-CBuilder \
    perl-ExtUtils-Embed
sudo yum install cscope ncurses ncurses-devel ncurses-libs ncurses-base lua lua-devel python36-devel python-libs ruby ruby-devel

#--with-python-command=/usr/local/fbcode/platform007/bin/python2.7 \
#--enable-pythoninterp \
#--with-python-config-dir=/usr/local/fbcode/platform007/lib/python2.7/config \

cd ~
ver=8.2.0251
curl -OL https://github.com/vim/vim/archive/v$ver.tar.gz
tar -zxvf v$ver.tar.gz
cd ~/vim-$ver
./configure --prefix=/usr/local \
            --with-features=huge \
            --enable-multibyte \
            --enable-rubyinterp \
            --with-python3-command=/usr/local/fbcode/platform007/bin/python3.6 \
            --enable-python3interp \
            --with-python3-config-dir=/usr/local/fbcode/platform007/lib/python3.6/config-3.6m-fb-007-x86_64/ \
            --enable-perlinterp \
            --enable-luainterp \
            --enable-gui=gtk2 \
            --enable-cscope
make VIMRUNTIMEDIR=/usr/local/share/vim/vim82

# sudo update-alternatives --install /usr/bin/editor editor /usr/bin/vim 1
# sudo update-alternatives --set editor /usr/bin/vim
# sudo update-alternatives --install /usr/bin/vi vi /usr/bin/vim 1
# sudo update-alternatives --set vi /usr/bin/vim

cd ~/vim-$ver
sudo make install
/usr/local/bin/vim --version
vim --version
cd ~
rm -rf ~/vim-$ver
rm -rf v$ver.tar.gz
