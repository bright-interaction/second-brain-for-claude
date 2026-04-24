# {{WIKI_NAME}}

Second brain for {{PROJECT_NAME}}. Karpathy-style LLM wiki.

## What

A curated collection of markdown pages about {{PROJECT_NAME}}, written for future-me and Claude. Covers things the code cannot self-document: why decisions were made, who uses what, how pieces connect beyond the repo.

## Layout

- `index.md` - entry point. Read first.
- `log.md` - append-only chronological log.
- `CLAUDE.md` - rules for how Claude reads and writes this wiki.
- `entities/` - pages about things that exist.
- `concepts/` - pages about ideas.
- `maps/` - synthesis pages.

## How to grow it

Every time you push non-trivial code to {{PROJECT_NAME}}, update the relevant entity page and append a log entry. The post-push hook in the main repo will remind Claude.

## Related

- graphify knowledge graph in the main {{PROJECT_NAME}} repo at `graphify-out/`
- Setup source: [second-brain-for-claude](https://github.com/YOURUSER/second-brain-for-claude)
