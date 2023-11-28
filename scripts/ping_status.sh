#!/usr/bin/env bash

misc_dir="$(dirname $(dirname $(readlink -f $0)))"
f=$misc_dir/tmp/ping_$(hostname).txt

if [[ -e ~/.active_ssh_client_for_tmux ]]; then
  client_ip=$(cat ~/.active_ssh_client_for_tmux | cut -sd ' ' -f 1 -)
else
  client_ip=$(echo $SSH_CLIENT | cut -sd ' ' -f 1 -)
fi

function register_client_ip {
  touch ~/.known_ssh_clients_for_tmux
  id=$(awk '/'$1'/{ print NR; exit }' ~/.known_ssh_clients_for_tmux)
  if [[ -n $id ]]; then
    echo $id
    return 0
  fi
  echo $1 >> ~/.known_ssh_clients_for_tmux
  register_client_ip $1
}

client_id=$(register_client_ip $client_ip)

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

# https://en.wikipedia.org/wiki/List_of_Unicode_characters
echo -e "$color""\u24df $client_id\u260e $avg_ping:$stdev_ping""#[default]"
