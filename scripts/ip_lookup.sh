#!/bin/zsh

function is_osx { [[ $(uname) == 'Darwin' ]]; }
function is_linux { [[ $(uname) == 'Linux' ]]; }

# tmux-powerline/segments/lan_ip.sh
# tmux-powerline/segments/wan_ip.sh
# oh-my-zsh/plugins/systemadmin/systemadmin.plugin.zsh
if is_osx; then
  all_nics=$(ifconfig 2>/dev/null |\
    awk -F':' '/^[a-z]/ && !/^lo/ {print $1}')
  for nic in "${(f)all_nics[@]}"; do
    ipv4s_on_nic=$(ifconfig ${nic} 2>/dev/null |\
      awk '$1 == "inet" {print $2}')
    for lan_ip in ${ipv4s_on_nic[@]}; do
      [[ -n "${lan_ip}" ]] && break
    done
    [[ -n "${lan_ip}" ]] && break
  done
elif is_linux; then
  # Get the names of all attached NICs.
  if [[ -z "$(which ip)" ]]; then
    all_nics="$(ip addr show | cut -d ' ' -f2 | tr -d :)"
    all_nics=(${all_nics[@]//lo/})	 # Remove lo interface.
    for nic in "${(f)all_nics[@]}"; do
      # Parse IP address for the NIC.
      lan_ip="$(ip addr show ${nic} | grep '\<inet\>' |\
        tr -s ' ' | cut -d ' ' -f3)"
      # Trim the CIDR suffix.
      lan_ip="${lan_ip%/*}"
      # Only display the last entry
      lan_ip="$(echo "$lan_ip" | tail -1)"
      [[ -n "$lan_ip" ]] && break
    done
  else
    lan_ip=$(ifconfig  | grep 'inet addr:' | grep -v '127.0.0.1' |\
      cut -d: -f2 | awk '{ print $1}')
  fi
fi

misc_dir="$(dirname $(dirname $(readlink -f $0)))"
[[ ! -d "$misc_dir/tmp" ]] && mkdir "$misc_dir/tmp"
tmp_file="$misc_dir/tmp/wan_ip_$(hostname).txt"
if [ -f "$tmp_file" ]; then
  if is_osx; then
    stat >/dev/null 2>&1 && { last_update=$(stat -f "%m" ${tmp_file}); }\
      || { last_update=$(stat -c "%Y" ${tmp_file}) }
  elif is_linux; then
    last_update=$(stat -c "%Y" ${tmp_file})
  fi
  time_now=$(date +%s)
  update_period=900
  up_to_date=$(echo "(${time_now}-${last_update}) < ${update_period}" | bc)
  [[ "$up_to_date" -eq 1 ]] && wan_ip=$(cat ${tmp_file})
fi
if [[ -z "$wan_ip" ]]; then
  wan_ip=$(curl --max-time 2 -s http://whatismyip.akamai.com/)
  [[ "$?" -eq "0" ]] &&  echo "${wan_ip}" > $tmp_file
fi

if [[ $1 == 'all' ]]; then
  echo "ⓛ ${lan_ip-N/a} ⓦ ${wan_ip-N/a}"
else
  [[ $lan_ip == $wan_ip ]] && wan_ip=""
  [[ -n $lan_ip ]] && lan_ip="ⓛ ${lan_ip} "
  [[ -n $wan_ip ]] && wan_ip="ⓦ ${wan_ip} "
  echo "$lan_ip$wan_ip"
fi
