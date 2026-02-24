#!/usr/bin/env zsh
set -eu
set -o pipefail

script_dir=$(dirname "$(readlink -f "$0")")
echo "script_dir=$script_dir"

# --------------------------
# oh-my-zsh install (skip if present)
# --------------------------
if [[ ! -e "$HOME/.oh-my-zsh/oh-my-zsh.sh" ]]; then
  echo "installing oh-my-zsh"
  RUNZSH=no KEEP_ZSHRC=no CHSH=yes sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
else
  echo "oh-my-zsh already installed"
fi

ZSH_CUSTOM=${ZSH_CUSTOM:-"$HOME/.oh-my-zsh/custom"}
mkdir -p "$ZSH_CUSTOM/themes" "$ZSH_CUSTOM/plugins"

# --------------------------
# spaceship prompt (clone or update)
# --------------------------
spaceship_dir="$ZSH_CUSTOM/themes/spaceship-prompt"
if [[ -d "$spaceship_dir/.git" ]]; then
  echo "updating spaceship-prompt"
  git -C "$spaceship_dir" fetch --depth=1 origin || true
  git -C "$spaceship_dir" pull --ff-only || true
else
  echo "cloning spaceship-prompt"
  git clone https://github.com/spaceship-prompt/spaceship-prompt.git "$spaceship_dir" --depth=1 || true
fi

# create symlink for theme (force, but idempotent)
ln -sf "$spaceship_dir/spaceship.zsh-theme" "$ZSH_CUSTOM/themes/spaceship.zsh-theme"

# --------------------------
# zsh-autosuggestions
# --------------------------
zsh_autos_dir="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions"
if [[ -d "$zsh_autos_dir/.git" ]]; then
  echo "updating zsh-autosuggestions"
  git -C "$zsh_autos_dir" fetch --depth=1 origin || true
  git -C "$zsh_autos_dir" pull --ff-only origin main 2>/dev/null || git -C "$zsh_autos_dir" pull --ff-only origin master 2>/dev/null || true
else
  echo "cloning zsh-autosuggestions"
  git clone https://github.com/zsh-users/zsh-autosuggestions "$zsh_autos_dir" --depth=1 || true
fi

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
# Link $HOME/.zshrc to ./zsh/.zshrc
# --------------------------
zshrc_src="$script_dir/zsh/.zshrc"
zshrc_dest="$HOME/.zshrc"

if [[ -f "$zshrc_dest" && ! -L "$zshrc_dest" ]]; then
  # Backup existing .zshrc if it's not already a symlink
  backup_file="$zshrc_dest.backup.$(date +%s)"
  echo "backing up existing .zshrc to $backup_file"
  mv "$zshrc_dest" "$backup_file"
fi

# Create symlink (force, but idempotent)
ln -sf "$zshrc_src" "$zshrc_dest"
echo "linked $zshrc_src to $zshrc_dest"

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

