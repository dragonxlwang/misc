#!/bin/bash

files=(	".bash_profile"       "${HOME}"	\
        "config"              "${HOME}/.ssh"  \
        ".gitconfig"          "${HOME}"	\
        "ls_colors.zsh"       "${HOME}"	\
        ".profile_wangxl"     "${HOME}"	\
        ".tmux.conf"	        "${HOME}"	\
        ".vimrc"              "${HOME}" \
        "ys.zsh-theme"        "${HOME}/.oh-my-zsh/themes" \
        ".zshrc"	            "${HOME}"	\
        ".vim/colors"         "${HOME}"
      )

if [[ $# -ne 1 ]]; then
  echo "specify which set of rules to apply"
  echo "use mac or timan"
  exit 1
else
  echo "building symlinks for ${1}"
fi

num_files=${#files[@]}
num_files=$(( num_files / 2 ))

ANSI_COLOR_RED="\033[31m"
ANSI_COLOR_GREEN="\033[32m"
ANSI_COLOR_RESET="\033[0m"
ANSI_COLOR_BLUE="\033[36m"

for i in $( seq 0 $((num_files - 1)) );
do
  j=$(( i * 2 ))
  k=$(( j + 1 ))
  file=${files[j]}
  path=${files[k]}
  if [[ -e ${path}/${file} ]]; 
  then
    echo -n "${path}/${file} already existed. Do you want to overwrite? [Y/N] "
    read ans
    ans=$(echo $ans | tr '[:upper:]' '[:lower:]')
    if [[ $ans == yes || $ans == y ]]
    then
      echo -e $ANSI_COLOR_RED "rm ${path}/${file}" $ANSI_COLOR_RESET 
      rm -rf ${path}/${file}
      echo -e  $ANSI_COLOR_RED "ln -s $PWD/${1}/${file} ${path}/${file}" $ANSI_COLOR_RESET
      ln -s $PWD/${1}/${file} ${path}/${file} 
    else
      echo -e $ANSI_COLOR_BLUE "skipping $PWD/${1}/${file}" $ANSI_COLOR_RESET
    fi
  else
    echo -e $ANSI_COLOR_GREEN "ln -s $PWD/${1}/${file} ${path}/${file}" $ANSI_COLOR_RESET
    ln -s $PWD/${1}/${file} ${path}/${file}
  fi
done    

if [[ $1 == "mac" ]];
then
  for f in $(ls "mac/.atom");
  do
    if [[ -e ${HOME}/.atom/$f ]];
    then
      echo -n "${HOME}/.atom/$f already existed. Do you want to overwrite? [Y/N] "
      read ans
      ans=$(echo $ans | tr '[:upper:]' '[:lower:]')
      if [[ $ans == "yes" || $ans == "y" ]];
      then
        echo -e $ANSI_COLOR_RED "rm ${HOME}/.atom/$f" $ANSI_COLOR_RESET 
        rm -rf ${HOME}/.atom/$f
        echo -e $ANSI_COLOR_RED "ln -s $PWD/mac/.atom/$f ${HOME}/.atom/$f" $ANSI_COLOR_RESET
        ln -s $PWD/mac/.atom/$f ${HOME}/.atom/$f
      else
        echo -e $ANSI_COLOR_BLUE "skipping $PWD/mac/.atom/$f" $ANSI_COLOR_RESET
      fi
    else
      echo -e $ANSI_COLOR_BLUE "ln -s $PWD/mac/.atom/$f ${HOME}/.atom/$f" $ANSI_COLOR_RESET
      ln -s $PWD/mac/.atom/$f ${HOME}/.atom/$f
    fi
  done
fi
       
