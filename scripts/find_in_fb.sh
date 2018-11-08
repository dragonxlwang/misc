#!/bin/zsh



fb_repo=$(~/misc/scripts/fb_repo_version.sh $*)

fbcode_repo="~/$fb_repo"
cconf_repo="~/configerator/source"

function join_by { local IFS="$1"; shift; echo "$*"; }

deep_fbcode_dirs=(        \
  search                  \
  nlp_tools               \
  unicorn                 \
  experimental/xlwang     \
  sigrid                  \
  fblearner               \
  caffe2                  \
  )

shallow_fbcode_dirs=()

deep_cconf_dirs=(         \
  search                  \
  nlp_tools               \
  )

shallow_cconf_dirs=(      \
  .                       \
  )

function _find {
  repo=$1
  shift
  mode=$2
  shift
  dir_num=$#
  subdirs=$(join_by ',' $@)
  if [[ $dir_num == 0 ]]; then
    return
  elif [[ $dir_num != 1 ]]; then
    subdirs="{${subdirs}}"
  fi
  if [[ $mode == "shallow" ]]; then
    eval "find ${repo}/${subdirs} -maxdepth 1 -type f"
  else
    eval "find ${repo}/$subdirs -type f"
  fi
}

_find $fbcode_repo shallow ${shallow_fbcode_dirs[@]}
_find $fbcode_repo deep ${deep_fbcode_dirs[@]}
_find $cconf_repo shallow ${shallow_cconf_dirs[@]}
_find $cconf_repo deep ${deep_cconf_dirs[@]}
find ~/misc -type f
find ~/ -maxdepth 1 -type f

