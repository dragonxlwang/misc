#!/bin/zsh



fb_repo=$(~/misc/scripts/fb_repo_version.sh $*)

fbcode_repo="${HOME}/$fb_repo"
cconf_repo="${HOME}/configerator/source"
tw_repo="${HOME}/configerator/raw_configs/tupperware/config"

function join_by { local IFS="$1"; shift; echo "$*"; }

deep_fbcode_dirs=(        \
  folly                   \
  dataswarm/dataswarm     \
  dataswarm-pipelines/tasks   \
  search/voyager          \
  search/sgs              \
  search/ultimate         \
  search/entities/            \
  search/posts/if             \
  search/lib/                 \
  search/dufusion         \
  search/posts/indexer    \
  search/keyword_extraction   \
  nlp_tools               \
  unicorn                 \
  experimental/xlwang     \
  sigrid                  \
  fblearner               \
  caffe2                  \
  ccif                    \
  )

shallow_fbcode_dirs=()

deep_cconf_dirs=(         \
  search                  \
  nlp_tools               \
  unicorn                 \
  )

shallow_cconf_dirs=(      \
  )

deep_tw_dirs=(            \
  search                  \
  )

shallow_tw_dirs=(       \
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
_find $tw_repo shallow ${shallow_tw_dirs[@]}
_find $tw_repo deep ${deep_tw_dirs[@]}
find $fbcode_repo/ -maxdepth 1 -type f
find $cconf_repo/ -maxdepth 1 -type f
find ~/misc -type f
find ~/ -maxdepth 1 -type f

