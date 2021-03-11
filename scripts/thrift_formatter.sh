#!/usr/bin/env zsh

tmp_fs=$(mktemp -u)
cat /dev/stdin > $tmp_fs


# tools/arcanist/lint/fbsource-lint-engine.toml
linter="/data/users/$USER/fbsource/tools/lint/thriftformat/thriftformat_linter"
if [[ ! -e $linter ]]; then
  echo "thrift linter $linter not available" 1>&2
  exit 1
fi

json_output=$(mktemp -u)

$linter $tmp_fs > $json_output
original=$(jq -rM '.original' $json_output)
replacement=$(jq -rM '.replacement' $json_output)
if [[ -z $replacement ]]; then
  cat $tmp_fs
else
  echo $replacement
fi

rm $json_output
rm $tmp_fs

