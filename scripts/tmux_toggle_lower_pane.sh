#!/bin/sh
HEIGHT=$(($(tmux display-message -p '#{pane_height}') / 5))
if [[ $(tmux list-panes | wc -l) -eq 1 ]]; then # only 1 pain e.g. vim
  tmux split-window -c "#{pane_current_path}" -v -l $HEIGHT
elif tmux list-panes -F "#F" | grep -q Z; then  # zoomed already
  tmux resize-pane -Z
  tmux select-pane -D
  tmux resize-pane -y $HEIGHT
elif [[ $(tmux display-message -p '#P') -eq 1 ]]; then  # in main pane
  tmux resize-pane -Z
else  # in small pane
  tmux select-pane -U
  tmux resize-pane -Z
fi

