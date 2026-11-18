# Strategy: dependency and build config

## Covers

Dependency and build manifests, and generated lockfiles. See the index for the file list.

## What the conflict looks like

These files are lists and maps, not prose. Most conflicts are two independent additions to
the same list or the same map. A true disagreement over one value is rare.

## Default resolution

1. Keep the entries from both sides. The default is a union, not a choice.
2. Keep the order convention the file already uses, which is usually alphabetical. Match
   the surrounding style for quotes, version ranges, and indentation.
3. When both sides set the same key to a different value, that is a true conflict. Use the
   convention that the rest of the file or the rest of the repo already uses. Read the
   change description for the author's intent.
4. Check for a duplicate key after the merge. An entry that moved between two sections
   looks like an addition on one side and a deletion on the other. Keep one copy, in the
   section the change intended.
5. Never merge a generated lockfile by hand. Resolve the manifests first. Then regenerate
   the lockfile with the package manager's lockfile-only command, run from the repo root.
   Squash the result into the same change.
6. A config file for a tool the repo no longer uses is dead weight. Delete the file instead
   of merging it. Confirm which tool is current from the repo's own config and docs before
   you delete.

## Proof

1. Parse the file to prove the syntax is valid. For JSON:
   `python3 -c "import json; json.load(open('<path>'))"`.
2. Read the regenerated lockfile diff. It must match the dependency change and nothing
   else. An unrelated version bump means the command ran with a stale manifest.
3. Run the repo's install, build, and typecheck for the affected packages.

## Ask a human

Ask when the two sides set a different major version of the same dependency, and neither
change description explains which one the stack needs.
