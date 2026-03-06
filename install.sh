#!/usr/bin/env zsh
set -eu
set -o pipefail

script_dir=$(dirname "$(readlink -f "$0")")
echo "script_dir=$script_dir"

# --------------------------
# Zsh (oh-my-zsh, spaceship, autosuggestions, .zshrc link, extra dotfiles)
# --------------------------
"$script_dir/zsh/install.sh"

# --------------------------
# Git Town install (skip if present)
# --------------------------
if ! command -v git-town >/dev/null 2>&1; then
  echo "installing git-town"
  # the official installer might require sudo depending on platform; keep it safe
  curl -fsSL https://www.git-town.com/install.sh | sh || echo "git-town install failed; please install manually"
else
  echo "git-town already installed"
fi
git config --global git-town.main-branch main
git config --global git-town.github-connector gh
git config --global git-town.sync-feature-strategy rebase
git config --global git-town.sync-tags false

# --------------------------
# Node (via nvm)
# --------------------------
"$script_dir/node/install.sh"

# --------------------------
# Neovim (prerequisites + install + config)
# --------------------------
"$script_dir/neovim/install.sh"

# --------------------------
# Link $HOME/.tmux.conf to ./tmux/.tmux.conf
# --------------------------
tmux_src="$script_dir/tmux/.tmux.conf"
tmux_dest="$HOME/.tmux.conf"

if [[ -f "$tmux_dest" && ! -L "$tmux_dest" ]]; then
  backup_file="$tmux_dest.backup.$(date +%s)"
  echo "backing up existing .tmux.conf to $backup_file"
  mv "$tmux_dest" "$backup_file"
fi

ln -sf "$tmux_src" "$tmux_dest"
echo "linked $tmux_src to $tmux_dest"

