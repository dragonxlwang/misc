#!/bin/bash

ANSI_COLOR_RED="\033[31m"
ANSI_COLOR_GREEN="\033[32m"
ANSI_COLOR_RESET="\033[0m"
ANSI_COLOR_BLUE="\033[36m"
ANSI_COLOR_ORANGE="\033[33m"
ANSI_COLOR_YELLOW="\033[1;33m"

root_dir=$(dirname $(dirname $(readlink -f $0)))
echo -e $ANSI_COLOR_ORANGE"root_dir=$root_dir"$ANSI_COLOR_RESET
echo ""

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
    src_ln="?"
    dst_ln="?"
    if [[ -f $src ]]; then
      src_ln=$(cat $src | wc -l)
    fi
    if [[ -f $dst ]]; then
      dst_ln=$(cat $dst | wc -l)
    fi

    cp -rL $src $dst
    ln_delta=$(( ${src_ln/'?'/0} - ${dst_ln/'?'/0} ))
    if [[ $ln_delta == -* ]]; then
      ln_str=$ANSI_COLOR_RED"($dst_ln -> $src_ln, $ln_delta)"$ANSI_COLOR_RESET
    elif [[ $ln_delta == 0 ]]; then
      ln_str=$ANSI_COLOR_YELLOW"($dst_ln -> $src_ln, $ln_delta)"$ANSI_COLOR_RESET
    else
      ln_str=$ANSI_COLOR_BLUE"($dst_ln -> $src_ln, +$ln_delta)"$ANSI_COLOR_RESET
    fi
    echo -e $ANSI_COLOR_GREEN"cp -r $src $dst"$ANSI_COLOR_RESET" $ln_str"
  else
    echo -e $ANSI_COLOR_RED"$src file does not exists!"$ANSI_COLOR_RESET
  fi
done
echo ""

cd $root_dir
git commit --verbose --all -m "dev cache sync"
git pull --rebase origin
git push origin

echo ""
echo -e $ANSI_COLOR_ORANGE"Finished!"$ANSI_COLOR_RESET
