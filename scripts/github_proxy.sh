#!/bin/sh

if [[ $(uname) == Darwin ]]; then
  :
elif [[ $(rpm -q --queryformat '%{VERSION}' centos-release) == 6* ]]; then
  nc -X connect -x fwdproxy:8080 $1 $2
else
  nc --proxy-type http --proxy fwdproxy:8080 $1 $2
fi
