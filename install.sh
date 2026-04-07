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
# Zsh (oh-my-zsh, spaceship, autosuggestions, .zshrc link)
# --------------------------
"$script_dir/zsh/install.sh"

# --------------------------
# Git Town install (skip if present)
# --------------------------
"$script_dir/git-town/install.sh"

# --------------------------
# Jujutsu (jj)
# --------------------------
"$script_dir/jujutsu/install.sh"

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
"$script_dir/tmux/install.sh"

# --------------------------
# Extra dotfiles from private gist
# --------------------------
if [[ -n "${EXTRA_DOTFILES_GIST:-}" ]]; then
  echo "fetching extra dotfiles from gist"

  # fetch and install .zshrc.local
  if curl -fsSL "$EXTRA_DOTFILES_GIST/.zshrc.local" -o "$HOME/.zshrc.local"; then
    echo "installed .zshrc.local"
  else
    echo "warning: failed to fetch .zshrc.local from gist"
  fi

  # fetch and run private install.sh
  extra_install=$(mktemp)
  if curl -fsSL "$EXTRA_DOTFILES_GIST/install.sh" -o "$extra_install"; then
    echo "running private install.sh"
    chmod +x "$extra_install"
    . "$extra_install"
    rm -f "$extra_install"
  else
    echo "warning: failed to fetch private install.sh from gist"
    rm -f "$extra_install"
  fi
else
  echo "no EXTRA_DOTFILES_GIST set; skipping extra dotfiles"
fi
