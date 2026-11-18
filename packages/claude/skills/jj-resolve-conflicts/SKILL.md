---
name: jj-resolve-conflicts
description: Use when a jj repo has conflicted changes, for example after a rebase, a pull that moved the base branch, or a force-push of main. Also use when `jj log -r 'conflicts()'` lists changes, or when the user asks to fix conflicts across a jj stack.
---

# jj Resolve Conflicts

## Overview

A conflicted stack is many small, similar problems. Solve them one at a time, oldest
first. jj rebases the descendants after each resolution, so later changes often become
clean with no work.

Core principle: one change is the unit of resolution and the unit of verification. Resolve
one change, run the checks for it, squash it, then take the next one.

Prefer one fresh subagent per change. The orchestrator keeps the plan and the conventions.
The subagent keeps the diffs.

## Resolve every change the same way

`resolving-one-change.md` holds the procedure for one change. Both paths use that one file.

- **Dispatch a subagent.** Fill in the template in `subagent-prompt.md`. The template sends
  the subagent to the procedure file.
- **Resolve it yourself.** Read the procedure file and follow every step, once per change.

The checks in that file belong to the change, not to the subagent. A path that skips the
subagent does not skip the checks.

## Subagent dispatch is part of this skill

This workflow runs on subagents. An invocation of this skill is the request for them.

Harnesses name the dispatch differently: `Agent`, `AgentTool`, and `Task`. The three names
mean one thing here.

State the plan in one line before the first dispatch, for example "12 conflicted changes,
one subagent each, oldest first". Report the count of dispatches in the final summary.

## When to use each path

Dispatch subagents when `jj log -r 'conflicts()'` lists 10 or more changes, or when one
change has many conflicted files.

Resolve the conflicts yourself when the stack is smaller than that. Switch to subagents if
your context fills with diffs before the stack is clean.

## Address every change by change ID

Use change IDs. jj rewrites the commit ID of every descendant after each resolution, so a
commit ID from an earlier step is stale. A change ID is stable.

## Stack loop

Follow this loop on both paths.

1. List the conflicted changes, oldest first: `jj log -r 'conflicts()'`.
2. Take the oldest conflicted change. Resolve it with `resolving-one-change.md`. Dispatch a
   fresh subagent on the latest Sonnet model (`model: sonnet`), or follow that file
   yourself. The work per change is mechanical, and the strategy files carry the judgment.
3. Wait for the report. Never run two subagents at the same time. The repo has one working
   copy, so parallel jj commands collide.
4. Add the decisions and the `CHECKS:` line to the running summary.
5. Run `jj log -r 'conflicts()'` again. The list is often shorter than expected. Do not
   start work on a change that is now clean.
6. Repeat from step 2 until the list is empty.
7. Follow `verifying.md`.

## Running summary

Keep a short list of the decisions made so far. Pass it to every new subagent. A fresh
subagent knows nothing about the earlier changes.

Include the conventions that the whole stack must keep, and the traps found in earlier
changes. Keep each entry to 1 or 2 sentences. Never include a diff or a file body.

Give every resolved change one entry, and give every entry a `CHECKS:` line. A missing
`CHECKS:` line means the change is not verified. Verify it before you continue.

## Strategy reports

A subagent reports two special cases. Handle both at the end of the run, after the stack
is clean.

- **New type.** No strategy covered the conflict. The subagent made a best attempt and
  reported the details. Explain the case to the user. Offer to write a new strategy file
  and to add a row to the index.
- **New nuance.** A strategy applied, but it did not cover part of the case. Explain what
  was missing. Offer to update that strategy file.

Do not write or edit a strategy file without the user's approval.

This skill lives in its own jj repo. Commit an approved change from the skill directory, not
from the target repo. Make exactly one commit per well-defined change. See `CLAUDE.md` in
the skill directory.

## Red flags

| Thought | Reality |
| --- | --- |
| "I will ask first whether I may dispatch a subagent." | The invocation is the request. State the plan and dispatch. |
| "I will run the subagents in parallel." | One working copy. The commands collide. |
| "I will dispatch one subagent per change on the first list." | Re-run `conflicts()` after every resolution. |
| "The commit ID moved, so the change is gone." | Address changes by change ID. |
| "The file reads correctly, so the change is good." | Run the scoped checks before the squash. See `resolving-one-change.md`. |
| "I am resolving these myself, so those steps are for subagents." | The steps belong to the change. Both paths follow `resolving-one-change.md`. |
| "I will run all the checks once, at the end." | A per-change check names the change that broke. A stack-wide failure costs a bisect. |
| "The next rebase makes this result stale, so the check adds nothing." | A stale pass still proves the resolution built. Staleness is not a reason to defer. |
| "I will regenerate the lockfile once, on top of the stack." | Regenerate it in the change that edited the manifest. Squash it into that change. |
| "This new strategy is obviously useful, I will add it." | Ask the user first. |
