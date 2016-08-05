#!/bin/bash

found=0
curpwd=$(pwd)
while [[ ! -a $(pwd)/.sync ]]; do
  cd $(dirname $(pwd))
done
exe_path="$(pwd)/.sync"
cd ${curpwd}

for x in $(git status -s | awk '{print $2}'); do
  echo $(readlink -f $x)
  $exe_path $(readlink -f $x)
done

