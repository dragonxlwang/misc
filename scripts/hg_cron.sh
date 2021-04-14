#!/bin/bash

# add the line below to "crontab -e"
# 0 5 * * 0 $HOME/misc/scripts/hg_cron.sh
# runs every sunday 5:00 am

function prettify() {
  while read line;
  do echo -e "[$(date +"%F %T")]: $line";
  done;
}

function hgrefresh() {
  if ! [[ -e $1 ]]; then
    echo "skip $1 because no repo exists" | prettify >> $HOME/tmp/hg_cron.out
    return
  fi
  cd $1
  if [[ -n $(hg status) ]]; then
    echo "skip $1 because status is not clean" | prettify >> $HOME/tmp/hg_cron.out
    return
  fi
  hg up master && hg pull && arc cleanup-features --force && hg up master
}

mkdir -p /tmp/$(whoami) > /dev/null 2>&1

function process() {
  echo "repo = $1" | prettify >> $HOME/tmp/hg_cron.out
  hgrefresh "$1" 2>&1 | prettify >> $HOME/tmp/hg_cron.out
}

process "$HOME/fbcode"
process "$HOME/configerator"
process "$HOME/configerator-dsi"
process "$HOME/www"
process "$HOME/www-hg"

cd "$HOME/fbcode"
buck build --show-output @mode/devo-nosan //unicorn/topaggr:top_aggregator_server

rm -rf ~/local/exp_scripts
cp -r ~/fbcode/scripts/xlwang ~/local/exp_scripts
