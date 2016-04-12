#!/usr/bin/env zsh
misc_dir="$(dirname $(dirname $(readlink -f $0)))"

function is_osx { [[ $(uname) == 'Darwin' ]]; }
function is_linux { [[ $(uname) == 'Linux' ]]; }
function need_update {
  if [ -f "$1" ]; then
    if is_osx; then
      stat >/dev/null 2>&1 && { last_update=$(stat -f "%m" $1); }\
        || { last_update=$(stat -c "%Y" $1) }
    elif is_linux; then
      last_update=$(stat -c "%Y" $1)
    fi
    time_now=$(date +%s)
    update_period=$2
    u2d=$(echo "(${time_now}-${last_update}) < ${update_period}" | bc)
    return u2d
  fi
}

if [[ $1 == cpu ]]; then
  f=$misc_dir/tmp/cpu.txt
  [[ -r $f ]] && cat $f
  if need_update $f 5; then
    $misc_dir/scripts/cpu_mem_lookup.py cpu > $f
  fi
elif [[ $1 == mem ]]; then
  f=$misc_dir/tmp/mem.txt
  [[ -r $f ]] && cat $f
  if need_update $f 5; then
    $misc_dir/scripts/cpu_mem_lookup.py mem > $misc_dir/tmp/mem.txt
  fi
fi
