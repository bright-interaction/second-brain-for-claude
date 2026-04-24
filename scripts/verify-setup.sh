#!/usr/bin/env bash
# Verify that the Second Brain for Claude setup completed correctly.
# Usage: ./scripts/verify-setup.sh <wiki-path> <project-path>

set -euo pipefail

if [ "$#" -ne 2 ]; then
  echo "Usage: $0 <wiki-path> <project-path>"
  echo "Example: $0 ~/Desktop/Brain /path/to/my-project"
  exit 1
fi

WIKI_PATH="$1"
PROJECT_PATH="$2"
FAIL=0

check() {
  local label="$1"
  local condition="$2"
  if eval "$condition"; then
    echo "  PASS: $label"
  else
    echo "  FAIL: $label"
    FAIL=1
  fi
}

echo "==> Checking wiki at $WIKI_PATH"
check "wiki directory exists" "[ -d '$WIKI_PATH' ]"
check "wiki is a git repo" "[ -d '$WIKI_PATH/.git' ]"
check "wiki has index.md" "[ -f '$WIKI_PATH/index.md' ]"
check "wiki has log.md" "[ -f '$WIKI_PATH/log.md' ]"
check "wiki has CLAUDE.md" "[ -f '$WIKI_PATH/CLAUDE.md' ]"
check "wiki has at least one entity page" "ls '$WIKI_PATH/entities/'*.md >/dev/null 2>&1"

echo
echo "==> Checking project at $PROJECT_PATH"
check "project directory exists" "[ -d '$PROJECT_PATH' ]"
check "project has .claude/settings.json" "[ -f '$PROJECT_PATH/.claude/settings.json' ]"
check "project has CLAUDE.md" "[ -f '$PROJECT_PATH/CLAUDE.md' ]"
check "graphify-out exists" "[ -d '$PROJECT_PATH/graphify-out' ]"
check "graphify graph.json exists" "[ -f '$PROJECT_PATH/graphify-out/graph.json' ]"

echo
echo "==> Checking graphify"
if command -v python3 >/dev/null 2>&1; then
  if [ -f "$PROJECT_PATH/.claude/settings.json" ]; then
    check "settings.json is valid JSON" "python3 -c 'import json; json.load(open(\"$PROJECT_PATH/.claude/settings.json\"))' 2>/dev/null"
    check "settings.json has UserPromptSubmit hook" "python3 -c 'import json,sys; d=json.load(open(\"$PROJECT_PATH/.claude/settings.json\")); sys.exit(0 if \"UserPromptSubmit\" in d.get(\"hooks\",{}) else 1)'"
    check "settings.json has PreToolUse hook" "python3 -c 'import json,sys; d=json.load(open(\"$PROJECT_PATH/.claude/settings.json\")); sys.exit(0 if \"PreToolUse\" in d.get(\"hooks\",{}) else 1)'"
    check "settings.json has PostToolUse hook" "python3 -c 'import json,sys; d=json.load(open(\"$PROJECT_PATH/.claude/settings.json\")); sys.exit(0 if \"PostToolUse\" in d.get(\"hooks\",{}) else 1)'"
  fi
fi

GRAPHIFY_BIN="${HOME}/.local/bin/graphify"
if [ -f "$GRAPHIFY_BIN" ]; then
  check "graphify binary exists" "[ -x '$GRAPHIFY_BIN' ]"
else
  echo "  WARN: $GRAPHIFY_BIN not found. Did you run install-graphify.sh?"
  FAIL=1
fi

echo
if [ "$FAIL" -eq 0 ]; then
  echo "==> All checks passed. Second Brain is ready."
  echo "    Open Claude Code in $PROJECT_PATH and try: \"what is this project?\""
  exit 0
else
  echo "==> Some checks failed. See FAILs above and re-run SETUP.md steps as needed."
  exit 1
fi
