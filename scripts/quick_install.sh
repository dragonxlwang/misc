#!/usr/bin/env zsh

# Ask for the administrator password upfront
sudo -v
# xcode
xcode-select --install

local basedir=$(dirname "$0")

# source $basedir/install_brew_pkg.sh
# source $basedir/install_brewcask_pkg.sh
source $basedir/install_homebrew.sh
source $basedir/install_pip_pkg.sh

wget https://gist.githubusercontent.com/baopham/1838072/raw/616d338cea8b9dcc3a5b17c12fe3070df1b738c0/Monaco%2520for%2520Powerline.otf -O ~/Library/Fonts/"Monaco for Powerline.otf"

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

# set symlink
## cd /usr/local/bin
## ln -s gmv mv
## ln -s greadlink readlink
## ln -s mvim vvim
## ln -s gls ls

# vim vundle
# git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim

# ipython default profile create:
# https://ipython.org/ipython-doc/3/config/intro.html
# ipython profile create [profilename]
# one time config for inline matplotlib:
# http://stackoverflow.com/questions/19410042/how-to-make-ipython-notebook-matplotlib-plot-inline
# http://stackoverflow.com/questions/21176731/automatically-run-matplotlib-inline-in-ipython-notebook
## cat "c = get_config()" >> ~/.ipython/profile_default/ipython_kernel_config.py
## cat 'c.InteractiveShellApp.matplotlib = "inline"' \
  ## >> ~/.ipython/profile_default/ipython_kernel_config.py

# show hidden files by default
## defaults write com.apple.finder AppleShowAllFiles YES
## killall Finder

# install atom
## atom_install_starred

# iterm map keys
# ^[ escape sequence
## opt <-: send ^[ B
## opt ->: send ^[ F
# Left option key acts as: +Esc

##############################
# Upgrade and reinstall tips #
##############################

# brew
# https://github.com/Homebrew/homebrew/blob/master/share/doc/homebrew/FAQ.md
# upgrade
## brew upgrade "<package>"
# uninstall/delete
## brew uninstall "<package>" --force
# old versions of a formula
## brew cleanup "<package>"
## brew reinstall --force "<package>"

# brew cask
# upgrade
## brew cask list | xargs brew cask install --force
# uninstall: uninstall and remove symlinks in ~/Applications.
## brew cask uninstall "<package>"
# uninstall all versions of a Cask
## brew cask uninstall --force "<package>"
# update workflow
## brew update; brew cleanup; brew cask cleanup

# apm manual upgrade
## for f in $(atom_ls_installed_packages); do
##   f=$(echo $f | sed -r 's/@.*//');
##   echo $f;
##   apm upgrade $f;
##   [[ $? -ne 0 ]] && echo $f >> err.txt;
## done

# pip upgrade (do not use as it conflicts with homebrew)
## pip install --upgrade --force-reinstall "<package>"
## pip install --upgrade --no-deps --force-reinstall "<package>"
## pip freeze --local | grep -v '^\-e' | cut -d = -f 1  | xargs -n1 pip install -U
## pip uninstall "<package>"

#############
# et cetera #
#############

# mac show hidden files
# defaults write com.apple.finder AppleShowAllFiles YES

# Python on mac
# Homebrew python: https://github.com/Homebrew/homebrew-python
## brew tap homebrew/python
## brew install python
## brew install numpy scipy matplotlib matplotlib-basemap
## brew install numba pillow pygame
## brew install ffmpeg
## sudo pip uninstall ipython
## pip install ipython
# Or alternatively, https://gitter.im/ipython/ipython/help/archives/2015/04/16
## sudo pip install "ipython[all]" --upgrade --force-reinstall
## sudo pip install -U nltk
## python -m nltk.downloader all
## sudo -H pip install --upgrade matplotlib

# pip utilities
## for f in $(pip list); do echo $f; done
## for f in $(pip list); do
##   [[ $f != "("* ]] && {echo -n $f" "; pip show $f | grep "Location"};
## done
## for f in $(pip list); do
##   [[ $f != "("* ]] && { s=$(pip show $f | grep "Location");
##       [[ -n $(echo $s | grep "Library") ]] && {echo $f >> tmp.txt}; }
## done
## for f in $(cat tmp.txt); do echo $f; sudo pip uninstall $f; done
## for f in $(cat tmp.txt); do
##   echo $ANSI_COLOR_RED$f$ANSI_COLOR_RESET;
##   pip install --upgrade --force-reinstall $f;
## done

# ipython
# sudo easy_install ipython
# brew install pkg-config
# brew install freetype
# brew install pnglib
# sudo -H easy_install matplotlib
# sudo -H pip install jupyter
#
# one time config for inline matplotlib:
# http://stackoverflow.com/questions/19410042/how-to-make-ipython-notebook\
  # -matplotlib-plot-inline
# cat "c = get_config()" >> /Users/xiaolong/.ipython/profile_default
# cat 'c.InteractiveShellApp.matplotlib = "inline"' \
  # >> /Users/xiaolong/.ipython/profile_default

# Homebrew permission problem
## sudo chown $(whoami):admin /usr/local \
  ##  && sudo chown -R $(whoami):admin /usr/local
## brew install coreutils

# gdb
# curl -L https://raw.githubusercontent.com/gdbinit/Gdbinit/master/gdbinit -o ~/.gdbinit
