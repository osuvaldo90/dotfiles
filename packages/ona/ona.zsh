# ---------------------------------------------------------------------------
# Ona environment management
#
# Requires ONA_PROJECT_ID and ONA_CLASS_ID to be set (e.g. in ~/.zshrc.local).
# Optional: ONA_IDLE_TIMEOUT (seconds, default 3600) for the cmux idle reaper.
# ---------------------------------------------------------------------------

# List running environments (skip header line).
_oc_list() {
  ona env list | tail -n +2
}

# Remote reaper: detaches tmux clients with no input for $1 seconds, checking
# every $2 seconds. Program output does not count as input. Stops when the
# tmux server exits.
read -r -d '' _OC_REAPER <<'EOF'
timeout=$1 interval=$2
while sleep "$interval"; do
  now=$(date +%s)
  clients=$(tmux list-clients -F '#{client_tty} #{client_activity}') || break
  echo "$clients" | while read -r c a; do
    [ -n "$c" ] && [ $((now - a)) -gt "$timeout" ] && tmux detach-client -t "$c"
  done
done
EOF

# Connect via SSH using the appropriate tmux integration.
#   $1 = host  (e.g. <env_id>.gitpod.environment)
#   $2 = env_name (tmux session name)
_oc_ssh() {
  local host=$1 env_name=$2
  if command -v cmux &>/dev/null; then
    # cmux names each mirrored workspace after its tmux session, so create
    # a session with the env name first. Then start the idle reaper once per
    # tmux server; the @oc_reaper option guards against duplicates.
    ssh "$host" "f=/tmp/oc-reaper.sh; cat > \$f.tmp && mv \$f.tmp \$f
      tmux has-session -t '=${env_name}' 2>/dev/null || tmux new-session -d -s '${env_name}'
      tmux if -F '#{@oc_reaper}' '' \"set -g @oc_reaper 1 ; run-shell -b 'sh \$f ${ONA_IDLE_TIMEOUT:-3600} 300'\"" \
      <<< "$_OC_REAPER" || return 1
    cmux ssh-tmux "$host"
  elif [[ -z "$TMUX" && "$TERM_PROGRAM" == "iTerm.app" ]]; then
    ssh -t "$host" "tmux -CC a -t ${env_name} || tmux -CC new -s ${env_name}"
  else
    ssh -t "$host" "tmux a -t ${env_name} || tmux new -s ${env_name}"
  fi
}

# Connect to an environment via SSH + tmux.
#   $1 = env_id
#   $2 = env_name (used for terminal title)
#   $3 = "retry" to retry up to 5 times (for newly created envs)
_oc_connect() {
  local env_id=$1 env_name=$2 mode=$3
  local host="${env_id}.gitpod.environment"

  echo -ne "\033]2;ona: ${env_name:-$env_id}\007"

  if [[ "$mode" == "retry" ]]; then
    local attempt=0
    while [[ $attempt -lt 5 ]]; do
      _oc_ssh "$host" "$env_name" && break
      echo "SSH not ready, retrying in 3s... (attempt $((attempt + 1))/5)"
      sleep 3
      ((attempt++))
    done
    if [[ $attempt -ge 5 ]]; then
      echo "Failed to connect to environment $env_id"
      echo -ne "\033]2;$(hostname -s)\007"
      return 1
    fi
  else
    _oc_ssh "$host" "$env_name"
  fi

  echo -ne "\033]2;$(hostname -s)\007"
}

# Create a new environment and connect to it.
#   $1 = env_name
_oc_create() {
  local env_name=$1
  local env_id tmpfile

  tmpfile=$(mktemp)
  ona env create "$ONA_PROJECT_ID" \
    --class-id="$ONA_CLASS_ID" \
    --name "$env_name" 2>&1 | tee "$tmpfile"

  env_id=$(grep -oE 'environmentID=[^ ]+' "$tmpfile" | cut -d= -f2)
  rm "$tmpfile"

  if [[ -z "$env_id" ]]; then
    echo "Failed to get environment ID"
    return 1
  fi

  _oc_connect "$env_id" "$env_name" retry
}

# Main entry point.
#   oc          - fuzzy-select from existing environments
#   oc <name>   - connect to named env, or offer to create it
oc() {
  local env_name=$1

  # No argument: interactive selection via fzf
  if [[ -z "$env_name" ]]; then
    local selected
    selected=$(_oc_list | fzf --prompt="Select environment: " --height=10 --reverse)
    [[ -z "$selected" ]] && return 0

    local env_id
    env_id=$(echo "$selected" | awk '{print $1}')
    env_name=$(echo "$selected" | awk '{print $2}')
    _oc_connect "$env_id" "$env_name"
    return
  fi

  # Argument given: look up by name
  local match env_id
  match=$(_oc_list | awk -v name="$env_name" '$2 == name {print; exit}')

  if [[ -n "$match" ]]; then
    env_id=$(echo "$match" | awk '{print $1}')
    local phase
    phase=$(echo "$match" | awk '{print $NF}')
    if [[ "$phase" != "running" ]]; then
      echo "Starting environment '$env_name'..."
      ona env start --dont-wait "$env_id"
      _oc_connect "$env_id" "$env_name" retry
    else
      _oc_connect "$env_id" "$env_name"
    fi
  else
    echo "No environment named '$env_name' found."
    read -q "confirm?Create a new one? [y/N] " || { echo; return 0; }
    echo
    _oc_create "$env_name"
  fi
}

# Zsh completion: complete env names for oc.
_oc_completion() {
  local -a env_names
  env_names=(${(f)"$(_oc_list | awk '{print $2}')"})
  compadd -X "ona environments" -- $env_names
}
compdef _oc_completion oc
