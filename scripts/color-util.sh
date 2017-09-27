#!/bin/sh
## ========================================================================== ##
#       ______   ______    __        ______   .______          _______.        #
#      /      | /  __  \  |  |      /  __  \  |   _  \        /       |        #
#     |  ,----'|  |  |  | |  |     |  |  |  | |  |_)  |      |   (----`        #
#     |  |     |  |  |  | |  |     |  |  |  | |      /        \   \            #
#     |  `----.|  `--'  | |  `----.|  `--'  | |  |\  \----.----)   |           #
#      \______| \______/  |_______| \______/  | _| `._____|_______/            #
## ========================================================================== ##
# print with or without newline
function _color_echo {
  if [[ "$2" == "-n" ]]; then echo -ne "\033[${1}${@:3}\033[0m"
  else echo -e "\033[${1}${@:2}\033[0m"; fi }
function blackecho    { _color_echo "1;30m" "${@}"; }
function redecho      { _color_echo "1;31m" "${@}"; }
function greenecho    { _color_echo "1;32m" "${@}"; }
function yellowecho   { _color_echo "1;33m" "${@}"; }
function blueecho     { _color_echo "1;34m" "${@}"; }
function magentaecho  { _color_echo "1;35m" "${@}"; }
function cyanecho     { _color_echo "1;36m" "${@}"; }
function whiteecho    { _color_echo "1;37m" "${@}"; }
