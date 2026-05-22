# Second Brain for Claude

A Karpathy-inspired wiki + knowledge graph + hook setup that stops Claude Code from re-exploring your codebase every conversation.

## What it does

Teaches your Claude Code instance to look things up the way an experienced engineer would:

1. **Query a knowledge graph first** (fast index, low token cost)
2. **Read a hand-curated wiki second** (context the graph can't infer)
3. **Only touch source code when the first two didn't answer**

Enforced by hooks so Claude can't skip the order even if it wants to.

## Quick start

Clone this repo, open it in Claude Code, and say:

> Read SETUP.md and set this up in my environment.

Claude will ask you a handful of questions (project name, what to call your wiki, where it lives, etc.) and wire everything up: the wiki directory, hook config, CLAUDE.md, graphify install, and a verification run.

Expect 5 to 10 minutes for the first-time setup, most of which is graphify building its initial graph.

## What you get

- **A wiki** (you name it, default suggestion is your project name + "-brain") with `entities/`, `concepts/`, `maps/` pages Karpathy-style
- **graphify** ([open source](https://github.com/graphifyy/graphify) knowledge graph over your code)
- **Hooks** that remind Claude of the work order on every prompt, tool call, and git push, plus the **Boil the Ocean** standard so partial fixes don't ship
- **A `CLAUDE.md`** in your repo that documents the workflow for future sessions (and future teammates)
- **Guardrails** against directory drift and credential leaks (optional, can skip)

### Optional add-ons (opt-in during setup)

- **Stop hook** - warns at session end if you have uncommitted or unpushed work (catches the "I forgot to commit" failure mode)
- **`/adr` slash command** - capture architectural decisions into your wiki with one command
- **Scheduled jobs** - daily TLS cert sweep, nightly Go test-coverage report, daily Claude-spend rollup, weekly security + SEO drift checks. macOS launchd + Linux cron both supported. See [`docs/scheduled-jobs.md`](docs/scheduled-jobs.md).

## Why

See [WHY.md](WHY.md) for the token-waste story. Short version: a 50kloc codebase re-explored from scratch every conversation costs dozens of tool calls and hundreds of thousands of tokens before Claude even understands where anything is. This fixes that.

## Credits

Karpathy's LLM wiki approach is the spiritual inspiration. [graphify](https://github.com/graphifyy/graphify) by @graphifyy does the heavy lifting for the graph layer. Everything here is the glue.

## License

MIT.
