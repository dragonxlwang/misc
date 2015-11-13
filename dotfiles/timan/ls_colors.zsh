# LSCOLORS/LS_COLORS
autoload colors; colors;

#LS_COLORS="di=01;35:ln=01;36:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=01;05;37;41:mi=01;05;37;41:su=37;41:sg=30;43:tw=30;42:ow=34;42:st=37;44:ex=01;32";
LSCOLORS="ExGxFxDxCxDxDxhbhdacEc";

LS_COLORS="no=00:fi=00:di=00;93:ln=00;36:pi=40;33:so=00;35:bd=40;33;01:cd=40;33;01:or=01;05;37;41:mi=01;05;37;41:*makefile=106;01;31:ex=00;91:*.cmd=00;32:*.exe=00;32:*.gz=00;90:*.bz2=00;90:*.bz=00;90:*.tz=00;90:*.rpm=00;90:*.rar=00;90:*.zip=00;90:*.iso=00;90:*.cpio=00;31:*.c=33:*.h=33:*.sh=33:*.t=33:*.pm=33:*.pl=33:*.cgi=33:*.pod=33:*.PL=33:*.js=33:*.php=33:*.off=00;9:*.bak=00;9:*.old=00;9:*.htm=94:*.html=94:*.txt=94:*.text=94:*.css=94:*.avi=96:*.wmv=96:*.mpeg=96:*.mpg=96:*.mov=96:*.AVI=96:*.WMV=96:*.mkv=96:*.jpg=96:*.jpeg=96:*.png=96:*.xcf=96:*.JPG=96:*.gif=96:*.svg=96:*.eps=00;96:*.pdf=00;96:*.PDF=00;96:*.ps=00;96:*.ai=00;91:*.doc=00;91:*.csv=95:*.dsv=95:*.db=95:*.sql=95:*.meta=95:*.xml=95:*.yaml=95:*.yml=95:*.conf=95:";
# Do we need Linux or BSD Style?
if ls --color -d . &>/dev/null 2>&1
then
  # Linux Style
  export LS_COLORS=$LS_COLORS
  alias ls='ls --color=tty'
else
  # BSD Style
  export LSCOLORS=$LSCOLORS
  alias ls='ls -G'
fi

# Use same colors for autocompletion
zmodload -a colors
zmodload -a autocomplete
zmodload -a complist
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}

