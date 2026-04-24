# Setup Instructions (for Claude)

You are being invoked to set up the Second Brain for Claude workflow in the user's environment. Work through these steps interactively. Do not skip ahead. Do not make assumptions about naming.

## Prerequisites check

Before anything, verify:
- Operating system (macOS, Linux, WSL)
- Python 3.11+ available
- git installed
- The user is invoking you from within an existing git repo OR has told you which repo to configure

If any are missing, stop and ask the user to install them first.

## Step 1: Gather inputs

Ask the user each of these in plain English, one at a time or as a batch. Do not proceed until you have answers.

1. **Project name.** What is the codebase you want Claude to learn? Example: "my-api", "acme-platform".
2. **Project path.** Absolute path to the repo. Default suggestion: the current working directory.
3. **Wiki name.** What do you want to call your wiki? This is the name you and Claude will refer to it as. Examples: "Hive" (Karpathy's term), "Brain", "Lorebook", "Kodex", "Atlas". Whatever clicks. Default suggestion: "Brain".
4. **Wiki path.** Where should the wiki directory live? It is a separate git repo. Default suggestion: `~/Desktop/<WikiName>`.
5. **Wiki scope.** Single project, or multi-project (will index several codebases)? Default: single.
6. **Primary language/stack.** Go, Python, TypeScript, Rust, mixed. Used to tune the starter entity page.

Store these as variables for the rest of the setup. The rest of this file uses:
- `{{WIKI_NAME}}` for the wiki name (e.g. `Brain`)
- `{{WIKI_NAME_UPPER}}` for the uppercase version, used in hook reminder text (e.g. `BRAIN`)
- `{{WIKI_PATH}}` for the wiki path
- `{{PROJECT_NAME}}` for the project name
- `{{PROJECT_PATH}}` for the project path
- `{{PROJECT_DESCRIPTION}}` for the one-line description
- `{{TODAY}}` for today's date in `YYYY-MM-DD` format (generate with `date +%Y-%m-%d`)

When you write files, substitute these placeholders with the real values. Never leave a `{{...}}` token in a shipped file. After substitution, run `grep -rn "{{" <output-paths>` and confirm zero hits before calling the step done.

## Step 2: Install graphify

Run `./scripts/install-graphify.sh`. On macOS it handles the expat library quirk (graphify needs `DYLD_LIBRARY_PATH=/opt/homebrew/opt/expat/lib` to find the XML parser).

Verify the install: `DYLD_LIBRARY_PATH=/opt/homebrew/opt/expat/lib ~/.local/bin/graphify --version` (or equivalent for the user's platform).

If the verify fails, stop and debug with the user before continuing.

## Step 3: Create the wiki

```bash
mkdir -p {{WIKI_PATH}}
cd {{WIKI_PATH}}
git init
```

Copy the contents of `wiki-templates/` into `{{WIKI_PATH}}`. Specifically:
- `index.md` - the entry point (customize first line to reference `{{PROJECT_NAME}}`)
- `log.md` - chronological log, append-only
- `CLAUDE.md` - rules for how Claude interacts with the wiki
- `README.md` - human-facing description
- `entities/_example.md` - rename to `{{PROJECT_NAME}}.md` and fill in a starter entity page
- `concepts/_example.md` - leave as `_example.md` so users know the pattern
- `maps/_example.md` - same

For the starter entity page, read the project's `README.md` / `package.json` / `go.mod` / root directory structure to populate:
- Purpose (one paragraph)
- Stack (from manifests)
- Top-level structure (from `ls`)
- Deploy target if you can find one (Dockerfile, compose, CI config)

Do not guess. If you can't find something, leave a `TODO: ask user` stub.

Commit the initial state:

```bash
cd {{WIKI_PATH}}
git add -A
git commit -m "init: second-brain scaffold for {{PROJECT_NAME}}"
```

## Step 4: Wire the hooks

Create `{{PROJECT_PATH}}/.claude/settings.json` from `templates/settings.json.template`. Substitute:
- `{{WIKI_PATH}}` in the hook commands
- `{{WIKI_NAME}}` in the reminder text

The hooks you install:

1. **UserPromptSubmit** - reminds Claude of the work order on every user message
2. **PreToolUse on Glob|Grep** - reminds Claude to query graphify first
3. **PreToolUse on Agent** - injects wiki + graphify context into subagent prompts so they don't explore from scratch
4. **PostToolUse on git push** - reminds Claude to update the wiki and rebuild the graph

If the user already has a `.claude/settings.json`, merge carefully. Do not clobber existing permissions. Present the merged output for approval before writing.

## Step 5: Generate CLAUDE.md for the project

Write `{{PROJECT_PATH}}/CLAUDE.md` from `templates/CLAUDE.md.template`. Substitute all placeholders.

This file is what Claude reads every time it opens the project. It documents:
- The work order
- How to query the wiki and graph
- How to update them after commits
- Project-specific conventions the user mentioned

If the project already has a CLAUDE.md, do not overwrite. Instead, append a section with the Second Brain workflow rules and ask the user to integrate.

## Step 6: Build the initial graph

```bash
cd {{PROJECT_PATH}}
DYLD_LIBRARY_PATH=/opt/homebrew/opt/expat/lib ~/.local/bin/graphify query "rebuild"
```

This takes a few minutes on first run (AST extraction across every file). Show progress to the user.

When done, the graph lives in `{{PROJECT_PATH}}/graphify-out/`.

## Step 7: Install the git hook for auto-rebuild

```bash
cd {{PROJECT_PATH}}
DYLD_LIBRARY_PATH=/opt/homebrew/opt/expat/lib ~/.local/bin/graphify hook install
```

This installs a `post-commit` hook that rebuilds the graph when code files change. Verify with `graphify hook status`.

## Step 8: Verify

Run `./scripts/verify-setup.sh`. It checks:
- `graphify query "<anything>"` returns results
- `{{WIKI_PATH}}/index.md` is readable
- `{{PROJECT_PATH}}/.claude/settings.json` is valid JSON with the four hooks
- `{{PROJECT_PATH}}/CLAUDE.md` exists
- `{{PROJECT_PATH}}/graphify-out/graph.json` exists
- The git hook is installed

Report results to the user.

## Step 9: Show the user how to use it

Tell them:

> Your Second Brain is live. From now on:
>
> 1. Every Claude conversation starts with the hooks reminding the work order
> 2. When you ask "how does X work?", Claude will query graphify and read `{{WIKI_PATH}}/entities/` before grepping source
> 3. After you commit and push, Claude will update `{{WIKI_PATH}}/entities/{{PROJECT_NAME}}.md` and rebuild the graph
> 4. You grow the wiki by adding entity, concept, and map pages as you go. See `{{WIKI_PATH}}/CLAUDE.md` for the Karpathy-style conventions.
>
> First thing to try: open a new Claude Code session in `{{PROJECT_PATH}}` and ask "what is this project?". Claude should answer from the wiki entity page you just created, not by re-reading source.

## Done criteria

Do not report "done" until:
- Verify script passes all checks
- User has run one test query and confirmed it uses the wiki + graph, not raw grep
- The wiki has at least one committed entity page

If any step fails, stop and debug with the user. Do not paper over errors.
