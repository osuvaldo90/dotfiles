alias jlg="jj log"
alias jne="jj new"
alias jed="jj edit"
alias jde="jj desc"
alias jpl="jj git fetch"
alias jpu="jj git push"
alias jpua="jj git push --allow-empty-description -c 'heads(mutable()) ~ bookmarks() ~ empty()'"
alias jbk="jj bookmark"
alias jdf="jj diff"
alias jst="jj st"
alias jsq="jj squash"
alias jab="jj abandon"
alias jrb="jj rebase"
alias jcmsg="jj commit -m"

if command -v jj >/dev/null 2>&1; then
  source <(jj util completion zsh)
fi
