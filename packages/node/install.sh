#!/usr/bin/env zsh
set -eu
set -o pipefail

NVM_DIR="${NVM_DIR:-$HOME/.nvm}"

# Source nvm into this shell
# (nvm uses unset variables internally, so temporarily relax -u)
set +eu
. "$NVM_DIR/nvm.sh"
set -eu

# Install latest LTS node and set as default
nvm install --lts
nvm alias default 'lts/*'
echo "node $(node --version) installed via nvm"
