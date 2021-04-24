#!/bin/bash

# add the line below to "crontab -e"
# 0 5 * * 0 $HOME/misc/scripts/hg_cron.sh
# runs every sunday 5:00 am

function prettify() {
  while read line;
  do echo -e "[$(date +"%F %T")]: $line";
  done;
}

function log_event() {
  echo "$*" | prettify >> $HOME/tmp/hg_cron.out
}

function log_status() {
  if [[ $? -eq 0 ]]; then
    log_event "succeeded"
  else
    log_event "failed"
  fi
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

log_event "build unicorn ..."
cd "$HOME/fbcode"
buck build --show-output @mode/devo-nosan //unicorn/topaggr:top_aggregator_server
log_status

log_event "sync exp scripts"
rm -rf ~/local/exp_scripts && cp -r ~/fbcode/scripts/xlwang ~/local/exp_scripts
log_status


log_event "www arc fix"
cd ~/www
arc fix
log_status

log_event 'local bento'
cd ~/fbcode
 ./search/typeahead/scripts/local_bento.sh
 log_status
