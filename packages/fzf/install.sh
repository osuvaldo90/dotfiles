#!/usr/bin/env zsh
set -eu
set -o pipefail

# Run a command with sudo only when not already root
_sudo() {
  if [[ "$(id -u)" -eq 0 ]]; then
    "$@"
  else
    sudo "$@"
  fi
}

if command -v fzf >/dev/null 2>&1; then
  echo "fzf already installed"
  exit 0
fi

echo "installing fzf"
if [[ "$(uname -s)" == "Darwin" ]]; then
  brew install fzf
elif command -v apt-get >/dev/null 2>&1; then
  _sudo apt-get update
  _sudo apt-get install -y fzf
elif command -v dnf >/dev/null 2>&1; then
  _sudo dnf install -y fzf
elif command -v yum >/dev/null 2>&1; then
  _sudo yum install -y fzf
else
  echo "unsupported OS/package manager; please install fzf manually"
fi
