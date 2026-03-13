#!/usr/bin/env zsh
set -eu
set -o pipefail

# --------------------------
# Git Town install (skip if present)
# --------------------------
if ! command -v git-town >/dev/null 2>&1; then
  echo "installing git-town"
  curl -fsSL https://www.git-town.com/install.sh | sh || echo "git-town install failed; please install manually"
else
  echo "git-town already installed"
fi

git config --global git-town.main-branch main
git config --global git-town.github-connector gh
git config --global git-town.sync-feature-strategy rebase
git config --global git-town.sync-tags false
git config --global git-town.proposal-breadcrumb stacks

