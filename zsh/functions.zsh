unalias gsts
function gsts() {
  if [ -z "$1" ]; then
    git stash show -p stash@{0}
    git show -p stash@{0}^3
  else
    git stash show -p $1
    git show -p $1^3
  fi

}

function stash() {
  stash_count=$(git stash list | wc -l)
  git stash -u
  return $stash_count
}

function unstash() {
  if [ $1 -ne $(git stash list | wc -l) ]; then
    git stash pop
  fi
}

function pl() {
  stash
  stash_count=$?
  git pull --rebase
  unstash $stash_count
}

function ub_internal () {
  current_branch=$(git rev-parse --abbrev-ref HEAD)
  update_branch=$1
  git checkout $update_branch
  git pull --rebase
  git checkout $current_branch
}

# update some other branch
function ub () {
  stash
  stash_count=$?

  ub_internal $1

  unstash $stash_count
}

# update a base branch and rebase against that branch
function re () {
  stash
  stash_count=$?

  ub_internal $1
  git rebase $1

  unstash $stash_count
}

function re_remote () {
  stash
  stash_count=$?

  git fetch origin $1
  git rebase $1

  unstash $stash_count
}

function reo () {
  stash
  stash_count=$?

  ub_internal $1
  git rebase --onto $1 $2

  unstash $stash_count
}

# update a base branch and rebase (interactively) against that branch
function rei () {
  stash
  stash_count=$?

  ub_internal $1
  git rebase -i $update_branch

  unstash $stash_count
}
