#!/bin/sh

if [[ $(tmux list-panes | wc -l) -eq 1 ]]; then # only 1 pain e.g. vim
  tmux split-window -c "#{pane_current_path}" -v -p 20
elif tmux list-panes -F "#F" | grep -q Z; then  # zoomed already
  tmux resize-pane -Z
  tmux select-pane -D
elif [[ $(tmux display-message -p '#P') -eq 1 ]]; then  # in main pane
  tmux resize-pane -Z
else  # in small pane
  tmux select-pane -U
  tmux resize-pane -Z
fi

