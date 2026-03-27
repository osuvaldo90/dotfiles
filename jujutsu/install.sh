#!/usr/bin/env zsh
set -eu
set -o pipefail

# --------------------------
# Jujutsu (jj) install (skip if present)
# --------------------------
if command -v jj >/dev/null 2>&1; then
  echo "jj already installed"
else
  echo "installing jujutsu (jj)"

  OS=$(uname -s)
  if [[ "$OS" == "Darwin" ]]; then
    brew install jj
  else
    JJ_VERSION="$(curl -fSs https://api.github.com/repos/jj-vcs/jj/releases/latest | grep '"tag_name"' | cut -d'"' -f4)"
    tmpdir=$(mktemp -d)
    curl -fSL "https://github.com/jj-vcs/jj/releases/download/${JJ_VERSION}/jj-${JJ_VERSION}-x86_64-unknown-linux-musl.tar.gz" -o "$tmpdir/jj.tar.gz"
    tar -xzf "$tmpdir/jj.tar.gz" -C "$tmpdir"
    install -d "$HOME/.local/bin"
    install "$tmpdir/jj" "$HOME/.local/bin/jj"
    rm -rf "$tmpdir"
  fi
fi

# --------------------------
# spaceship-jj prompt section (clone or update)
# --------------------------
ZSH_CUSTOM=${ZSH_CUSTOM:-"$HOME/.oh-my-zsh/custom"}
spaceship_jj_dir="$ZSH_CUSTOM/plugins/spaceship-jj"
if [[ -d "$spaceship_jj_dir/.git" ]]; then
  echo "updating spaceship-jj"
  git -C "$spaceship_jj_dir" fetch --depth=1 origin && git -C "$spaceship_jj_dir" reset --hard FETCH_HEAD || true
else
  echo "cloning spaceship-jj"
  git clone https://github.com/lucean/spaceship-jj.git "$spaceship_jj_dir" --depth=1 || true
fi
