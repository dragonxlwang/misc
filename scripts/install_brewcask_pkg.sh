#!/bin/sh

# homebrew caskroom/cask
brew tap homebrew/cask
brew tap homebrew/versions
brew tap homebrew/fonts
brew tap homebrew/core

brew install graphviz

brew install xquartz
brew install dropbox google-drive google-chrome adium qq skype
brew install spotify neteasemusic inkscape gimp
brew install iterm2-beta atom filezilla the-unarchiver flux
brew install mactex bibdesk texmaker bbedit adobe-acrobat-reader mou
brew install cheatsheet suspicious-package
brew install github-desktop
brew install java tcl quip

brew install qlcolorcode
brew install qlstephen
brew install qlmarkdown
brew install quicklook-json
brew install qlprettypatch
brew install quicklook-csv
brew install betterzipql
brew install webpquicklook
brew install skim

brew install font-inconsolata
brew install font-source-code-pro
brew install font-profontx
brew install font-andale-mono
brew install font-droid-sans-mono
brew install font-dejavu-sans-mono-for-powerline
brew install font-m-plus
brew install font-clear-sans
brew install font-roboto

## brew cask install brackets nvalt libreoffice
## brew cask install sourcetree slack gisto
## brew cask install alfred Skitch

defaults write -app Skim SKAutoReloadFileUpdate -boolean true
