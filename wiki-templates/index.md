# {{WIKI_NAME}} Index

*Read this first.* Every page in the wiki is listed here with a one-line summary. See [`CLAUDE.md`](CLAUDE.md) for the operating model, [`ORGANIZATION.md`](ORGANIZATION.md) for how this vault is structured (the note types, linking, and mapping standard), and [`README.md`](README.md) for the human entry point.

**Counts:** 1 entity · 0 concepts · 1 map · 2 total

---

## Maps, synthesis pages

- [[architectural-decisions]] - ADR-style decision log (append with `/adr` if the slash command is installed)

## Entities

- [[{{PROJECT_NAME}}]] - TODO one-line summary after setup reads the repo

## Concepts

*(none yet. Create in `concepts/` when you have an idea worth a whole page.)*

---

## How to grow this

See [`ORGANIZATION.md`](ORGANIZATION.md) for the full standard. In short:

- New thing in your stack? Add an **entity** page.
- New idea you reason about? Add a **concept** page.
- Made a choice, or escaped a trap? Add a **decision** / **gotcha** (these are tier-0:
  search surfaces them first). Capture them with `mesh_append_note`.
- Bigger picture forming? Add a **map** (one per domain).
- Every push updates at least one of these + appends to `log.md`.
