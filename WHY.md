# Why Second Brain for Claude

## The problem

Every time you start a new Claude Code conversation on a non-trivial codebase, Claude has no memory of what it learned last session. It starts from zero:

- Greps for a function name across 50k lines
- Reads random files to piece together architecture
- Asks you "where does X live?" even though you answered that last Tuesday
- Burns 20k+ tokens before making a single useful edit

On a monorepo with 20 services, this is the difference between a productive session and a session where you spend the first 10 minutes watching Claude explore.

## The fix, in one sentence

Give Claude a pre-built index of the code (the graph) plus a hand-curated wiki of the things the graph can't infer (business context, decisions, constraints), and enforce the lookup order with hooks so it can't skip it.

## The three layers

### 1. graphify (the fast index)

[graphify](https://github.com/graphifyy/graphify) extracts an AST-level knowledge graph of your codebase. Functions, types, imports, calls. Queryable in milliseconds from the CLI.

When you ask "where is user auth handled?", graphify returns the relevant nodes in one tool call instead of Claude grepping 40 files.

Rebuilds on every commit via git hook. Always fresh.

### 2. The wiki (the Karpathy layer)

Andrej Karpathy popularized the idea of an LLM-consumed wiki: markdown pages about your codebase written for a future you plus the LLM, not for new human employees. Each page is short, focused, and cross-linked.

Three page types:

- **Entities** - things that exist: services, products, clients, people
- **Concepts** - ideas you reason about: "how auth works", "the billing model"
- **Maps** - synthesis pages that pull together many entities into a picture

The graph can tell you WHAT code exists. The wiki tells you WHY it exists and HOW it connects to everything else, including things outside the repo.

### 3. The hooks (enforcement)

Claude Code has a hooks API. We use it to inject context at four moments:

1. **Every user prompt** reminds Claude of the work order
2. **Before Glob/Grep** reminds Claude to query the graph first
3. **Before spawning subagents** injects graph + wiki context into their prompts so they do not re-explore
4. **After `git push`** reminds Claude to update the wiki and rebuild the graph

Without hooks, Claude skips these steps under load. With hooks, the reminders are load-bearing.

## The work order

```
graphify query  ->  read wiki  ->  read source (only if needed)
                                    |
                                    v
                                  execute
                                    |
                                    v
                           commit -> push
                                    |
                                    v
                           update wiki entity + log
                                    |
                                    v
                           commit wiki
                                    |
                                    v
                           rebuild graphify
```

The order matters. The wiki + graph are downstream of the code, so they update AFTER the code ships. They are upstream of Claude's next session, so they save you tokens every conversation after.

## What this costs

- 5 to 10 minutes of setup
- A few minutes per meaningful feature to update the wiki entity page
- Disk space: graphify outputs are a few MB, wiki is tiny

What you get: conversations that start where the last one left off instead of square one.

## What this is not

- It is not a replacement for docs aimed at new human hires. Those are longer, more explanatory. This is dense notes for you + LLM.
- It is not magic. If your wiki pages are wrong or stale, Claude will act on wrong information. Update as you go.
- It is not a substitute for good code. A clear codebase + good naming is still the foundation. This is the layer above.
