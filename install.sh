#!/usr/bin/env zsh
set -eu
set -o pipefail

script_dir=$(dirname "$(readlink -f "$0")")
echo "script_dir=$script_dir"

ZSH_CUSTOM=${ZSH_CUSTOM:-"$HOME/.oh-my-zsh/custom"}
mkdir -p "$ZSH_CUSTOM/themes" "$ZSH_CUSTOM/plugins"

if [[ "${IS_ON_ONA:-false}" = "true" ]]; then
  # ensure zsh is used in all sessions
  echo "detecting Ona environment; setting zsh as default shell"
  sudo chsh "$(id -un)" --shell "/usr/bin/zsh"
else
  # TODO Ona has Oh My Zsh pre-installed. If not, install and set up OMZ
fi

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

