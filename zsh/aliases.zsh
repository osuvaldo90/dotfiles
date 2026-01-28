alias co='git checkout'
alias com='git checkout $(git rev-parse --abbrev-ref origin/HEAD | sed "s#^origin/##")'
alias st='git status -s'
alias lg_base="git log --graph --abbrev-commit --pretty=format:'%C(bold magenta)%s%Creset %C(dim white)%h%Creset%n%C(yellow)%ad%Creset %C(dim white)by%Creset %C(green)%an%n%(decorate:separator=%n- ,suffix=,prefix=- )%n'"
alias lg="lg_base --date=relative"
alias lgf="lg --first-parent"
alias lgb='lg $(git rev-parse --abbrev-ref origin/HEAD)~..HEAD'
alias lgd='lg_base --date=local'
alias lgt="tv git-log"
alias fh="git commit --amend --no-edit"
alias pu='git push --set-upstream origin'
alias pf='git push --force-with-lease'
alias cf='git commit --fixup'
alias cotmp='git branch -D tmp; git checkout -b tmp'
alias 'ga.'='git add .'

alias newpr='re $(git rev-parse --abbrev-ref origin/HEAD) && pu && gh pr create'
alias rem='re_remote $(git rev-parse --abbrev-ref origin/HEAD | sed "s#^origin/##")'
alias reom='reo $(git rev-parse --abbrev-ref origin/HEAD)'
alias rpf='rem && pf'
alias frpf='fh && rem && pf'

# git town
unalias gts
alias gt='git town'
alias gs='git town sync --no-push'
alias gsr='git town sync'
alias gsa='git town sync --all --no-push'
alias gsar='git town sync --all'
alias ft='git town hack'
alias pr='git town propose'
alias ap='git town append'
alias sw='git town switch'
alias gtc='git town continue'
alias gts='git town skip'
