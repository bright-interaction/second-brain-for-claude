# Boil the Ocean

The standard the hooks remind Claude of on every prompt.

## The principle

The marginal cost of completeness with AI is near zero. Do the whole thing. Do it right. Do it with tests. Do it with documentation. Do it so well that the user is genuinely impressed, not politely satisfied.

- Never offer to "table this for later" when the permanent solve is within reach.
- Never leave a dangling thread when tying it off takes five more minutes.
- Never present a workaround when the real fix exists.

The standard is not "good enough." It is "holy shit, that's done."

## Why this is the default

Partial fixes, workarounds, and "we can do that later" responses waste more time than doing it right the first time. Every incomplete fix that ships gets revisited, debugged, re-explained, and re-fixed in a future session that has lost the context. The compound cost of incompleteness is large; the marginal cost of completeness is small.

This is the operating standard, not an aspiration.

## How to apply

Before claiming any task done, walk through every angle:

1. **Does it build?** Compilation, type checks, lint, format.
2. **Does it render?** UI shows up correctly, no console errors, no broken styles.
3. **Does it work in production-shaped conditions?** Not just localhost. Headers, CORS, auth, real data.
4. **Does data round-trip?** Whatever you send out you should be able to read back unchanged.
5. **Are error messages legible?** A human reading the failure mode should understand what happened.
6. **Is rate-limiting sane?** No accidental DoS-able endpoint. No infinite loop in a hook.
7. **Tenant-facing check (mandatory).** Can a non-developer reach the demoable state through the UI alone, no docs-diving, no API calls, no asking us? If no, the feature is not shipped. Add the operator surface and re-run the gates.

If any of those fail, fix them before responding. Do not ship a fix and say "try it now" until you have confirmed it works end-to-end yourself.

## Canonical failure modes (what this rule is here to prevent)

- "I'll add the migration but you'll have to run it manually." Run it.
- "The feature works, the admin UI is a follow-up." The admin UI is the feature.
- "Tests are mostly green, the flaky one isn't related." Investigate the flake before claiming green.
- "Settings are in a config row, the operator can edit the database." The operator cannot edit the database. Build the form.
- "Code shipped, I'll update the wiki tomorrow." The next conversation starts blind.

## Where it lives

- **In the UserPromptSubmit hook**: every message you send injects the boil-the-ocean rule into Claude's context.
- **In `CLAUDE.md`**: section 8 of the generated `CLAUDE.md` documents it for the project.
- **In `docs/work-order.md`**: it is the verification gate before each task moves from `executing` to `done`.

You can soften the rule by editing the hook text in `.claude/settings.json`. Do not soften it lightly - the rule exists because softening it has a track record of costing more time than it saves.
