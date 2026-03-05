#!/usr/bin/env zsh
set -eu
set -o pipefail

script_dir=$(dirname "$(readlink -f "$0")")

# --------------------------
# OS detection
# --------------------------
OS=$(uname -s)
LINUX_PKG_MGR=""
if [[ "$OS" == "Linux" ]]; then
  if command -v apt-get >/dev/null 2>&1; then LINUX_PKG_MGR="apt"
  elif command -v dnf >/dev/null 2>&1; then LINUX_PKG_MGR="dnf"
  elif command -v yum >/dev/null 2>&1; then LINUX_PKG_MGR="yum"
  fi
fi

# --------------------------
# Prerequisites
# --------------------------

install_pkg() {
  local pkg_mac="$1" pkg_apt="$2" pkg_dnf="$3"
  if [[ "$OS" == "Darwin" ]]; then
    brew install "$pkg_mac"
  elif [[ "$LINUX_PKG_MGR" == "apt" ]]; then
    sudo apt-get install -y "$pkg_apt"
  elif [[ "$LINUX_PKG_MGR" == "dnf" ]]; then
    sudo dnf install -y "$pkg_dnf"
  elif [[ "$LINUX_PKG_MGR" == "yum" ]]; then
    sudo yum install -y "$pkg_dnf"
  else
    echo "unsupported OS/package manager; please install $pkg_mac manually"
  fi
}

# build tools (needed for tree-sitter parser compilation)
if [[ "$OS" == "Darwin" ]]; then
  if ! xcode-select -p >/dev/null 2>&1; then
    echo "installing Xcode command line tools"
    xcode-select --install
  else
    echo "Xcode command line tools already installed"
  fi
elif [[ "$LINUX_PKG_MGR" == "apt" ]]; then
  sudo apt-get install -y build-essential
elif [[ "$LINUX_PKG_MGR" == "dnf" ]]; then
  sudo dnf install -y gcc gcc-c++ make
elif [[ "$LINUX_PKG_MGR" == "yum" ]]; then
  sudo yum install -y gcc gcc-c++ make
fi

# ripgrep
if ! command -v rg >/dev/null 2>&1; then
  echo "installing ripgrep"
  install_pkg ripgrep ripgrep ripgrep
else
  echo "ripgrep already installed"
fi

# fd
if ! command -v fd >/dev/null 2>&1; then
  echo "installing fd"
  install_pkg fd fd-find fd
else
  echo "fd already installed"
fi

# lazygit
if ! command -v lazygit >/dev/null 2>&1; then
  echo "installing lazygit"
  if [[ "$OS" == "Darwin" ]]; then
    brew install lazygit
  else
    # fetch latest release tarball from GitHub
    lazygit_version=$(curl -fsSL "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep '"tag_name"' | sed 's/.*"v\([^"]*\)".*/\1/')
    curl -fsSL "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${lazygit_version}_Linux_x86_64.tar.gz" \
      | sudo tar -C /usr/local/bin -xz lazygit
  fi
else
  echo "lazygit already installed"
fi

# node (for LSP servers: TypeScript, ESLint, Prettier)
if ! command -v node >/dev/null 2>&1; then
  echo "installing node"
  install_pkg node "nodejs npm" "nodejs npm"
else
  echo "node already installed"
fi

# --------------------------
# Neovim install
# --------------------------
if ! command -v nvim >/dev/null 2>&1; then
  echo "installing neovim"
  if [[ "$OS" == "Darwin" ]]; then
    brew install neovim
  elif [[ "$OS" == "Linux" ]]; then
    curl -fsSL -o /tmp/nvim-linux64.tar.gz \
      "https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz"
    sudo tar -C /opt -xzf /tmp/nvim-linux64.tar.gz
    sudo ln -sf /opt/nvim-linux-x86_64/bin/nvim /usr/local/bin/nvim
    rm -f /tmp/nvim-linux64.tar.gz
  else
    echo "unsupported OS for automatic neovim install; please install manually"
  fi
else
  echo "neovim already installed"
fi

# --------------------------
# LazyVim config (symlink neovim/config → ~/.config/nvim)
# --------------------------
nvim_config_src="$script_dir/config"
nvim_config_dest="$HOME/.config/nvim"

mkdir -p "$HOME/.config"

if [[ -d "$nvim_config_dest" && ! -L "$nvim_config_dest" ]]; then
  backup_dir="$nvim_config_dest.backup.$(date +%s)"
  echo "backing up existing nvim config to $backup_dir"
  mv "$nvim_config_dest" "$backup_dir"
fi

ln -sfn "$nvim_config_src" "$nvim_config_dest"
echo "linked $nvim_config_src to $nvim_config_dest"

# --------------------------
# tree-sitter-cli (needed by nvim-treesitter to compile parsers)
# --------------------------
if ! command -v tree-sitter >/dev/null 2>&1; then
  echo "installing tree-sitter-cli"
  npm install -g tree-sitter-cli
else
  echo "tree-sitter-cli already installed"
fi
