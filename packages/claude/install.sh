#!/usr/bin/env zsh
set -eu
set -o pipefail

script_dir=$(dirname "$(readlink -f "$0")")
source "$script_dir/../../lib/link.zsh"

claude_dir="$HOME/.claude"

# --------------------------
# User-level CLAUDE.md (another repo may link its own file over this one later)
# --------------------------
link_with_backup "$script_dir/CLAUDE.md" "$claude_dir/CLAUDE.md"

# --------------------------
# Output styles and skills: one link per item, so items that other repos own
# or that live only in ~/.claude stay in place
# --------------------------
for f in "$script_dir"/output-styles/*(N); do
  link_with_backup "$f" "$claude_dir/output-styles/${f:t}"
done

for d in "$script_dir"/skills/*(N/); do
  link_with_backup "$d" "$claude_dir/skills/${d:t}"
done
