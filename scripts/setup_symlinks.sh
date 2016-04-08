#!/bin/bash

ANSI_COLOR_RED="\033[31m"
ANSI_COLOR_GREEN="\033[32m"
ANSI_COLOR_RESET="\033[0m"
ANSI_COLOR_BLUE="\033[36m"

root_dir=$(dirname $(dirname $(readlink -f $0)))/dotfiles

if [[ ${1:l} != "mac" && ${1:l} != "timan" ]]; then
  echo "specify which set of rules to apply"
  echo "use mac or timan"
  exit 1
else
  echo "building symlinks for ${1}"
fi

no_confirm=0
[[ ${2:l} == '--no-confirm' ]] && no_confirm=1

cnt=0

mk_link() {
  src=$1
  des=$2
  cnt=$((cnt + 1))
  if [[ -e $des || -L $des ]];
  then
    echo -n "${des} already existed. Do you want to overwrite? [Y/N] "
    [[ $no_confirm -eq 1 ]] && {  ans="yes"; echo ""; } || read ans
    ans=$(echo $ans | tr '[:upper:]' '[:lower:]')
    if [[ $ans == yes || $ans == y ]]
    then
      echo -e $ANSI_COLOR_RED "[$cnt]: rm ${des}" $ANSI_COLOR_RESET
      rm -rf ${des}
      echo -e  $ANSI_COLOR_RED "[$cnt]: ln -s ${scr} ${des}" $ANSI_COLOR_RESET
      ln -s ${scr} ${des}
    else
      echo -e $ANSI_COLOR_BLUE "[$cnt]: skipping ${des}" $ANSI_COLOR_RESET
    fi
  else
    echo -e $ANSI_COLOR_GREEN "[$cnt]: ln -s ${scr} ${des}" $ANSI_COLOR_RESET
    ln -s ${scr} ${des}
  fi
}

## mac/timan suite
files=(".zshrc"         "${HOME}")
if [[ ${#files[@]} -gt 0 ]]; then
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
fi

## mac suite: gnu coreutils and atom
bins=("mv" "readlink" "ls" "du")
if [[ $1 == "mac" ]];
then
  for f in $(ls "$root_dir/mac/.atom");
  do
    scr="$root_dir/mac/.atom/$f"
    des="${HOME}/.atom/$f"
    mk_link $scr $des
  done
  echo -e $ANSI_COLOR_GREEN "setting up /usr/local symlinks" $ANSI_COLOR_RESET
  for b in "${bins[@]}"
  do
    echo -e $ANSI_COLOR_BLUE "$b -> g$b" $ANSI_COLOR_RESET
    if [[ -e /usr/local/bin/$b ]]; then
      echo "==> bin symlink: skipping, $b exist"
    elif [[ ! -e /usr/local/bin/g$b ]]; then
      echo "==> bin symlink: skipping, g$b doesn't exist"
    else
      ln -s /usr/local/bin/g$b /usr/local/bin/$b
      echo "==> bin symlink: $b -> g$b"
    fi
    if [[ -e /usr/local/man/man1/$b.1 ]]; then
      echo "==> man symlink: skipping, $b exist"
    elif [[ ! -e /usr/local/opt/coreutils/libexec/gnuman/man1/$b.1 ]]; then
      echo "==> man symlink: skipping, $b doesn't exist"
    else
      ln -s /usr/local/opt/coreutils/libexec/gnuman/man1/$b.1 \
            /usr/local/man/man1/$b.1
      echo "==> man symlink: $b -> g$b"
    fi
  done
fi

## mac & timan suite
files=( "$root_dir/lib/ys.zsh-theme"                      \
        "${HOME}/.oh-my-zsh/custom/themes/ys.zsh-theme"   \
        "$root_dir/lib/.vimrc"            "${HOME}/.vimrc"              \
        "$root_dir/lib/.gitconfig"        "${HOME}/.gitconfig"        	\
        "$root_dir/lib/config"            "${HOME}/.ssh/config"         \
        "$root_dir/lib/ls_colors.zsh"     "${HOME}/ls_colors.zsh"       \
        "$root_dir/lib/.profile_wangxl"   "${HOME}/.profile_wangxl"	    \
        "$root_dir/lib/.bash_profile"     "${HOME}/.bash_profile"	      \
        "$root_dir/lib/.bashrc"           "${HOME}/.bashrc"	            \
        "$root_dir/lib/.tmux.conf"	      "${HOME}/.tmux.conf" )

for i in $( seq 0 $(( ${#files[@]} / 2 - 1 )) );
do
  j=$(( i * 2 ))
  k=$(( j + 1 ))
  scr=${files[j]}
  des=${files[k]}
  mk_link $scr $des
done

echo "Finished!"
