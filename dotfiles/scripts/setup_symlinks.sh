#!/bin/bash

ANSI_COLOR_RED="\033[31m"
ANSI_COLOR_GREEN="\033[32m"
ANSI_COLOR_RESET="\033[0m"
ANSI_COLOR_BLUE="\033[36m"

root_dir=$(dirname $PWD)

if [[ $# -ne 1 ]]; then
  echo "specify which set of rules to apply"
  echo "use mac or timan"
  exit 1
else
  echo "building symlinks for ${1}"
fi

mk_link() {
  src=$1
  des=$2
  if [[ -a $des ]];
  then
    echo -n "${des} already existed. Do you want to overwrite? [Y/N] "
    read ans
    ans=$(echo $ans | tr '[:upper:]' '[:lower:]')
    if [[ $ans == yes || $ans == y ]]
    then
      echo -e $ANSI_COLOR_RED "rm ${des}" $ANSI_COLOR_RESET
      rm -rf ${des}
      echo -e  $ANSI_COLOR_RED "ln -s ${scr} ${des}" $ANSI_COLOR_RESET
      ln -s ${scr} ${des}
    else
      echo -e $ANSI_COLOR_BLUE "skipping ${des}" $ANSI_COLOR_RESET
    fi
  else
    echo -e $ANSI_COLOR_GREEN "ln -s ${scr} ${des}" $ANSI_COLOR_RESET
    ln -s ${scr} ${des}
  fi
}

## mac/timan suite
files=(	".bash_profile"       "${HOME}"	\
        "config"              "${HOME}/.ssh"  \
        ".gitconfig"          "${HOME}"	\
        "ls_colors.zsh"       "${HOME}"	\
        ".profile_wangxl"     "${HOME}"	\
        ".tmux.conf"	        "${HOME}"	\
        ".zshrc"	            "${HOME}"
      )
for i in $( seq 0 $(( ${#files[@]} / 2 - 1 )) );
do
  j=$(( i * 2 ))
  k=$(( j + 1 ))
  file=${files[j]}
  path=${files[k]}
  scr="$root_dir/${1}/${file}"
  des="${path}/${file}"
  mk_link $scr $des
done

## mac suite: atom
if [[ $1 == "mac" ]];
then
  for f in $(ls "$root_dir/mac/.atom");
  do
    scr="$root_dir/mac/.atom/$f"
    des="${HOME}/.atom/$f"
    mk_link $scr $des
  done
fi

## mac & timan suite
files=( "$root_dir/lib/ys.zsh-theme" \
        "${HOME}/.oh-my-zsh/custom/themes/ys.zsh-theme" \
        "$root_dir/lib/.vimrc" \
        "${HOME}/.vimrc")
for i in $( seq 0 $(( ${#files[@]} / 2 - 1 )) );
do
  j=$(( i * 2 ))
  k=$(( j + 1 ))
  scr=${files[j]}
  des=${files[k]}
  mk_link $scr $des
done

echo "Finished!"
