# Wiki Philosophy (Karpathy-style)

## The three page types

### Entities

Things that exist. A service, a product, a team, a client, a person. Answers "what is X?"

Filename: `entities/<thing>.md`, lowercase kebab-case.

Template:

```markdown
---
title: ServiceName
type: entity
status: active | planned | archived
stack: Go + React + PostgreSQL
updated: YYYY-MM-DD
links: [[other-entity]] [[related-concept]]
---

# ServiceName

One-paragraph summary: what it does, who uses it, where it deploys.

## Stack

- Language/framework
- Database
- Key dependencies
- Deploy target

## Top-level structure

- `cmd/` - entry points
- `internal/` - private packages
- `frontend/` - UI
- ... (from ls, not invented)

## Key decisions

- Why X over Y (links to any relevant concept or map pages)
- Known trade-offs

## Gotchas

- Things future-you needs to remember. Specific, concrete, short.
```

### Concepts

Ideas you reason about. "How auth works", "our billing model", "the scan pipeline". Answers "how does X work?"

Filename: `concepts/<idea>.md`.

Template:

```markdown
---
title: How Auth Works
type: concept
updated: YYYY-MM-DD
links: [[relevant-entities]]
---

# How Auth Works

Start with the one-sentence version. Then unpack.

## The flow

1. Step one, in plain words
2. Step two
3. ...

## Why this way

Short reason. Not an essay. Link to a decision doc if you wrote one.
```

### Maps

Synthesis pages. "All our services on one diagram", "the whole infrastructure", "every product and how it connects to every other product". Pulls together many entities and concepts.

Filename: `maps/<topic>-overview.md`.

Template:

```markdown
---
title: Infrastructure Overview
type: map
updated: YYYY-MM-DD
links: [[every-entity-referenced]]
---

# Infrastructure Overview

The big-picture view. Usually has an ASCII diagram or a bulleted hierarchy.

## The picture

```
Internet
  |
  v
Reverse proxy
  |
  +--> Service A ([[service-a]])
  +--> Service B ([[service-b]])
```

## What changed recently

Optional timeline so you remember when things moved.
```

## Writing style

- **Dense.** Not pedagogical. You and Claude are the audience, not a new hire.
- **Short.** A page should fit on one screen. If it does not, split into sub-pages.
- **Cross-linked.** Use `[[page-name]]` liberally. That is how Claude traverses.
- **Current.** Wrong information is worse than no information. Update or delete.

## The index

`index.md` lists every page with a one-line hook. Claude reads this first. Keep lines under ~150 characters. Group by category, not alphabetical.

## The log

`log.md` is append-only. One entry per meaningful change. Format:

```
## [YYYY-MM-DD] verb | summary
Touched: [[page-a]] [[page-b]]
Source: <commit-hash or URL if applicable>
Notes: <what and why, 1-3 sentences>
```

Claude appends a log entry as part of step 7 of the work order, every push.

## When to create a new page vs. extend an existing one

- Extend if the new thing is a property of an existing entity. New flag in a service? Update the service entity page.
- Create new if the thing is conceptually separate. New billing model? New concept page.
- When in doubt, extend. It is easier to split later than to merge.

## Antipatterns

- Summarizing code. The graph already does that. The wiki is for context.
- Listing commit history. That is what `git log` is for.
- Ephemeral task tracking. Use your actual task tracker.
- "Latest" anything. Dates change. Use absolute dates or just delete when stale.
