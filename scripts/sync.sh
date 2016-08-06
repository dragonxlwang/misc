#!/bin/bash

found=0
curpwd=$(pwd)
while [[ ! -a $(pwd)/.sync ]]; do
  cd $(dirname $(pwd))
done
exe_path="$(pwd)/.sync"
cd ${curpwd}

tmstr="\033[0;33m$(date)\033[0m  "
tmstrlen=${#tmstr}
echo -ne "$tmstr"
echo -ne "\033[0;33m"
printf "%0.s=" $( seq 1 $(( 80 - $tmstrlen )) )
echo -e "\033[0m"

for x in $(git status -s | awk '{print $2}'); do
  f=$(readlink -f $x)
  echo -e "\033[1;32muploading\033[0m $f"
  if [[ ! -a $f ]]; then
    echo -e "\033[1;31mremoved:\033[0m $f"
    continue
  fi
  $exe_path $f
done

echo -ne "\033[0;33m"
printf "%0.s=" $( seq 1 80 )
echo -e "\033[0m"
echo ""

