#!/usr/bin/env zsh
misc_dir="$(dirname $(dirname $(readlink -f $0)))"
if [[ $1 == cpu ]]; then
  [[ -r $misc_dir/tmp/cpu.txt ]] && cat $misc_dir/tmp/cpu.txt
  $misc_dir/scripts/cpu_mem_lookup.py cpu > $misc_dir/tmp/cpu.txt
elif [[ $1 == mem ]]; then
  [[ -r $misc_dir/tmp/mem.txt ]] && cat $misc_dir/tmp/mem.txt
  $misc_dir/scripts/cpu_mem_lookup.py mem > $misc_dir/tmp/mem.txt
fi
