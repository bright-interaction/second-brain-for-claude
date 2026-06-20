---
id: organization
type: concept
title: How this vault is organized (the structure standard)
tags: [structure, conventions, meta]
---

# How this vault is organized

This is the single source of truth for how notes are typed, linked, and mapped. The
AI reads it to follow a clear path; `mesh structure` enforces it. If you change the
standard, change it here first.

## The model (why structure matters)

This vault is a **knowledge graph**, not a folder tree:

- **Nodes** are notes. A note's `type` is its job and its lifecycle.
- **Edges** are `[[wiki-links]]` (and `related:` frontmatter). Links are how the AI
  walks from one idea to the next; an unlinked note is invisible to graph retrieval.
- **Clusters** are communities Mesh detects from the link graph. A **map** note is a
  cluster's front door.

The rules below are not taste, they are what the retrieval engine rewards (see "Why
these rules").

## The eight note types

Every note declares exactly one `type`. Folder = type. Three families:

### Knowledge (permanent, never age-decayed)

| type | job | one-line test |
|---|---|---|
| **entity** | a *thing*: a system, tool, project, person, skill | "Could it have a logo or a repo?" |
| **concept** | an *idea*: how X works, a pattern, a principle | "Does it explain or teach something?" |
| **map** | a *Map of Content*: the front door to a domain, mostly `[[links]]` | "Is it a table of contents for a cluster?" |

### Institutional memory (permanent, **tier-0** — surfaces first in search)

| type | job | required body |
|---|---|---|
| **decision** | a choice you made and why | `**Do:** … **Don't:** … **Why:** …` |
| **gotcha** | a trap that cost time | `**Do:** … **Don't:** … **Why:** …` |
| **post-mortem** | an incident retro: what broke, root cause, fix | timeline + root cause + prevention |

These are the highest-value notes in the vault. Mesh boosts them and reserves part
of every search budget for them. Capture them with `mesh_append_note` the moment you
learn something, one fact per note.

### Working memory (ephemeral, **age-decays** in ranking)

| type | job | note |
|---|---|---|
| **note** | a loose capture that hasn't earned a home yet | promote it to a real type or delete it |
| **status** | a current-state snapshot (deploy state, sprint, inventory) | set `review_by`; it goes stale on purpose |

## Frontmatter schema

Keep it minimal and canonical. Extra keys are allowed but not required.

**Required on every note**

```yaml
id: kebab-case-stable-id     # identity; never changes, even on rename
type: entity                  # one of the eight above
title: Human Readable Title   # what search and the graph rank on
updated: 2026-01-01           # ISO date of last meaningful edit
```

**Recommended:** `tags` (1-4, cross-cutting), `related: [[other-note]]` (or link
inline). **Type-specific:** `do`/`dont`/`why` (decision/gotcha/post-mortem),
`role`/`stack`/`repo_path`/`status` (entity), `review_by` (anything that goes stale).

Do not invent parallel vocabularies (`kind` vs `type`, `domain` vs `tags`). One word
per concept.

## Linking: how connections are made

Links are the product. A note with no links is dead weight.

1. **Every note links at least 2 siblings.** An entity links the concepts it uses and
   the decisions that shaped it; a concept links the entities that apply it.
2. **Link the specific, not the hub.** Graph expansion *skips hub notes* (anything
   with many links: `index`, `log`, big maps). A link to `log.md` does nothing for
   retrieval. Link the atomic note.
3. **Link by id, in prose:** `[[note-id]]` inline where the connection is made. The
   `related:` frontmatter list works too.
4. **Decisions and gotchas link the entity they're about**, so the entity's
   neighborhood surfaces its institutional memory.

## Mapping: how a domain is navigated

A **map** is a cluster's front door. The target is **one map per domain**.

- `index.md` is the map-of-maps: it links every domain map.
- A domain map opens with one paragraph of context, then a linked list of the
  domain's key entities, concepts, and recent decisions. A map is mostly links.

This is the clear path: orient → index → domain map → atomic note.

## Lifecycle

| state | types | behavior |
|---|---|---|
| permanent | entity, concept, map, decision, gotcha, post-mortem | never age-decays |
| ephemeral | note, status | age-decays in ranking; `status` carries `review_by` |
| retired | entity | set `status: retired`; keep the note (history is memory) |

`mesh health` flags overdue `review_by`, dead refs, and contradictions.

## Why these rules (what the engine rewards)

- **Tier-0 boost:** `decision`/`gotcha`/`post-mortem` get a ranking multiplier and a
  reserved slice of every search budget. Capturing them discretely is the biggest win.
- **Hub skip:** expansion ignores high-degree hubs, so linking the specific note (not
  the index/log) is what actually pulls context.
- **Communities:** clean intra-domain linking makes clean clusters, which makes maps
  and orientation work.
- **Freshness decay:** `type` decides permanence, so typing a snapshot as `status`
  keeps stale state from outranking durable knowledge.

## The flywheel

Read at session start (orient) → work → write back: `mesh_append_note`
(decision|gotcha|post-mortem, one fact, with do/dont/why) and `mesh_write_entity` for
new systems. Run `mesh structure` for the organization grade. A vault that scores
well here is one a teammate, or an AI, can navigate on the first try.
