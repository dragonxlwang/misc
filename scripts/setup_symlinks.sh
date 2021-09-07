#!/bin/bash

ANSI_COLOR_RED="\033[31m"
ANSI_COLOR_GREEN="\033[32m"
ANSI_COLOR_RESET="\033[0m"
ANSI_COLOR_BLUE="\033[36m"
ANSI_COLOR_YELLOW="\033[33m"

root_dir=$(dirname $(dirname $(greadlink -f $0)))/dotfiles
[[ $? -ne 0 ]] && root_dir=$(dirname $(dirname $(greadlink -f $0)))/dotfiles

if [[ ${1:l} != "darwin" && ${1:l} != "linux" ]]; then
  echo "specify which set of rules to apply"
  echo "use darwin or linux"
  exit 1
else
  echo "building symlinks for ${1}"
fi

no_confirm=0
[[ ${2:l} == '--no-confirm' ]] && no_confirm=1

cnt=0

mk_link() {
  src=$1
  des=$2
  cnt=$((cnt + 1))
  if [[ ! -e ${src} ]]; then
    echo -e $ANSI_COLOR_YELLOW "[$cnt]: ${src} does not exist!" \
      $ANSI_COLOR_RESET
    return 1
  fi
  mkdir -p $(dirname $des)
  if [[ -e $des || -L $des ]];
  then
    echo -n "${des} already existed. Do you want to overwrite? [Y/N] "
    [[ $no_confirm -eq 1 ]] && {  ans="yes"; echo ""; } || read ans
    ans=$(echo $ans | tr '[:upper:]' '[:lower:]')
    if [[ $ans == yes || $ans == y ]]
    then
      echo -e $ANSI_COLOR_RED "[$cnt]: rm ${des}" $ANSI_COLOR_RESET
      rm -rf "${des}"
      echo -e  $ANSI_COLOR_RED "[$cnt]: ln -s ${src} ${des}" $ANSI_COLOR_RESET
      ln -s "${src}" "${des}"
    else
      echo -e $ANSI_COLOR_BLUE "[$cnt]: skipping ${des}" $ANSI_COLOR_RESET
    fi
  else
    echo -e $ANSI_COLOR_GREEN "[$cnt]: ln -s ${src} ${des}" $ANSI_COLOR_RESET
    ln -s "${src}" "${des}"
  fi
}

## darwin suite: gnu coreutils and atom
bins=("mv" "readlink" "ls" "du")
if [[ $1 == "darwin" ]];
then
  for f in $(ls "$root_dir/darwin/.atom");
  do
    src="$root_dir/darwin/.atom/$f"
    des="${HOME}/.atom/$f"
    mk_link $src $des
  done
  mk_link ${HOME}/Dropbox\ \(Personal\) ${HOME}/Dropbox
  echo -e $ANSI_COLOR_GREEN "setting up /usr/local symlinks" $ANSI_COLOR_RESET
  for b in "${bins[@]}"
  do
    echo -e $ANSI_COLOR_BLUE "$b -> g$b" $ANSI_COLOR_RESET
    if [[ -e /usr/local/bin/$b ]]; then
      echo "==> bin symlink: skipping, $b exist"
    elif [[ ! -e /usr/local/bin/g$b ]]; then
      echo "==> bin symlink: skipping, g$b doesn't exist"
    else
      ln -s /usr/local/bin/g$b /usr/local/bin/$b
      echo "==> bin symlink: $b -> g$b"
    fi
    if [[ -e /usr/local/man/man1/$b.1 ]]; then
      echo "==> man symlink: skipping, $b exist"
    elif [[ ! -e /usr/local/opt/coreutils/libexec/gnuman/man1/$b.1 ]]; then
      echo "==> man symlink: skipping, $b doesn't exist"
    else
      ln -s /usr/local/opt/coreutils/libexec/gnuman/man1/$b.1 \
        /usr/local/man/man1/$b.1
      echo "==> man symlink: $b -> g$b"
    fi
  done
fi

## darwin/linux suite
files=(                                                           \
  "$root_dir/lib/.bashrc"               "${HOME}/.bashrc"         \
  "$root_dir/lib/.gitconfig"            "${HOME}/.gitconfig")
if [[ ${#files[@]} -gt 0 ]]; then
  for i in $( seq 0 $(( ${#files[@]} / 2 - 1 )) );
  do
    j=$(( i * 2 ))
    k=$(( j + 1 ))
    file=${files[j]}
    path=${files[k]}
    src="${file}_${1}"
    des="${path}"
    mk_link $src $des
  done
fi

## system suite
if [[ $(uname) == Darwin ]]; then
  mk_link $root_dir/lib/ssh-config-darwin \
    ${HOME}/.ssh/config
elif [[ $(rpm -q --queryformat '%{VERSION}' centos-release) == 6* ]]; then
  mk_link $root_dir/lib/ssh-config-centos6 \
    ${HOME}/.ssh/config
elif [[ $(rpm -q --queryformat '%{VERSION}' centos-release) == 7* ]]; then
  mk_link $root_dir/lib/ssh-config-centos7 \
    ${HOME}/.ssh/config
fi

if [[ $(uname) == Linux ]]; then
  mk_link /tmp/$USER ${HOME}/tmp
fi

[[ $(tmux -V) == *2.2 ]] && \
  tmux_conf=".tmux.v2.2.conf" || tmux_conf=".tmux.conf"
tmux_conf="$root_dir/lib/"$tmux_conf

## darwin & linux suite
mkdir -p ${HOME}/.oh-my-zsh/custom/themes/
files=(                                                           \
  "$root_dir/lib/ys.zsh-theme"                                    \
  "${HOME}/.oh-my-zsh/custom/themes/ys.zsh-theme"                 \
  "$root_dir/lib/.vimrc"            "${HOME}/.vimrc"              \
  "$root_dir/lib/ls_colors.zsh"     "${HOME}/ls_colors.zsh"       \
  "$root_dir/lib/.profile_wangxl"   "${HOME}/.profile_wangxl"     \
  "$root_dir/lib/.bash_profile"     "${HOME}/.bash_profile"       \
  "$tmux_conf"                      "${HOME}/.tmux.conf"          \
  "$root_dir/lib/.zshrc"            "${HOME}/.zshrc"              \
  "$root_dir/lib/.hgrc"             "${HOME}/.hgrc"               \
  "$root_dir/lib/flake8"            "${HOME}/.config/flake8"      \
  "$root_dir/lib/.hgignore"         "${HOME}/.hgignore"           \
  "$root_dir/lib/.edenrc"           "${HOME}/.edenrc"             \
  "$root_dir/lib/.gdbinit"          "${HOME}/.gdbinit"            \
  "$root_dir/lib/.ycm_extra_conf.py"    "${HOME}/.vim/.ycm_extra_conf.py"     \
  "$root_dir/lib/.ycm_extra_conf.py"    "${HOME}/fbcode/.ycm_extra_conf.py"   \
  "${HOME}/fbsource/fbcode"         "${HOME}/fbcode"              \
  "${HOME}/local/configerator"      "${HOME}/configerator"        \
  "${HOME}/local/notebooks"         "${HOME}/notebooks"           \
  "${HOME}/local/.cache"            "${HOME}/.cache"              \
  "${HOME}/local/vim-sessions"      "${HOME}/vim-sessions"        \
  "$root_dir/lib/bento_notebook.json"                             \
  "${HOME}/local/.bento/jupyter/nbconfig/notebook.json"
)

for i in $( seq 0 $(( ${#files[@]} / 2 - 1 )) );
do
  j=$(( i * 2 ))
  k=$(( j + 1 ))
  src=${files[j]}
  des=${files[k]}
  mk_link $src $des
done

echo "Finished!"
