#!/bin/sh

# xcode
xcode-select --install

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
brew install hub gawk ascii_plots gzip screen watch wget pigz
brew install gcc node reattach-to-user-namespace zsh-completions
brew install emacs gdb gpatch m4 nano

brew install file-formula git less openssh perl518 rsync svn unzip
## brew install vim --override-system-vi
## brew install macvim --override-system-vim --custom-system-icons
##brew install zsh

brew install pwgen gmp libtool pdflib-lite smpeg sqlite llvm mpfr
brew install freetype fontconfig isl jpeg readline xz libevent openssl
brew install boost boost-build pkg-config gnutls gnu-getopt go
brew install webp --with-libtiff

## python
brew install python
brew install numpy scipy
brew install matplotlib --with-tex --with-tcl-tk
brew install matplotlib-basemap numba pillow pygame ffmpeg
pip install --upgrade pip
pip install "ipython[all]" --upgrade --force-reinstall
sudo -H pip install -U nltk
## python -m nltk.downloader all
pip install -U jupyter
pip install -U flake8
pip install -U pep8
pip install -U autopep8
pip install -U yapf
pip install -U jedi

# oh-my-zsh
sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

# zsh set to default shell
# User & Groups -> Advanced Options -> Login Shell
# http://apple.stackexchange.com/questions/88278/change-default-shell-from-bash-to-zsh
chsh -s $(which zsh)

# completion initialize
/bin/rm -rfv ~/.zcompdump
compinit

###########################################
# Following needs to be executed manually #
###########################################

# set mv by symlink
## cd /usr/local/bin
## ln -s gmv mv

# one time config for inline matplotlib:
# http://stackoverflow.com/questions/19410042/how-to-make-ipython-notebook-matplotlib-plot-inline
## cat "c = get_config()" >> /Users/xiaolong/.ipython/profile_default
## cat 'c.InteractiveShellApp.matplotlib = "inline"' \
## >> /Users/xiaolong/.ipython/profile_default

# install atom
## atom_install_starred

# iterm map keys
# ^[ escape sequence
## opt <-: send ^[ B
## opt ->: send ^[ F
