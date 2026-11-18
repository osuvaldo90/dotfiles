# Create a symlink at <dest> pointing to <src>. Idempotent.
# - dest already links to src: do nothing
# - dest is a symlink to something else: replace it (a link holds no data)
# - dest is a real file/dir: move it to "<dest>.backup.<timestamp>" first
link_with_backup() {
  local src="$1" dest="$2"

  if [[ -L "$dest" ]]; then
    if [[ "$(readlink "$dest")" == "$src" ]]; then
      echo "already linked $dest -> $src"
      return 0
    fi
  elif [[ -e "$dest" ]]; then
    local backup="$dest.backup.$(date +%s)"
    echo "backing up existing $dest to $backup"
    mv "$dest" "$backup"
  fi

  mkdir -p "$(dirname "$dest")"
  ln -sfn "$src" "$dest"
  echo "linked $dest -> $src"
}
