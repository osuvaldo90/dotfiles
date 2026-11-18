# Strategy: business content

## Covers

Content that a customer reads: policy text, legal copy, product copy, a document catalog, a
seeded data set.

## What the conflict looks like

Two changes edited the same text or the same catalog entry.

## Default resolution

1. Treat this content as the exception. No test catches a wrong merge here, so a wrong
   guess corrupts the content in silence.
2. When one side only adds a new item, and the other side adds a different new item, keep
   both items. Keep the catalog's order and its ID convention.
3. Keep the exact wording of the side you choose. Never paraphrase two sentences into one,
   and never blend two versions of the same sentence.
4. Stop and ask when both sides changed the same text and the intent is unclear.

## Proof

1. Parse the file if it has a machine format.
2. Compare the item count before and after. An item that disappeared is a silent loss.
3. Confirm that every ID and every cross reference still resolves.

## Ask a human

Ask whenever step 4 of the default resolution applies. Report the file, the two versions of
the text, and the change description of each side. Do not choose for the user.
