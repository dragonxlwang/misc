#!/bin/sh
if [[ $# -eq 0 ]]; then
  brew rm python
  brew rm macvim
  brew cleanup

  brew install python --force
  brew linkapps python
  brew install macvim --with-lua --with-override-system-vim --force
  brew linkapps macvim
  brew cleanup
fi

if [[ $1 == 'make' ]]; then
  vim +PluginClean +qall
  vim +PluginInstall +qall
  vim +PluginClean +qall

  cd ~/.vim/bundle/YouCompleteMe
  ./install.py --clang-completer
  cd ~/.vim/bundle/color_coded
  mkdir build && cd build
  cmake ..
  make && make install # Compiling with GCC is preferred, ironically
  # Clang works on OS X, but has mixed success on Linux and the BSDs

  # Cleanup afterward; frees several hundred megabytes
  make clean && make clean_clang
fi
