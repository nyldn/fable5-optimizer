#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
TMP_DIR="$(mktemp -d "${TMPDIR:-/tmp}/fable5-optimizer-test.XXXXXX")"
trap 'rm -rf "$TMP_DIR"' EXIT

HOME_DIR="$TMP_DIR/home"
PROJECT_DIR="$TMP_DIR/project"
mkdir -p "$HOME_DIR" "$PROJECT_DIR"

# GNU stat first; BSD stat rejects -c cleanly, while GNU -f would print
# filesystem details for the path before failing.
file_mode() {
  local mode
  if mode="$(stat -c '%a' "$1" 2>/dev/null)"; then
    printf '%s\n' "$mode"
    return 0
  fi
  stat -f '%Lp' "$1" 2>/dev/null
}

backup_inventory() {
  find "$1" -name '*.backup.*' | sort
}

HOME="$HOME_DIR" "$ROOT/install.sh" skill
test -f "$HOME_DIR/.claude/skills/fable5-optimizer/SKILL.md"

FABLE5_OPTIMIZER_TARGET="$PROJECT_DIR" "$ROOT/install.sh" skill-project
test -f "$PROJECT_DIR/.claude/skills/fable5-optimizer/SKILL.md"

mkdir -p "$PROJECT_DIR/.claude"
printf '# Project Instructions\n\nKeep this project-specific note.\n\t\nTrailing-whitespace line above must survive.\n' > "$PROJECT_DIR/.claude/CLAUDE.md"
# A distinctive mode proves the installer restores what was there, rather than
# hardcoding 644, and keeps the assertion independent of the runner's umask.
chmod 640 "$PROJECT_DIR/.claude/CLAUDE.md"

FABLE5_OPTIMIZER_TARGET="$PROJECT_DIR" "$ROOT/install.sh" claude-md
test -f "$PROJECT_DIR/.claude/CLAUDE.md"
test -f "$PROJECT_DIR/.claude/skills/fable5-optimizer/SKILL.md"
test -f "$PROJECT_DIR/.claude/skills/fable5-optimizer/references/codex-workflows.md"
grep -q "Keep this project-specific note." "$PROJECT_DIR/.claude/CLAUDE.md"
grep -q "# Model Routing" "$PROJECT_DIR/.claude/CLAUDE.md"
grep -q "Claude Opus 5" "$PROJECT_DIR/.claude/CLAUDE.md"
grep -q "GPT-5.6 Sol" "$PROJECT_DIR/.claude/CLAUDE.md"
grep -q "/fable5-optimizer" "$PROJECT_DIR/.claude/CLAUDE.md"
grep -q "fable5-optimizer:start" "$PROJECT_DIR/.claude/CLAUDE.md"
# Interior whitespace-only lines are user content and must be preserved byte
# for byte; only trailing blank lines are trimmed.
grep -q "^	$" "$PROJECT_DIR/.claude/CLAUDE.md"

cp "$PROJECT_DIR/.claude/CLAUDE.md" "$TMP_DIR/first-run.md"

# Rerunning must be a byte-for-byte no-op: no stacked blocks, no growing blank
# lines, no fresh backup of content that did not change.
FABLE5_OPTIMIZER_TARGET="$PROJECT_DIR" "$ROOT/install.sh" claude-md
FABLE5_OPTIMIZER_TARGET="$PROJECT_DIR" "$ROOT/install.sh" claude-md
test "$(grep -c "fable5-optimizer:start" "$PROJECT_DIR/.claude/CLAUDE.md")" -eq 1
diff -u "$TMP_DIR/first-run.md" "$PROJECT_DIR/.claude/CLAUDE.md"
backup_count="$(find "$PROJECT_DIR/.claude" -name 'CLAUDE.md.backup.*' | wc -l | tr -d ' ')"
test "$backup_count" -eq 1

# The installed policy must keep the mode it had, not inherit mktemp's 0600.
test "$(file_mode "$PROJECT_DIR/.claude/CLAUDE.md")" = "640"

# Skill backups must live outside the skills root; Claude Code discovers every
# directory below it that contains a SKILL.md, so a backup left there would
# register as a second skill claiming the same name.
printf '\nlocal edit\n' >> "$PROJECT_DIR/.claude/skills/fable5-optimizer/SKILL.md"
FABLE5_OPTIMIZER_TARGET="$PROJECT_DIR" "$ROOT/install.sh" skill-project
test "$(find "$PROJECT_DIR/.claude/skills" -name 'SKILL.md' | wc -l | tr -d ' ')" -eq 1
test "$(find "$PROJECT_DIR/.claude/skill-backups" -maxdepth 1 -mindepth 1 -type d | wc -l | tr -d ' ')" -eq 1
grep -q "local edit" "$PROJECT_DIR"/.claude/skill-backups/fable5-optimizer.backup.*/SKILL.md
! grep -q "local edit" "$PROJECT_DIR/.claude/skills/fable5-optimizer/SKILL.md"

# An unchanged skill reinstall creates no backup artifact anywhere in the tree.
backup_inventory "$PROJECT_DIR" > "$TMP_DIR/backups-before.txt"
FABLE5_OPTIMIZER_TARGET="$PROJECT_DIR" "$ROOT/install.sh" skill-project
backup_inventory "$PROJECT_DIR" > "$TMP_DIR/backups-after.txt"
diff -u "$TMP_DIR/backups-before.txt" "$TMP_DIR/backups-after.txt"

# A CLAUDE.md created from scratch gets the umask default, not mktemp's 0600.
FRESH_DIR="$TMP_DIR/fresh"
mkdir -p "$FRESH_DIR"
(
  umask 027
  FABLE5_OPTIMIZER_TARGET="$FRESH_DIR" "$ROOT/install.sh" claude-md
)
test "$(file_mode "$FRESH_DIR/.claude/CLAUDE.md")" = "640"

echo "OK: install modes validated"
