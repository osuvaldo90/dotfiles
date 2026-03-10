#!/usr/bin/env zsh
set -eu
set -o pipefail

script_dir=$(dirname "$(readlink -f "$0")")
echo "script_dir=$script_dir"

# --------------------------
# macOS (homebrew)
# --------------------------
if [[ "$(uname)" == "Darwin" ]]; then
  "$script_dir/macos/install.sh"
fi

# --------------------------
# Zsh (oh-my-zsh, spaceship, autosuggestions, .zshrc link, extra dotfiles)
# --------------------------
"$script_dir/zsh/install.sh"

# --------------------------
# Git Town install (skip if present)
# --------------------------
"$script_dir/git-town/install.sh"

# --------------------------
# Node (via nvm)
# --------------------------
# "$script_dir/node/install.sh"

# --------------------------
# Neovim (prerequisites + install + config)
# --------------------------
"$script_dir/neovim/install.sh"

# --------------------------
# Link $HOME/.tmux.conf to ./tmux/.tmux.conf
# --------------------------
"$script_dir/tmux/install.sh"

