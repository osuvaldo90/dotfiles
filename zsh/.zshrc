export PATH=$HOME/.local/bin:$PATH  

# configure and load oh-my-zsh
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="spaceship"
plugins=(git gh encode64 zsh-autosuggestions)

source $ZSH/oh-my-zsh.sh

# source custom zsh files
ZSHRC="$HOME/.zshrc"
zsh_files_dir=$(dirname "$(readlink -f "$ZSHRC")")
source "$zsh_files_dir/aliases.zsh"
source "$zsh_files_dir/exports.zsh"
source "$zsh_files_dir/functions.zsh"

# source Ona secrets if present
[ -f /etc/profile.d/ona-secrets.sh ] && . /etc/profile.d/ona-secrets.sh

if [[ -f "$HOME/.zshrc.local" ]]; then
  source "$HOME/.zshrc.local"
fi
