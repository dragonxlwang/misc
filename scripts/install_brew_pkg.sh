#!/bin/sh

# homebrew
# sudo chown $(whoami):admin /usr/local \
#   && sudo chown -R $(whoami):admin /usr/local

# sudo chown -R $(whoami):admin /usr/local
sudo chown -R $(whoami) $(brew --prefix)/*
sudo chown -R $(whoami) /usr/local/lib /usr/local/sbin
chmod u+w /usr/local/lib /usr/local/sbin

/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

# brew tap homebrew/dupes
# brew tap homebrew/python@2
# brew tap homebrew/science
# brew tap homebrew/versions

brew install coreutils # set mv by symlink
brew install binutils
brew install diffutils
brew install ed
brew install findutils
brew install gnu-indent
brew install gnu-sed
brew install gnu-tar
brew install gnu-which
brew install grep
brew install wdiff # --with-gettext
brew install lua # --with-completion
brew link lua

for app in mosh tmux curl clang-format tree fzf ag;
do
  brew install $app
done

brew install htop # --with-ncurses
brew install gnuplot # --with-tex --with-pdflib-lite --with-qt --with-test --with-x11
brew install make # --with-default-names
brew install geos

for app in hub gawk ascii_plots gzip screen watch wget pigz fpp \
           gcc node reattach-to-user-namespace zsh-completions ctags cmake \
           emacs gdb gpatch m4 nano markdown pandoc \
           file-formula git gist bfg less openssh perl518 rsync svn unzip autojump;
do
  brew install $app
done

brew install macvim # --with-lua --with-override-system-vim
# brew linkapps macvim

## brew install vim --override-system-vi
## brew install zsh
## brew install zsh-syntax-highlighting

for app in pwgen gmp libtool pdflib-lite smpeg sqlite llvm mpfr \
           freetype fontconfig isl jpeg readline xz libevent openssl \
           boost boost-build pkg-config gnutls gnu-getopt go \
do
  brew install $app
done

brew install webp # --with-libtiff
brew install ffmpeg
brew install gifsicle # --with-x11
brew install imagemagick # --with-x11 --with-webp --with-librsvg

## python
brew install python
# brew linkapps python
pip2 install --upgrade pip setuptools
# ln -s /usr/local/opt/python/libexec/bin/python /usr/local/bin/python
# ln -s /usr/local/bin/pip2 /usr/local/bin/pip
brew install matplotlib-basemap numba pillow pygame

# fzf
/usr/local/opt/fzf/install
