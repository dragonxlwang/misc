#!/bin/bash

ANSI_COLOR_RED="\034[31m"
ANSI_COLOR_GREEN="\033[32m"
ANSI_COLOR_RESET="\033[0m"
ANSI_COLOR_BLUE="\033[36m"
ANSI_COLOR_YELLOW="\033[33m"

root_dir=$(dirname $(dirname $(readlink -f $0)))
echo $root_dir

dst_dir="${root_dir}/cache"

## darwin & linux suite
files=(                                                                 \
  "${HOME}/.z"                      "${dst_dir}/.z"                     \
  "${HOME}/.zsh_history"            "${dst_dir}/.zsh_history"           \
  "${HOME}/.viminfo"                "${dst_dir}/.viminfo"               \
  "${HOME}/.cache/ctrlp/."          "${dst_dir}/ctrlp/"                 \
  "${HOME}/fbcode/scripts/xlwang/"  "${dst_dir}/fbcode/"                \
  "${HOME}/misc/tmp/tb"             "${dst_dir}/tb"                     \
  "${HOME}/misc/tmp/mast_exp.md"    "${dst_dir}/mast_exp.md"            \
)

mkdir -p $dst_dir

for i in $( seq 0 $(( ${#files[@]} / 2 - 1 )) );
do
  j=$(( i * 2 ))
  k=$(( j + 1 ))
  src=${files[j]}
  dst=${files[k]}
  if [[ -e $src ]] ; then
    mkdir -p $(dirname $dst)
    src_ln=$(cat $src | wc -l)
    dst_ln=$(cat $dst | wc -l)

    # cp -rL $src $dst
    echo -e $ANSI_COLOR_GREEN"cp -r $src $dst ($src_ln -> $dst_ln)"$ANSI_COLOR_RESET
  else
    echo -e $ANSI_COLOR_RED"$src file does not exists!"$ANSI_COLOR_RESET
  fi
done

cd $root_dir
git commit --verbose --all -m "dev cache sync"
git pull --rebase origin
git push origin

echo "Finished!"
