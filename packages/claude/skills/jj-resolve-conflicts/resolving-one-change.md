# Resolving one change

Follow this procedure for one conflicted change. Both paths use it: the orchestrator that
dispatches a subagent, and the agent that resolves the stack itself.

One change is the unit of resolution and the unit of verification. Never batch the checks
for two changes.

## Steps

1. `cd <repo path>`.
2. `jj new <change ID>`. This creates a child of the conflicted change. Resolve in the
   child, then squash the result back. Never edit the conflicted change directly.
3. `jj resolve --list` to list the conflicted files.
4. Read `<skill path>/strategies/index.md`. Match each conflicted file to a strategy. Read
   only the strategy files you need.
5. Read the intent before you guess. Run
   `jj log -r <change ID> --no-graph -T description`, and read the change's own diff. The
   description states what the author meant. Keep that intent on both sides of the conflict.
6. Resolve each file with a text editor. Remove every conflict marker: `<<<<<<<`,
   `%%%%%%%`, `+++++++`, `>>>>>>>`, and `=======`. Do not run `jj resolve` without
   `--list`, because it opens an interactive tool and hangs.
7. Confirm `jj resolve --list` reports no conflicts.
8. Run the checks for this change. See "Verify" below.
9. Squash the result: `jj squash --into <change ID> --use-destination-message`. Always pass
   `--use-destination-message`, or jj opens an editor and the task hangs.

## The squash gate

Step 8 is a precondition of step 9. Do not run `jj squash --into` until the scoped checks
pass, or until you have proved that the failure also exists on the base branch.

A check at the end of the run does not replace this gate. A per-change check names the
change that broke, at the moment it broke. A stack-wide failure costs a bisect. See
`locating-a-failure.md`.

## Verify

1. Find the packages that own the conflicted files.
2. Run the repo's static checks and its tests, scoped to those packages only: typecheck,
   lint, the format check, and the unit tests. Find the commands in the repo's agent guide,
   its README, or its package scripts.
3. Run the extra proof that the strategy file names, if it names one. For example, a
   lockfile needs the install and a review of the lockfile diff.
4. Fix any failure that your resolution caused.
5. A failure in a file that this change does not touch can come from an ancestor that jj
   rebased with no conflict. Find the change that wrote the failing code with
   `jj file annotate`. Fix that change first: `jj new <owner>`, fix, run its checks, and
   squash. Your resolution stays in its own child change. Return to it with
   `jj edit <child>`, and run the checks for this change again.
6. A failure that also exists on the base branch is not yours. Report it and leave it.

## Record the result

Report one line for this change, in the running summary or in the subagent report:

```
CHECKS: <command> -> pass | fail (<reason>)
```

An empty line means the change is not verified. Never leave it empty.
