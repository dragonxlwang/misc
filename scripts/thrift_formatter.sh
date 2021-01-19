#!/usr/bin/env zsh

tmp_fs=$(mktemp -u)
cat /dev/stdin > $tmp_fs


# tools/arcanist/lint/fbsource-lint-engine.toml
linter="/data/users/$USER/fbsource/tools/lint/thriftformat/thriftformat_linter"
if [[ ! -e $linter ]]; then
  echo "thrift linter $linter not available" 1>&2
  exit 1
fi

$linter $tmp_fs | jq -rM '.replacement' | xargs -0 echo -e

rm $tmp_fs

