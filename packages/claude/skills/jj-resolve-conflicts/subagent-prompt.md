# Subagent prompt template

Fill in every placeholder. Send the result as the whole subagent prompt. Do not refer to
this file, because a fresh subagent cannot read your context. A file path is different. A
subagent can read any path you give it, so the template points to the procedure file.

---

Resolve the conflicts in one jj change.

Repo: `{REPO_PATH}`
Change ID: `{CHANGE_ID}`
Skill path: `{SKILL_PATH}`
Position in the stack: {ONE SENTENCE, for example "second of four base dependency changes"}

## Decisions made in earlier changes

{RUNNING_SUMMARY, or "None. This is the first change."}

## Procedure

Read `{SKILL_PATH}/resolving-one-change.md` first. Follow every step in it, in order. Use
`{REPO_PATH}` as the repo path and `{CHANGE_ID}` as the change ID. The scoped checks in that
file are a precondition of the squash. Do not squash before they pass.

## Escalation

Do not stop and wait when a strategy does not cover the case. Make a best attempt with the
same judgment, then report it.

Stop and ask only for a conflict in business content where the intent is unclear. See
`{SKILL_PATH}/strategies/business-content.md`.

## Report back in this format

```
CHANGE: {CHANGE_ID}
FILES:
- <path>: <strategy file used> - <what you did, one sentence>
LOCKFILE: regenerated | not needed
CHECKS: <command> -> pass | fail (<reason>)
NEW TYPE: <path, what the conflict was, what you did> | none
NEW NUANCE: <strategy file, what it did not cover, what you did> | none
BLOCKED: <the question> | none
CONVENTION: <a decision the next change must repeat, one sentence> | none
```

Report only the new type and the new nuance. A conflict that a strategy covered needs no
flag.
