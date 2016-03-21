#!/bin/sh
[[ $(uname) == 'Linux' ]] && { tmux new -A -D -s  $(hostname -s)-main ; }
# by setting login shell using chsh, following is not needed for atom
zsh
