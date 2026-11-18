# Maintaining this skill

This directory is a jj repo. It tracks the history of the skill itself. It is not the repo
whose conflicts the skill resolves. Keep the two apart.

## Run jj in the right repo

Run every jj command for the skill from this directory, or pass `-R <this directory>`. A jj
command run from the target repo edits the wrong history.

## This repo sits on an NFS mount

jj lock operations fail here at random with "Stale file handle (os error 116)". The failure
is transient.

- Never hide the output of a jj command in this repo. Read it.
- Retry the command once when it reports a lock error. A retry succeeds.
- Confirm the result with `jj log` after every commit. A `jj new` that silently failed puts
  the next edit into the previous commit.

## One commit per well-defined change

- Make exactly one commit for one well-defined change. Never batch two unrelated edits.
- Describe the change with `jj describe -m "<summary>"`. Then start the next one with
  `jj new`.
- To fold a small fix into the change you just described, edit the file and run
  `jj squash --use-destination-message`. Always pass `--use-destination-message`, or jj
  opens an editor and the task hangs.
- Abandon a stray empty change with `jj abandon <change ID>`. A `squash` leaves one behind.
- Leave no undescribed edit in the working copy at the end of a task.
- Do not run `git commit` here. The repo uses the jj git backend, and a git commit bypasses
  jj.

## Before you change the content

- Get the user's approval before you add or edit a strategy file.
- Write every file in Simplified Technical English. Short sentences, active voice, no
  contractions.
- `SKILL.md` is the entry point. Keep it short. Detail belongs in the file that needs it.
