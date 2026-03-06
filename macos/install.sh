#!/usr/bin/env zsh
set -eu
set -o pipefail

# --------------------------
# Homebrew
# --------------------------
# On Apple Silicon the prefix is /opt/homebrew; on Intel it is /usr/local.
if [[ -x "/opt/homebrew/bin/brew" ]]; then
  brew_prefix="/opt/homebrew"
else
  brew_prefix="/usr/local"
fi

if ! command -v brew >/dev/null 2>&1; then
  echo "installing homebrew"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  zprofile="$HOME/.zprofile"
  shellenv_line='eval "$('$brew_prefix'/bin/brew shellenv)"'
  if ! grep -qF "$shellenv_line" "$zprofile" 2>/dev/null; then
    echo "$shellenv_line" >> "$zprofile"
    echo "added brew shellenv to $zprofile"
  fi
else
  echo "homebrew already installed"
fi

# Ensure brew is on PATH for the rest of this install session.
eval "$("$brew_prefix/bin/brew" shellenv)"
