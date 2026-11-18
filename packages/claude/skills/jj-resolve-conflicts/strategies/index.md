# Strategy index

Match each conflicted file to one row. Also match a file that fails a check after the
rebase but has no conflict. Read only the strategy files you need.

| The conflicted file is | Strategy |
| --- | --- |
| A dependency or build manifest: `package.json`, `tsconfig*.json`, `turbo.json*`, `pyproject.toml`, `Cargo.toml`, `go.mod` | `dependency-and-build-config.md` |
| A generated lockfile: `pnpm-lock.yaml`, `package-lock.json`, `yarn.lock`, `poetry.lock`, `Cargo.lock`, `uv.lock` | `dependency-and-build-config.md` |
| Content that a customer reads: policy text, legal copy, product copy, a document catalog, a seeded data set | `business-content.md` |
| Code that reads a name the new base removed or renamed, with or without conflict markers | `base-api-change.md` |
| Nothing above | No strategy. See "No match" below. |

## No match

Most conflicts start here, including every conflict in source code. There is no strategy for
a broad category, on purpose. Use judgment:

1. Read both sides, and read the change description of each side.
2. Keep the intent of both sides. Do not drop one side because it is harder to keep.
3. Apply a rename or a move from one side to the other side's new code. This is the most
   common cause of a resolution that reads correctly and fails to compile.
4. Remove every conflict marker.
5. Search the file and the package for every name you touched. Confirm that no caller, no
   export, and no test refers to a name that no longer exists.
6. Run the checks. Report the case as a new type only when the same conflict looks likely to
   recur. A one-off edit to one file needs no report.

## Add a strategy

Only the orchestrator adds a strategy, and only with the user's approval. Keep each file
under 40 lines. Give it these five sections:

1. **Covers.** Which files match.
2. **What the conflict looks like.** The usual shape.
3. **Default resolution.** The action to take.
4. **Proof.** The check that shows the result is correct.
5. **Ask a human.** The cases that judgment cannot settle.

Write a strategy only for a conflict type that recurs. Keep it narrow. A broad strategy,
for example one for all source code, repeats the judgment above and adds nothing.

Write general rules, not rules for one repo or one migration. A rule that names a single
package or a single release is a note for the running summary, not a strategy.
