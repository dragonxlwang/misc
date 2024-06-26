# Path to your oh-my-zsh installation.
export ZSH=${HOME}/.oh-my-zsh

# Set name of the theme to load.
# Look in ~/.oh-my-zsh/themes/
# Optionally, if you set this to "random", it'll load a random theme each
# time that oh-my-zsh is loaded.
# ZSH_THEME="robbyrussell"
ZSH_THEME="ys"

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion. Case
# sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for
#   completion.
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# The optional three formats: "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# HIST_STAMPS="mm/dd/yyyy"

# .z sets below default to 9000, which roughly keeps 500 dir locations
# increase the value to keep more dirs
ZSHZ_MAX_SCORE=99999

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
#   (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(\
  git                             \
  colored-man-pages               \
  extract python web-search       \
  zsh-completions                 \
  zsh-autosuggestions             \
  bd                              \
  autojump                        \
  z                               \
  #zsh-syntax-highlighting         \
  #command-not-found               \
)


# User configuration
if [[ $(uname) == 'Darwin' ]]; then                                    # mac os
  PATH="/opt/facebook/bin:"
  PATH+="/usr/local/bin:/usr/local/sbin:/usr/bin:/bin:/usr/sbin:/sbin:"
  PATH+="/opt/X11/bin:/Library/TeX/texbin"
elif [[ $(hostname -s) =~ "timan" ]]; then                              # timan
  ## initial path
  PATH="/opt/facebook/bin:"
  PATH+="/software/matlab-R2011a-x86_64/bin:"
  PATH+="/software/sun-jdk-1.6.0-latest-el6-x86_64/bin:"
  PATH+="/srv/adm/bin:/usr/lib64/qt-3.3/bin:/usr/NX/bin:"
  PATH+="/usr/bin:/bin:/usr/sbin:/sbin:$HOME/resource/vowpal_wabbit"
  ## path set by devtoolset-2
  source /opt/rh/devtoolset-2/enable
else                                                                      # dev
  PATH="/usr/local/bin:"
  PATH+="/bin:"
  PATH+="/usr/bin:"
  PATH+="/usr/local/sbin:"
  PATH+="/usr/sbin:"
  PATH+="/usr/facebook/ops/scripts:"
  PATH+="/usr/facebook/scripts:"
  PATH+="/opt/local/bin:"
  PATH+="/usr/facebook/ops/scripts:"
  PATH+="/usr/facebook/scripts:"
  PATH+="/usr/facebook/scripts:"
  PATH+="/usr/facebook/scripts/db:"
  PATH+="/usr/local/sbin:"
  PATH+="/usr/sbin:/sbin:"
  PATH+="/mnt/vol/engshare/svnroot/tfb/trunk/www/scripts/bin:"
  PATH+="/mnt/vol/engshare/admin/scripts/hg:"
  PATH+="/mnt/vol/engshare/admin/scripts/git:"
  PATH+="/mnt/vol/engshare/admin/scripts:"
  PATH+="/home/xlwang/www/scripts/bin:/home/xlwang/bin"
fi

export PATH
export PATH="/usr/local/bin:/usr/local/sbin:$PATH"
export MANPATH="/usr/local/man:$MANPATH"
export HISTFILE=~/.zsh_history

## set by linuxbrew
INCLUDE_LINUXBREW_PATHS=0
if [[ INCLUDE_LINUXBREW_PATHS -eq 1 && -e "${HOME}/.linuxbrew" ]]; then
  export PATH="$HOME/.linuxbrew/bin:$HOME/.linuxbrew/sbin:$PATH"
  export MANPATH="$HOME/.linuxbrew/share/man:$MANPATH"
  export INFOPATH="$HOME/.linuxbrew/share/info:$INFOPATH"
fi

## set by homebrew
if [[ $(uname) == 'Darwin' ]]; then                                    # mac os
  if [[ -e ~/homebrew ]]; then
    eval "$($HOME/homebrew/bin/brew shellenv)"
  else
    eval $(brew shellenv)
  fi
fi

# Source global definitions
if [[ -e "/etc/zshrc" ]]; then
  . /etc/zshrc
fi
# Source Facebook definitions
if [[ -e "/usr/facebook/ops/rc/master.zshrc" ]]; then
  # first source fb zshrc to avoid my own setting being overwritten
  source /usr/facebook/ops/rc/master.zshrc >/dev/null 2>&1
fi
for i in /etc/profile.d/*.sh; do
  if [ -r "$i" ]; then
    if [ "$PS1" ]; then
      . $i
    else
      . $i > /dev/null 2>&1
    fi
  fi
done
unset i

source $ZSH/oh-my-zsh.sh

# enable zsh-completions
setopt completealiases
autoload -U compinit && compinit >/dev/null 2>&1

# Use vi mode.
# bindkey -v
# bind ctrl + space to accept the current suggestion
bindkey '^ ' autosuggest-accept
# vim-like move
# http://zsh.sourceforge.net/Doc/Release/Zsh-Line-Editor.html#Zle-Widgets
bindkey "^K" up-line-or-beginning-search
bindkey "^J" down-line-or-beginning-search
bindkey "^H" backward-char
bindkey "^L" forward-char
bindkey "^B" backward-word
bindkey "^F" forward-word
bindkey "^X" backward-delete-char
# kill the lag
export KEYTIMEOUT=10

# You may need to manually set your language environment
export LANG=en_US.UTF-8
# export LC_ALL=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# ssh
# export SSH_KEY_PATH="~/.ssh/dsa_id"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

source ${HOME}/ls_colors.zsh
source ${HOME}/.profile_wangxl

###############################################################################
#                            Added by Other Scripts                           #
###############################################################################


test -e "${HOME}/.iterm2_shell_integration.zsh" && \
  source "${HOME}/.iterm2_shell_integration.zsh"

function _PREPEND_PATH {
  local dir=$1
  if [[ -e $dir ]]; then
    echo "$dir:$PATH"
  else
    echo "$PATH"
  fi
}
function _APPEND_PATH {
  local dir=$1
  if [[ -e $dir ]]; then
    echo "$PATH:$dir"
  else
    echo "$PATH"
  fi
}
for _path in  "/opt/homebrew/bin" \
              "/opt/facebook/nuclide/latest/nuclide/pkg/fb-biggrep-cli/bin" \
              "/opt/facebook/hg/bin" \
              "/usr/local/munki";
do
  PATH=$(_APPEND_PATH ${_path})
done
for _path in "/usr/local/opt/ed/libexec/gnubin" \
             "/usr/local/opt/findutils/libexec/gnubin" \
             "/usr/local/opt/gnu-indent/libexec/gnubin" \
             "/usr/local/opt/gnu-sed/libexec/gnubin" \
             "/usr/local/opt/gnu-tar/libexec/gnubin" \
             "/usr/local/opt/gnu-which/libexec/gnubin" \
             "/usr/local/opt/grep/libexec/gnubin" \
             "/usr/local/opt/qt/bin" \
             "/usr/local/opt/curl/bin" \
             "/usr/local/opt/python/libexec/bin";
do
  PATH=$(_PREPEND_PATH ${_path})
done

export FBANDROID_DIR=/Users/xlwang/fbsource/fbandroid
alias quicklog_update="/Users/xlwang/fbsource/fbandroid/"`
                      `"scripts/quicklog/quicklog_update.sh"
alias qlu=quicklog_update

# added by setup_fb4a.sh
export ANDROID_SDK=/opt/android_sdk
export ANDROID_NDK_REPOSITORY=/opt/android_ndk
export ANDROID_HOME=${ANDROID_SDK}
export PATH=${PATH}:${ANDROID_SDK}/tools:${ANDROID_SDK}/platform-tools


[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
