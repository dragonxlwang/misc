# interactive and non-login

## set locale
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

## initial path
export PATH="/software/matlab-R2011a-x86_64/bin:/software/sun-jdk-1.6.0-latest-el6-x86_64/bin:/srv/adm/bin:/usr/lib64/qt-3.3/bin:/usr/NX/bin:/usr/bin:/bin:/usr/sbin:/sbin:$HOME/resource/vowpal_wabbit"

## path set by devtoolset-2
source /opt/rh/devtoolset-2/enable

## add /usr/local
export PATH="/usr/local/bin:/usr/local/sbin:$PATH"
# export MANPATH="/usr/local/man:$MANPATH"

## set by linuxbrew
INCLUDE_LINUXBREW_PATHS=0
if [[ INCLUDE_LINUXBREW_PATHS -eq 1 ]]; then
  export PATH="$HOME/.linuxbrew/bin:$HOME/.linuxbrew/sbin:$PATH"
  export MANPATH="$HOME/.linuxbrew/share/man:$MANPATH"
  export INFOPATH="$HOME/.linuxbrew/share/info:$INFOPATH"
fi

## q for quick exit
alias q='exit'
