# Hooks Explained

Four hooks, each load-bearing. If you remove one, the workflow degrades.

## 1. UserPromptSubmit

Fires: every time you send a message to Claude.

Does: Injects a short reminder with the work order and project-specific rules.

Why: Without this, Claude drifts back to default behavior under load. The reminder is a few hundred tokens, costs almost nothing, and keeps the loop honest.

What it injects:

```
1. graphify FIRST (query before grepping)
2. wiki SECOND (read before reading source)
3. work order: graphify -> wiki -> source -> execute -> commit -> push -> edit wiki -> commit wiki -> rebuild graph
4. structure rules specific to this project
```

## 2. PreToolUse on Glob|Grep

Fires: before Claude calls Glob or Grep.

Does: Reminds Claude to query graphify first.

Why: Grep is the natural default. Without this reminder, Claude greps first and queries graphify as an afterthought (or not at all). This hook catches the bad pattern at the moment it happens.

## 3. PreToolUse on Agent

Fires: before Claude spawns a subagent.

Does: Injects the graphify command, wiki path, and project structure path into the subagent's context.

Why: Subagents are fresh context windows. Without this, every subagent re-explores from scratch - wasting the whole setup. With this, subagents also hit graphify and wiki first.

## 4. PostToolUse on Bash(git push*)

Fires: after a successful `git push`.

Does: Reminds Claude of the 3-step wiki update: edit entity page, commit the wiki repo, rebuild graphify.

Why: This is the step Claude skips most. "I committed the code, so I'm done" feels complete but leaves the wiki stale for the next session. The hook is the backstop.

## What the hooks do not do

- They do not prevent Claude from doing the wrong thing. They remind.
- They do not inspect content. The Glob|Grep hook fires whether or not you already queried graphify.
- They do not block tool calls. They add context to the prompt, nothing more.

This is fine. The goal is to keep the work order top-of-mind, not to enforce it at runtime.

## Configuration

All four hooks live in `.claude/settings.json` under `hooks`. See `templates/settings.json.template` for the full JSON with inline comments.

Hooks can be edited while Claude Code is running. Changes apply to the next message.

## If hooks fire too often

If you find the reminders noisy:

- Cut the UserPromptSubmit text shorter
- Add an `if:` condition to the Bash hook to only fire for `git push origin main` (skip feature branches)
- Remove the Glob|Grep hook if you trust yourself to remember

Do not remove the PostToolUse on git push. That one actually saves you.
