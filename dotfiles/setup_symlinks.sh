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
      )

num_files=${#files[@]}
num_files=$(( num_files / 2 ))
echo "building symlinks for ${1}"

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
      echo "rm ${path}/${file}"
      "rm" ${path}/${file}
      echo "ln -s ${1}/${file} ${path}/${file}"
      ln -s ${1}/${file} ${path}/${file} 
    else
      echo "skipping ${path}/${file}"
    fi
  else
    echo "ln -s ${1}/${file} ${path}/${file}"
    ln -s ${1}/${file} ${path}/${file}
  fi
done    
       
