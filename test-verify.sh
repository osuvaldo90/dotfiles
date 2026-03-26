#!/usr/bin/env zsh
set -eu
set -o pipefail

# git-town installs to ~/.local/bin; nvm-managed node is not on PATH in subshells
export PATH="$HOME/.local/bin:$PATH"
export NVM_DIR="$HOME/.nvm"
set +eu; . "$NVM_DIR/nvm.sh"; set -eu

echo ""
echo "=== verification ==="

pass() { printf "  PASS  %s\n" "$1"; }
fail() { printf "  FAIL  %s\n" "$1"; exit 1; }

check_cmd() {
  local label="$1" version
  version=$("${@:2}" 2>&1 | head -1 | sed 's/\x1b\[[0-9;]*m//g')
  printf "  PASS  %-20s %s\n" "$label" "$version"
}

check_link() {
  local path="$1" target
  target=$(readlink -f "$path" 2>/dev/null || true)
  if [[ -L "$path" ]]; then
    pass "symlink $path -> $target"
  else
    fail "symlink missing: $path"
  fi
}

check_dir() {
  local path="$1"
  if [[ -d "$path" ]]; then
    pass "dir $path"
  else
    fail "dir missing: $path"
  fi
}

check_git_config() {
  local key="$1" expected="$2" actual
  actual=$(git config --global "$key" 2>/dev/null || true)
  if [[ "$actual" == "$expected" ]]; then
    printf "  PASS  %-20s %s\n" "git $key" "$actual"
  else
    fail "git config $key: expected [$expected], got [$actual]"
  fi
}

# --- oh-my-zsh ---
check_dir "$HOME/.oh-my-zsh"

# --- spaceship ---
check_link "$HOME/.oh-my-zsh/custom/themes/spaceship.zsh-theme"

# --- zsh-autosuggestions ---
check_dir "$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions"

# --- git-town ---
check_cmd "git-town"    git-town --version
check_git_config git-town.main-branch           main
check_git_config git-town.github-connector      gh
check_git_config git-town.sync-feature-strategy rebase
check_git_config git-town.sync-tags             false

# --- jujutsu ---
check_cmd "jj"          jj --version

# --- node / nvm ---
check_cmd "nvm"         nvm --version
check_cmd "node"        node --version
check_cmd "npm"         npm --version
actual_alias=$(nvm alias default 2>/dev/null | head -1)
if [[ "$actual_alias" == *"lts/*"* ]]; then
  pass "nvm default alias -> lts/*"
else
  fail "nvm default alias not set to lts/*: $actual_alias"
fi

# --- neovim prerequisites ---
check_cmd "ripgrep"     rg --version
check_cmd "fd"          fd --version
check_cmd "fzf"         fzf --version
check_cmd "lazygit"     lazygit --version
check_cmd "tree-sitter" tree-sitter --version

# --- symlinks ---
check_link "$HOME/.tmux.conf"
check_link "$HOME/.zshrc"
check_link "$HOME/.config/nvim"

echo ""
echo "all checks passed"
