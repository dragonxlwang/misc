#!/usr/bin/env bash

hostname | sed -r 's/\./ /g' | awk '{ if (NF > 1) print $1"."$2; else print $1; }'
