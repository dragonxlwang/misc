#!/bin/sh

function install_homebrew {
  if [[ $(uname -a | awk '{ print $1 }') != "Darwin" ]]; then
    echo "Not a mac"
    exit 1
  fi

  if [[ $(uname -a | awk '{ print $NF }') == "x86_64" ]]; then
    echo "Intel-chip mac"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    exit 0
  fi


  # https://www.internalfb.com/intern/wiki/Homebrew_in_home_directory/
  echo "Apple-chip mac"
  cd ~
  mkdir homebrew
  curl -L https://github.com/Homebrew/brew/tarball/master | tar xz --strip 1 -C homebrew
  eval "$(homebrew/bin/brew shellenv)"
  brew update --force --quiet
  chmod -R go-w "$(brew --prefix)/share/zsh"
  exit 0
}

install_homebrew
cd ~/misc/scripts/
brew bundle

if [[ -e "$(brew --prefix)/opt/fzf/install" ]]; then
  $(brew --prefix)/opt/fzf/install
fi
