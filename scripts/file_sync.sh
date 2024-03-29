#!/bin/bash

ANSI_COLOR_RED="\034[31m"
ANSI_COLOR_GREEN="\033[32m"
ANSI_COLOR_RESET="\033[0m"
ANSI_COLOR_BLUE="\033[36m"
ANSI_COLOR_YELLOW="\033[33m"

root_dir=$(dirname $(dirname $(greadlink -f $0)))/dotfiles
[[ $? -ne 0 ]] && root_dir=$(dirname $(dirname $(readlink -f $0)))/dotfiles

echo $root_dir


dst_dir="${root_dir}/lib/cache"

## darwin & linux suite
files=(                                                                 \
  "${HOME}/.z"                      "${dst_dir}/.z"                     \
  "${HOME}/.zsh_history"            "${dst_dir}/.zsh_history"           \
  "${HOME}/.viminfo"                "${dst_dir}/.viminfo"               \
  "${HOME}/.cache/ctrlp/."          "${dst_dir}/.cache.ctrlp/"          \
  "${HOME}/fbcode/scripts/xlwang/." "${dst_dir}/fbcode_exp/"            \
)

mkdir -po $dst_dir

for i in $( seq 0 $(( ${#files[@]} / 2 - 1 )) );
do
  j=$(( i * 2 ))
  k=$(( j + 1 ))
  src=${files[j]}
  dst=${files[k]}
  if [[ -e $src ]] ; then
    mkdir -p $(dirname $dst)
    cp -rL $src $dst
    echo -e $ANSI_COLOR_GREEN"cp -r $src $dst"$ANSI_COLOR_RESET
  else
    echo -e $ANSI_COLOR_RED"$src file does not exists!"$ANSI_COLOR_RESET
  fi
done

echo "Finished!"
