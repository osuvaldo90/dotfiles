#!/usr/bin/env zsh
set -eu
set -o pipefail

NVM_DIR="${NVM_DIR:-$HOME/.nvm}"

# Install nvm if not present
if [[ ! -s "$NVM_DIR/nvm.sh" ]]; then
  echo "installing nvm"
  PROFILE=/dev/null bash -c "$(curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/HEAD/install.sh)"
else
  echo "nvm already installed"
fi
