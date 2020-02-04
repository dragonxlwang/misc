#!/bin/bash

# add the line below to "crontab -e"
# 0 3 * * 0 $HOME/misc/scripts/hg_cron.sh
# runs every sunday 3:00 am

function prettify() {
  while read line;
  do echo -e "[$(date +"%F %T")]: $line";
  done;
}

function hgrefresh() {
  cd $1
  hg up master && hg pull && arc cleanup-features --force && hg up master
}

mkdir -p /tmp/$(whoami) > /dev/null 2>&1

function process() {
  echo "repo = $1" | prettify >> $HOME/tmp/hg_cron.out
  hgrefresh "$HOME/fbcode" 2>&1 | prettify >> $HOME/tmp/hg_cron.out
}

process "$HOME/fbcode"
process "$HOME/configerator"
process "$HOME/configerator-dsi"
