# Clean, simple, compatible and meaningful.
# Tested on Linux, Unix and Windows under ANSI colors.
# It is recommended to use with a dark background and the font Inconsolata.
# Colors: black, red, green, yellow, *blue, magenta, cyan, and white.
#
# http://ysmood.org/wp/2013/03/my-ys-terminal-theme/
# Mar 2013 ys
# Forked by wxl

# Machine name.
function box_name {
    [ -f ~/.box-name ] && cat ~/.box-name || echo $HOST
}

# Directory info.
local current_dir='${PWD/#$HOME/~}'

# VCS
YS_VCS_PROMPT_PREFIX1=" %{$fg[white]%}on%{$reset_color%} "
YS_VCS_PROMPT_PREFIX2=":%{$fg[cyan]%}"
YS_VCS_PROMPT_SUFFIX="%{$reset_color%}"
YS_VCS_PROMPT_DIRTY=" %{$fg[red]%}x"
YS_VCS_PROMPT_CLEAN=" %{$fg[green]%}o"

# Git info.
local git_info='$(git_prompt_info)'
ZSH_THEME_GIT_PROMPT_PREFIX="${YS_VCS_PROMPT_PREFIX1}git${YS_VCS_PROMPT_PREFIX2}"
ZSH_THEME_GIT_PROMPT_SUFFIX="$YS_VCS_PROMPT_SUFFIX"
ZSH_THEME_GIT_PROMPT_DIRTY="$YS_VCS_PROMPT_DIRTY"
ZSH_THEME_GIT_PROMPT_CLEAN="$YS_VCS_PROMPT_CLEAN"

# HG info
local hg_info='$(ys_hg_prompt_info)'
# ys_hg_prompt_info() {
# 	# make sure this is a hg dir
# 	if [ -d '.hg' ]; then
# 		echo -n "${YS_VCS_PROMPT_PREFIX1}hg${YS_VCS_PROMPT_PREFIX2}"
# 		echo -n $(hg branch 2>/dev/null)
# 		if [ -n "$(hg status 2>/dev/null)" ]; then
# 			echo -n "$YS_VCS_PROMPT_DIRTY"
# 		else
# 			echo -n "$YS_VCS_PROMPT_CLEAN"
# 		fi
# 		echo -n "$YS_VCS_PROMPT_SUFFIX"
# 	fi
# }
if [[ -e ~/misc/scripts/scm-prompt ]]; then
  source ~/misc/scripts/scm-prompt
fi
ys_hg_prompt_info() {
  if [[ -e ~/misc/scripts/scm-prompt ]]; then
    echo -n "$(_dotfiles_scm_info hg)"
  fi
}

local exit_code="%(?,%?,%{$fg[red]%}%?%{$reset_color%})"

# Prompt format:
# # USER at MACHINE in DIRECTORY on git:BRANCH STATE [TIME] \
# tty:tty L:shell_depth N:line_number C:exit_code
# $
# For example
# xiaolong at 189.128-25.236.17.192.in-addr.arpa in ~/misc on git:master x \
# [16:24:04] tty:s005 L:2 N:1 C:0
# For more info
# http://zsh.sourceforge.net/Doc/Release/Prompt-Expansion.html

PROMPT="
"
PROMPT+="%{$fg_bold[yellow]%}➜ %{$reset_color%}\
%(#,%{$bg[yellow]%}%{$fg[black]%}%n%{$reset_color%},\
%{$fg_bold[cyan]%}%n%{$reset_color%}) \
%{$fg_bold[white]%}at%{$reset_color%} \
%{$fg_bold[magenta]%}%M%{$reset_color%} \
%{$fg_bold[white]%}in%{$reset_color%} \
%{$fg_bold[green]%}%~%{$reset_color%}\
%{$terminfo[bold]%}${hg_info}${git_info}%{$reset_color%} \
%{$fg[yellow]%}[%*] \
%{$fg[blue]%}tty:%l L:%L N:%i C:$exit_code
%{$fg_bold[yellow]%}$%{$reset_color%} "
