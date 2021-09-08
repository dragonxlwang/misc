#!/bin/zsh

repo=$(basename $(hg root))
viml="${HOME}/misc/tmp/${repo}_fpp.viml"
viml_script=""
first_file="$1"
for f in "${@:2}"
do
  viml_script+="vs $f\n"
done
viml_script+="ReorgBuf"
echo "\"vs $first_file" > $viml
echo $viml_script >> $viml

vim $first_file -S $viml

