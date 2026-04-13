# Copy stdin to the system clipboard via OSC 52.
# Works through tmux (requires allow-passthrough / set-clipboard) and
# in any terminal that supports OSC 52 (e.g. iTerm2, Ghostty, WezTerm).
# Usage: echo hello | yy
yy() {
  local data
  data=$(cat)
  printf "\033]52;c;%s\a" "$(printf '%s' "$data" | base64 | tr -d '\n')"
}
