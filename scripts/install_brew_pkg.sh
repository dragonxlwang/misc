#!/bin/sh

# homebrew
sudo chown $(whoami):admin /usr/local \
  && sudo chown -R $(whoami):admin /usr/local
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

brew tap homebrew/dupes
brew tap homebrew/python
brew tap homebrew/science
brew tap homebrew/versions

brew install coreutils # set mv by symlink
brew install binutils diffutils
brew install ed --with-default-names
brew install findutils --with-default-names
brew install gnu-indent --with-default-names
brew install gnu-sed --with-default-names
brew install gnu-tar --with-default-names
brew install gnu-which --with-default-names
brew install grep --with-default-names
brew install wdiff --with-gettext
brew install lua --with-completion
brew install tmux curl clang-format tree
brew install htop --with-ncurses
brew install gnuplot --with-tex --with-pdflib-lite --with-qt --with-test --with-x11
brew install make --with-default-names
brew install hub gawk ascii_plots gzip screen watch wget pigz fpp
brew install gcc node reattach-to-user-namespace zsh-completions ctags cmake
brew install emacs gdb gpatch m4 nano markdown pandoc
brew install file-formula git gist bfg less openssh perl518 rsync svn unzip
brew install macvim --with-lua --with-override-system-vim
brew linkapps macvim

## brew install vim --override-system-vi
## brew install zsh
## brew install zsh-syntax-highlighting

brew install pwgen gmp libtool pdflib-lite smpeg sqlite llvm mpfr
brew install freetype fontconfig isl jpeg readline xz libevent openssl
brew install boost boost-build pkg-config gnutls gnu-getopt go
brew install webp --with-libtiff
brew install ffmpeg
brew install gifsicle --with-x11
brew install imagemagick --with-x11 --with-webp --with-librsvg

## python
brew install python
brew linkapps python
brew install numpy scipy
brew install matplotlib --with-tex --with-tcl-tk
brew install matplotlib-basemap numba pillow pygame
