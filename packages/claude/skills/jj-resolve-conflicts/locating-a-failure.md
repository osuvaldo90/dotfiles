# Locating a failure in the stack

Use this workflow when the final verification fails. The goal is to find the one change
that introduced the failure.

## Steps

1. Reduce the failing check to one fast command. A slow command makes the search long,
   because jj runs it once per revision it tests.
2. Confirm the command fails at the top of the stack and passes at the base. If it fails at
   the base, the failure is not from this stack. Stop and report it.
3. Confirm the working copy is clean. `jj bisect run` edits each revision it tests.
4. Run the search:
   `jj bisect run --range '<base change>::<top change>' -- <check command>`
   The command must exit non-zero only for this failure.
5. jj reports the first bad revision. That change introduced the failure.
6. Fix it in place. `jj new <bad change>`, edit, then
   `jj squash --into <bad change> --use-destination-message`.
7. Return to `verifying.md` and run the final verification again. The fix rewrote every
   descendant, so a later change can now fail for a new reason.

## Limits

`jj bisect run` assumes that every descendant of a bad revision is also bad. A failure that
appears and then disappears breaks that assumption, and the result is then wrong. Test the
two endpoints by hand when the answer looks wrong.

A flaky test also breaks the assumption. Run the failing test twice at the top of the stack
before you start the search.
