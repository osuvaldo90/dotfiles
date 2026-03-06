#!/usr/bin/env bash
set -euo pipefail

script_dir=$(cd "$(dirname "$0")" && pwd)

echo "=== building docker image ==="
docker build -t dotfiles-test "$script_dir"

echo "=== running install + verification ==="
docker run --rm \
  -v "$script_dir:/home/user/dotfiles" \
  dotfiles-test \
  zsh -c './install.sh && ./test-verify.sh'
