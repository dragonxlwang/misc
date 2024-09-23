#!/bin/sh

run=$1
suffix=""
if [[ $run == *,* ]]; then
  suffix=" # "$(echo $run | cut -f1 -d,)
  run=${run#*,}
fi
echo $run$suffix
