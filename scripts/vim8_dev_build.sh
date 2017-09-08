#!/bin/bash

cd ~

sudo curl -L https://copr.fedorainfracloud.org/coprs/mcepl/vim8/repo/epel-7/mcepl-vim8-epel-7.repo -o /etc/yum.repos.d/mcepl-vim8-epel-7.repo

export http_proxy=fwdproxy:8080
export https_proxy=fwdproxy:8080

sudo yum update "vim*"
sudo rm -rf /etc/yum.repos.d/mcepl-vim8-epel-7.repo
