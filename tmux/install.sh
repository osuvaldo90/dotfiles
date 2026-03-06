#!/usr/bin/env zsh
set -eu
set -o pipefail

script_dir=$(dirname "$(readlink -f "$0")")

# --------------------------
# Link $HOME/.tmux.conf to ./tmux/.tmux.conf
# --------------------------
tmux_src="$script_dir/.tmux.conf"
tmux_dest="$HOME/.tmux.conf"

if [[ -f "$tmux_dest" && ! -L "$tmux_dest" ]]; then
  backup_file="$tmux_dest.backup.$(date +%s)"
  echo "backing up existing .tmux.conf to $backup_file"
  mv "$tmux_dest" "$backup_file"
fi

ln -sf "$tmux_src" "$tmux_dest"
echo "linked $tmux_src to $tmux_dest"
