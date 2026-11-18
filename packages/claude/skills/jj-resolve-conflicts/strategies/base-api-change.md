# Strategy: base API change

## Covers

Code that reads a name or value the new base removed or renamed, with or without markers.

## What the conflict looks like

The text merges cleanly, or the markers show only a small edit. The typecheck then fails
on a name that no longer exists, or a test fails on an old value. A change that jj
rebased with no conflict can fail in the same way.

## Default resolution

1. Read the base commits between the old base and the new base. Their descriptions often
   say what replaces each removed name.
2. Search the whole stack for each removed name, not only the conflicted files. A name can
   also be a real external name, such as a query column. Change only the uses of the
   removed name.
3. Fix each use in the change that wrote it. Find that change with `jj file annotate`.
4. When a change exists to follow the data, for example "read the new data", fix it there.
5. A value that is now the same on every record becomes a constant. Remove the code that
   can no longer run.
6. Update each test and change description that states an old value or an old fact.

## Proof

1. Run the typecheck through the build tool that builds dependencies first. A typecheck of
   one package can read a stale build of a dependency and hide the error.
2. When the stack adds a dependency, run the repo's install first. A missing link looks
   like a code error.
3. Run the tests of every package that reads a changed name.
4. Check the parent of a failing change. If the parent failed the same way before the
   rebase, a later change fixes it on purpose. Leave the parent and report it.

## Ask a human

Ask when the base descriptions do not say what replaces a removed name, and two mappings
are equally possible.
