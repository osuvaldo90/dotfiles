# ---------------------------------------------------------------------------
# Gitpod environment management
#
# Requires ONA_PROJECT_ID and ONA_CLASS_ID to be set (e.g. in ~/.zshrc.local).
# ---------------------------------------------------------------------------

# List running environments (skip header line).
_oc_list() {
  gitpod env list | tail -n +2
}

# Connect to an environment via SSH + tmux.
#   $1 = env_id
#   $2 = env_name (used for terminal title)
#   $3 = "retry" to retry up to 5 times (for newly created envs)
_oc_connect() {
  local env_id=$1 env_name=$2 mode=$3

  echo -ne "\033]2;ona: ${env_name:-$env_id}\007"

  if [[ "$mode" == "retry" ]]; then
    local attempt=0
    while [[ $attempt -lt 5 ]]; do
      ssh -t "$env_id".gitpod.environment 'tmux -CC a || tmux -CC' && break
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
    ssh -t "$env_id".gitpod.environment 'tmux -CC a || tmux -CC'
  fi

  echo -ne "\033]2;$(hostname -s)\007"
}

# Create a new environment and connect to it.
#   $1 = env_name
_oc_create() {
  local env_name=$1
  local env_id tmpfile

  tmpfile=$(mktemp)
  gitpod env create "$ONA_PROJECT_ID" \
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
    _oc_connect "$env_id" "$env_name"
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
  compadd -X "gitpod environments" -- $env_names
}
compdef _oc_completion oc
