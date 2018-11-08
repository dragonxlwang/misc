#!/bin/zsh

if [[ $# != 0 ]]; then
  if [[ -f $1 ]]; then
    dest=$(dirname $1)
  else
    dest=$1
  fi
  pushd $dest 2>/dev/null 1>&2
fi

HG_ROOT=$(hg root 2>/dev/null)
fb_version=""
if [[ "${HG_ROOT#*fbsource2}" != "$HG_ROOT" ]]; then
  fb_version="2"
elif [[ "${HG_ROOT#*fbsource3}" != "$HG_ROOT" ]]; then
  fb_version="3"
fi

echo fbcode$fb_version
popd 2>/dev/null 1>&2
