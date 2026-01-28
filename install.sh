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
sed -i.bak.1-theme 's/^ZSH_THEME=.*$/ZSH_THEME="spaceship"/' $HOME/.zshrc

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

# configure OMZ plugins
sed -i.bak.plugins 's/^plugins=.*$/plugins=(git gh encode64 zsh-autosuggestions)/' $HOME/.zshrc

# enable aliases and functions
ensure_source_once() {
  local target="$1"
  local src_line="source $target"
  if ! grep -Fxq "$src_line" "$HOME/.zshrc"; then
    echo "$src_line" >> $HOME/.zshrc
    echo "added: $src_line"
  else
    echo "already sources: $target"
  fi
}

ensure_source_once "$script_dir/zsh/aliases.zsh"
ensure_source_once "$script_dir/zsh/exports.zsh"
ensure_source_once "$script_dir/zsh/functions.zsh"

ensure_path_once() {
  local path_dir="$1"
  if [[ ":$PATH:" != *":$path_dir:"* ]]; then
    echo "export PATH=\"$path_dir:\$PATH\"" >> "$HOME/.zshrc"
    echo "added $path_dir to PATH"
  else
    echo "$path_dir already in PATH"
  fi
}

ensure_path_once "$HOME/.local/bin"
