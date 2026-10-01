export PATH=$HOME/.local/bin:$PATH

# configure and load oh-my-zsh
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="spaceship"
ZSH_AUTOSUGGEST_STRATEGY=(match_prev_cmd completion history)
plugins=(git gh encode64 zsh-autosuggestions)

# spaceship-jj is installed by the jj package
ZSH_CUSTOM=${ZSH_CUSTOM:-"$ZSH/custom"}
if [[ -d "$ZSH_CUSTOM/plugins/spaceship-jj" ]]; then
  plugins+=(spaceship-jj)
fi

source $ZSH/oh-my-zsh.sh

# spaceship prompt
if (( ${plugins[(Ie)spaceship-jj]} )); then
  SPACESHIP_PROMPT_ORDER=(user dir host jj git exec_time line_sep exit_code char)
else
  SPACESHIP_PROMPT_ORDER=(user dir host git exec_time line_sep exit_code char)
fi

export LESS="-FR"

# source zsh config of installed packages (linked by install.sh)
for f in "$HOME/.config/dotfiles/zsh.d/"*.zsh(N); do
  source "$f"
done

if [[ -f "$HOME/.zshrc.local" ]]; then
  source "$HOME/.zshrc.local"
fi
