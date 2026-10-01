#!/usr/bin/env zsh
set -eu
set -o pipefail

script_dir=$(dirname "$(readlink -f "$0")")

packages_dir="$script_dir/packages"
all_packages=("$packages_dir"/*(/:t))
os=$(uname -s)

usage() {
  echo "usage: install.sh [-o <package>]... | [-x <package>]..."
  echo "  -o <package>  only install <package> (and its dependencies)"
  echo "  -x <package>  install everything except <package>"
  echo "packages: ${all_packages[*]}"
}

die() {
  echo "error: $*" >&2
  exit 1
}

# --------------------------
# Parse arguments
# --------------------------
only=()
exclude=()
while getopts "o:x:h" opt; do
  case $opt in
    o) only+=("$OPTARG") ;;
    x) exclude+=("$OPTARG") ;;
    h) usage; exit 0 ;;
    *) usage >&2; exit 1 ;;
  esac
done
(( OPTIND > $# )) || die "unexpected argument: ${@[$OPTIND]}"
(( ${#only} && ${#exclude} )) && die "-o and -x can not be used together"

for p in "${only[@]}" "${exclude[@]}"; do
  (( ${all_packages[(Ie)$p]} )) || die "unknown package: $p (packages: ${all_packages[*]})"
done

# Read an array variable from a package's package.conf in a subshell
pkg_conf() {
  local conf="$packages_dir/$1/package.conf"
  [[ -f "$conf" ]] || return 0
  ( source "$conf"; print -r -- ${(P)2-} )
}

pkg_supported() {
  local oses=($(pkg_conf "$1" os))
  (( ${#oses} == 0 || ${oses[(Ie)$os]} ))
}

# --------------------------
# Select and resolve packages
# --------------------------
if (( ${#only} )); then
  selected=("${(@u)only}")
  for p in "${selected[@]}"; do
    pkg_supported "$p" || die "$p is not supported on $os"
  done
else
  selected=("${(@)all_packages:|exclude}")
fi

# Depth-first walk: dependencies are added to $order before their dependents
order=()
visiting=()
skipped=()
resolve() {
  local p=$1 dep
  (( ${order[(Ie)$p]} || ${skipped[(Ie)$p]} )) && return 0
  (( ${visiting[(Ie)$p]} )) && die "dependency cycle at $p"
  if ! pkg_supported "$p"; then
    skipped+=("$p")
    return 0
  fi
  visiting+=("$p")
  for dep in $(pkg_conf "$p" depends); do
    (( ${all_packages[(Ie)$dep]} )) || die "$p depends on unknown package $dep"
    (( ${exclude[(Ie)$dep]} )) && die "$p depends on $dep, which is excluded"
    resolve "$dep"
  done
  visiting=("${(@)visiting:#$p}")
  order+=("$p")
}
for p in "${selected[@]}"; do
  resolve "$p"
done

requested=("${(@)order:*selected}")
dependencies=("${(@)order:|selected}")
echo "installing: ${requested[*]}"
echo "dependencies: ${dependencies[*]:-none}"
(( ${#skipped} )) && echo "skipped (not supported on $os): ${skipped[*]}"

if [[ -n "${DRY_RUN:-}" ]]; then
  echo "DRY_RUN set; install order: ${order[*]}"
  exit 0
fi

# --------------------------
# Install packages
# --------------------------
zshd="$HOME/.config/dotfiles/zsh.d"
mkdir -p "$zshd"
for p in "${order[@]}"; do
  echo "==> $p"
  if [[ -x "$packages_dir/$p/install.sh" ]]; then
    "$packages_dir/$p/install.sh"
  fi
  # Link package zsh files so .zshrc sources them
  for f in "$packages_dir/$p/"*.zsh(N); do
    ln -sf "$f" "$zshd/${f:t}"
    echo "linked $f to $zshd/${f:t}"
  done
done

# --------------------------
# Extra dotfiles from private gist
# --------------------------
if [[ -n "${EXTRA_DOTFILES_GIST:-}" ]]; then
  echo "fetching extra dotfiles from gist"

  # fetch and install .zshrc.local
  if curl -fsSL "$EXTRA_DOTFILES_GIST/.zshrc.local" -o "$HOME/.zshrc.local"; then
    echo "installed .zshrc.local"
  else
    echo "warning: failed to fetch .zshrc.local from gist"
  fi

  # fetch and run private install.sh
  extra_install=$(mktemp)
  if curl -fsSL "$EXTRA_DOTFILES_GIST/install.sh" -o "$extra_install"; then
    echo "running private install.sh"
    chmod +x "$extra_install"
    . "$extra_install"
    rm -f "$extra_install"
  else
    echo "warning: failed to fetch private install.sh from gist"
    rm -f "$extra_install"
  fi
else
  echo "no EXTRA_DOTFILES_GIST set; skipping extra dotfiles"
fi
