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
sudo yum groupinstall "Development Tools"
sudo yum install cmake clang boost rubygems curl-devel htop \
  gettext-devel openssl-devel perl-CPAN perl-devel zlib-devel \
  curl-devel xorg-x11-xauth kernel-devel make ncurses-devel \
  bzip2-devel sqlite-devel readline readline-devel python-devel openssl \
  ruby ruby-devel lua lua-devel luajit \
  luajit-devel ctags git python python-devel \
  python3 python3-devel tcl-devel \
  perl perl-devel perl-ExtUtils-ParseXS \
  perl-ExtUtils-XSpp perl-ExtUtils-CBuilder \
  perl-ExtUtils-Embed gcc gcc-c++ \
  wget tar gzip ncurses-devel texinfo svn python-devel

# vim
## ==================================================
## wiki/Development_Environment/Vim/
sudo ln -s /usr/lib64/libpython2.7.so.1.0 /usr/lib64/libpython2.6.so.1.0
sudo yum install fb-ycm-1.1-fb4.x86_64
/usr/share/vim/vim74/bundle/YouCompleteMe/setup-ycm.sh

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
sudo yum install -y socat &&
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

# ipython
## ==================================================
## dex/ifbpy-notebook-in-a-nutshell/
ipython_setup
cd ~/fbcode
torch/fb/fbitorch/setup.sh
buck build -c fbcode.platform=gcc-4.9-glibc-2.20 deeplearning/torch:cuth


# pip
## ==================================================
mkdir -p ~/workspace

# cd ~/workspace
# git clone https://github.com/hhatto/autopep8.git
# cd autopep8
# sudo python setup.py install

cd ~/workspace
git clone https://github.com/giampaolo/psutil.git
cd psutil
sudo python setup.py install

cd ~/workspace
git clone https://github.com/google/yapf.git
cd yapf
sudo python setup.py install
