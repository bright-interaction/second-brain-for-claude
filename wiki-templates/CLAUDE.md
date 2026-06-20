# {{WIKI_NAME}} Operating Rules (for Claude)

This file lives inside the {{WIKI_NAME}} repo. It documents how Claude interacts with the wiki.

## Read order

1. `index.md` - always start here. It lists every page.
2. The specific entity/concept/map page the task concerns.
3. Cross-linked `[[pages]]` referenced by the above.

Never read source code before reading the relevant entity page. The entity page tells you what matters; the source is a detail.

## Write order (after every push to the main project)

1. Update the relevant entity page. Change the `updated` date. Add new sections if needed.
2. Append to `log.md` using the standard format.
3. Update any map page that references this entity.
4. `git add -A && git commit -m "sync: <summary>"` in this wiki repo.
5. Rebuild graphify in the main project (separate step, outside this repo).

## Page types

The full standard is [`ORGANIZATION.md`](ORGANIZATION.md): the eight note types, their
lifecycle, the frontmatter schema, and the linking/mapping rules. The everyday ones:

- **entities/** - things that exist. One page per service, product, team, client, person.
- **concepts/** - ideas you reason about. One page per "how X works" or "why we do Y".
- **maps/** - synthesis pages that connect multiple entities (one per domain).
- **decisions/** + **gotchas/** - institutional memory, **tier-0** (search surfaces them
  first). Capture with `mesh_append_note`; use `**Do:** / **Don't:** / **Why:**`.

Run `mesh structure` for the organization grade. See `docs/wiki-philosophy.md` for
page templates.

## Style

- Dense. You and Claude are the audience, not new hires.
- Short. One screen per page. Split if longer.
- Cross-linked with `[[page-name]]`.
- Current. Wrong info > no info, so delete stale content.

## When in doubt

Extend an existing page before creating a new one. Create new only when the concept is genuinely separate.
