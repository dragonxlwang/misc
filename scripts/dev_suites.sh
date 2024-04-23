#!/usr/bin/env zsh

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

# yum
## ==================================================
sudo dnf groupinstall "Development Tools"
packages=(cmake clang boost rubygems curl-devel htop \
  gettext-devel openssl-devel perl-CPAN perl-devel zlib-devel \
  curl-devel xorg-x11-xauth kernel-devel make ncurses-devel \
  bzip2-devel sqlite-devel readline readline-devel python-devel openssl \
  ruby ruby-devel lua lua-devel luajit \
  luajit-devel ctags git python python-devel \
  python3 python3-devel tcl-devel \
  perl perl-devel perl-ExtUtils-ParseXS \
  perl-ExtUtils-XSpp perl-ExtUtils-CBuilder \
  perl-ExtUtils-Embed gcc gcc-c++ \
  wget tar gzip ncurses-devel texinfo svn python-devel the_silver_searcher \
  yasd autojump-zsh)
for p in "${packages[@]}"
do
  sudo dnf install -y "$p"
done

# vim
## ==================================================
## wiki/Development_Environment/Vim/
# sudo ln -s /usr/lib64/libpython2.7.so.1.0 /usr/lib64/libpython2.6.so.1.0
# sudo yum install fb-ycm-1.1-fb4.x86_64
# /usr/share/vim/vim74/bundle/YouCompleteMe/setup-ycm.sh

# proxy
## ==================================================
## wiki/Development_Environment/Internet_Proxy/
if [[ ! -e ~/.curlrc ]]; then
  str="proxy=fwdproxy:8080\n"
  str+="noproxy=fbcdn.net,facebook.com,thefacebook.com,"
  str+="tfbnw.net,fb.com,fburl.com,facebook.net,sb.fbsbx.com,localhost"
  echo $str >> ~/.curlrc
fi
if [[ ! -e ~/.wgetrc ]]; then
  str="http_proxy=fwdproxy:8080\n"
  str+="https_proxy=fwdproxy:8080"
  echo $str >> ~/.wgetrc
fi
sudo dnf install -y socat &&
if [[ ! -e ~/bin/git-proxy-wrapper ]]; then
  mkdir -p ~/bin;
  printf '%s\n' \
      '#!/bin/sh' \
      '# See https://fburl.com/DevInternetProxy' \
      _proxy=fwdproxy \
      _proxyport=1080 \
      'exec socat -6 STDIO SOCKS4:$_proxy:$1:$2,socksport=$_proxyport' \
    > ~/bin/git-proxy-wrapper &&
  chmod a+x ~/bin/git-proxy-wrapper
fi

# fzf
cd ~
git clone --depth 1 git@github.com:junegunn/fzf.git  ~/.fzf
~/.fzf/install

# bd
cd ~/.oh-my-zsh/custom/plugins
git clone git@github.com:Tarrasch/zsh-bd.git bd

# pip
## ==================================================
mkdir -p ~/workspace

# cd ~/workspace
# git clone https://github.com/hhatto/autopep8.git
# cd autopep8
# sudo python setup.py install

cd ~/workspace
git clone git@github.com:giampaolo/psutil.git
cd psutil
sudo /usr/bin/python3 setup.py install

cd ~/workspace
git clone git@github.com:google/yapf.git
cd yapf
sudo /usr/bin/python3 setup.py install

cd ~/workspace
git clone git@github.com:PythonCharmers/python-future.git
cd python-future
sudo /usr/bin/python3 setup.py install

cd ~/workspace
git clone git@github.com:orb/pygments-json.git
cd pygments-json
sudo /usr/bin/python3 setup.py install

cd ~/workspace
git clone git@github.com:busyloop/lolcat
cd lolcat
make && sudo make install

cd ~/workspace
git clone git@github.com:jeffkaufman/icdiff
cd icdiff
sudo /usr/bin/python3 setup.py install

cd ~/workspace
git clone git@github.com:pallets/click.git
cd click
git checkout cba52fa76135af2edf46c154203b47106f898eb3
sudo /usr/bin/python3 setup.py install

# ipython
## ==================================================
## dex/ifbpy-notebook-in-a-nutshell/
# ipython_setup
# cd ~/fbcode
# torch/fb/fbitorch/setup.sh
# buck build -c fbcode.platform=gcc-4.9-glibc-2.20 deeplearning/torch:cuth

# features
## ==================================================
sudo feature install balancebot_vim
sudo feature install bento
sudo feature install dumont
sudo feature install fb-vim
sudo feature install fblearner_flow
sudo feature install glean_tools
sudo feature install inference_platform_tools
sudo feature install laser_tools
sudo feature install manifold
sudo feature install mdf
sudo feature install nlp_catalogue_tool
sudo feature install ouroboros
sudo feature install ttls_fwdproxy
sudo feature install unicorn_tools
sudo feature install warehouse
sudo feature install fpp
