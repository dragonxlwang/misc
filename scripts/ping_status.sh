#!/usr/bin/env bash

misc_dir="$(dirname $(dirname $(readlink -f $0)))"
f=$misc_dir/tmp/ping_$(hostname).txt
client_ip=$(echo $SSH_CLIENT | cut -sd ' ' -f 1 -)

function update_ping() {
  local report=$(ping6 -c 10 -w 10 $client_ip)
  echo "$report" > $f
}

if [[ -z $SSH_CLIENT ]] || ! [[ $(hostname) =~ 'dev' ]];
then
  exit
fi

if ! [[ -e $f ]];
then
  update_ping
  exit
fi

avg_ping=$(cut -sd / -f 5 $f | cut -d . -f 1)
stdev_ping=$(cut -sd / -f 7 $f | cut -d . -f 1)
ctime=$(stat -c %Z $f)
mtime=$(stat -c %Y $f)
now=$(date +%s)
interval=120

if [[ $now -gt $(( $mtime + $interval )) ]] && [[ $now -gt $(( $ctime + $interval )) ]];
then
  update_ping &
fi

if [[ -z $avg_ping ]] || [[ -z $stdev_ping ]];
then
  exit
fi

if [[ $avg_ping -gt 100 ]];
then
  color="#[fg=red,bright]"
elif [[ $avg_ping -lt 50 ]];
then
  color="#[fg=cyan,bright]"
else
  color="#[fg=yellow,bright]"
fi

echo -e "$color""\u24df $avg_ping:$stdev_ping""#[default]"

