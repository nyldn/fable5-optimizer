#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
TMP_DIR="$(mktemp -d "${TMPDIR:-/tmp}/fable5-optimizer-test.XXXXXX")"
trap 'rm -rf "$TMP_DIR"' EXIT

HOME_DIR="$TMP_DIR/home"
PROJECT_DIR="$TMP_DIR/project"
mkdir -p "$HOME_DIR" "$PROJECT_DIR"

HOME="$HOME_DIR" "$ROOT/install.sh" skill
test -f "$HOME_DIR/.claude/skills/fable5-optimizer/SKILL.md"

FABLE5_OPTIMIZER_TARGET="$PROJECT_DIR" "$ROOT/install.sh" skill-project
test -f "$PROJECT_DIR/.claude/skills/fable5-optimizer/SKILL.md"

mkdir -p "$PROJECT_DIR/.claude"
printf '# Project Instructions\n\nKeep this project-specific note.\n' > "$PROJECT_DIR/.claude/CLAUDE.md"

FABLE5_OPTIMIZER_TARGET="$PROJECT_DIR" "$ROOT/install.sh" claude-md
test -f "$PROJECT_DIR/.claude/CLAUDE.md"
grep -q "Keep this project-specific note." "$PROJECT_DIR/.claude/CLAUDE.md"
grep -q "# Fable 5 Optimizer" "$PROJECT_DIR/.claude/CLAUDE.md"
grep -q "## Codex Report Contract" "$PROJECT_DIR/.claude/CLAUDE.md"
grep -q "fable5-optimizer:start" "$PROJECT_DIR/.claude/CLAUDE.md"

FABLE5_OPTIMIZER_TARGET="$PROJECT_DIR" "$ROOT/install.sh" claude-md
test "$(grep -c "fable5-optimizer:start" "$PROJECT_DIR/.claude/CLAUDE.md")" -eq 1
backup_count="$(find "$PROJECT_DIR/.claude" -name 'CLAUDE.md.backup.*' | wc -l | tr -d ' ')"
test "$backup_count" -ge 2

echo "OK: install modes validated"
