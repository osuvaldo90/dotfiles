alias jl="jj log"
alias jn="jj new"
alias je="jj edit"
alias jc="jj commit"
alias jdc="jj desc"
alias jf="jj git fetch"
alias jp="jj git push"
alias jb="jj bookmark"
alias jdf="jj diff"
alias js="jj st"
alias ja="jj abandon"

if command -v jj >/dev/null 2>&1; then
  source <(jj util completion zsh)
fi
