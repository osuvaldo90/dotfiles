# Final verification

Run these steps once, after `jj log -r 'conflicts()'` is empty. This run is a regression
check on the whole stack. It does not replace the per-change checks in
`resolving-one-change.md`.

1. Confirm the stack is clean. `jj log -r 'conflicts()'` must print no changes.
2. Confirm every resolved change has a `CHECKS:` line in the running summary. A change with
   no line is not verified. Go back to `resolving-one-change.md` and verify it first.
3. Search the whole tree for leftover markers: `<<<<<<<`, `%%%%%%%`, `+++++++`, `>>>>>>>`,
   and `=======`. Compare every hit against the base branch. Some files hold markers on
   purpose, for example a test fixture or a document about conflicts.
4. List the files the stack touched:
   `jj diff --name-only --from <base change> --to <top change>`.
5. Map those files to packages. Run the repo's static checks, the format check, and the
   unit tests, scoped to those packages only. Never widen the scope to the whole repo.
6. If any check fails, follow `locating-a-failure.md`.

## Why this step still matters

Every change got its own scoped checks before its squash. jj then rebased the descendants
after every later resolution, so an earlier result is stale. This run proves that the stack
works as it now stands.

A stale per-change result still earned its cost. It named the change that broke, at the
moment it broke. This run reports only that something in the stack is wrong, and finding
the cause then costs a bisect. Never treat the coming rebase as a reason to defer a
per-change check.

## Report to the user

- The number of changes on the first `conflicts()` list.
- How many needed a resolution, and how many jj auto-resolved through rebase.
- How many were resolved by a subagent, and how many you resolved yourself.
- The result of each check.
- Every new type, one line each.
- Every new nuance, one line each.
- Every question a subagent raised and how it was settled.

Then offer the strategy updates. See the "Strategy reports" section of `SKILL.md`.
