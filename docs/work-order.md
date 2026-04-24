# The Work Order

The hard-coded sequence Claude follows on every task.

## Read order (before doing anything)

1. **graphify query** - `~/.local/bin/graphify query "<question>"`. Fast index, tells you which files matter.
2. **Wiki entity pages** - Read `index.md` first, then the entity page for the project or the concept page for the idea.
3. **Source code** - Only if the first two did not answer. This is where you grep and read files.

## Work order (while doing the task)

4. **Execute** - Make the change.
5. **Commit** - Small, conventional-commit messages.
6. **Push** - Let CI take over.

## Write order (after the code ships)

7. **Edit wiki entity page** - Update the relevant `entities/<project>.md` with what changed and why. Append to `log.md`.
8. **Commit wiki** - Wiki is a separate git repo. Uncommitted edits do not count.
9. **Rebuild graphify** - The post-commit hook does this automatically if installed, but run explicitly to be sure.

## Why the order

- **Read order**: cheapest tokens first. graphify is fastest. Wiki is second. Source is last.
- **Work order**: standard.
- **Write order**: the wiki is downstream of code and upstream of Claude's next conversation. Skipping step 7 or 8 means the next conversation starts stale.

## Violations to catch

Claude will sometimes:

- Jump straight to Grep without querying graphify
- Claim "done" after editing code but before updating the wiki
- Edit wiki files but forget to commit them (they then disappear from next session)

Hooks nudge on all three. If you see one slip, tell Claude directly - the feedback sticks for the session.
