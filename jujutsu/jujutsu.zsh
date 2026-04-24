alias jlg="jj log"
alias jnw="jj new"
alias jed="jj edit"
alias jds="jj desc"
alias jpl="jj git fetch"
alias jpu="jj git push"
jpua() {
  # Prune superseded osvi/push-* bookmarks: those on commits that have descendants.
  local stale
  stale=$(jj log --no-graph -r 'bookmarks(glob:"osvi/push-*") ~ heads(all())' \
    -T 'bookmarks ++ "\n"' 2>/dev/null \
    | tr ' ' '\n' | grep '^osvi/push-' | sort -u)
  if [[ -n "$stale" ]]; then
    echo "$stale" | xargs jj bookmark delete
  fi

  jj git push --allow-empty-description -c 'heads(mutable()) ~ bookmarks() ~ empty()'
  jj git push --all --deleted
}
alias jbk="jj bookmark"
alias jdf="jj diff"
alias jst="jj st"
alias jsq="jj squash"
alias jab="jj abandon"
alias jrb="jj rebase"
alias jrbam="jj rebase -b 'heads(mutable()) ~ empty()' -o main"
alias jcmsg="jj commit -m"

if command -v jj >/dev/null 2>&1; then
  source <(jj util completion zsh)
fi
