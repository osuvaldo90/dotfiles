export PATH=$HOME/.local/bin:$PATH

# configure and load oh-my-zsh
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="spaceship"
ZSH_AUTOSUGGEST_STRATEGY=(match_prev_cmd completion history)
plugins=(git gh encode64 zsh-autosuggestions)

source $ZSH/oh-my-zsh.sh

# spaceship prompt
SPACESHIP_PROMPT_ORDER=(user dir host git exec_time line_sep exit_code char)

export EDITOR=nvim
export VISUAL=nvim

# source per-tool zsh config
ZSHRC="$HOME/.zshrc"
dotfiles_dir=$(dirname "$(dirname "$(readlink -f "$ZSHRC")")")
source "$dotfiles_dir/git/git.zsh"
source "$dotfiles_dir/git-town/git-town.zsh"
source "$dotfiles_dir/docker/docker.zsh"
source "$dotfiles_dir/gitpod/gitpod.zsh"

if [[ -f "$HOME/.zshrc.local" ]]; then
  source "$HOME/.zshrc.local"
fi

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
