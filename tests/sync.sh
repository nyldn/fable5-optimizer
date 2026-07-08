#!/usr/bin/env bash
# The committed always-on template must be byte-identical to the block
# install.sh generates from the skill body. This makes drift between the
# two public instruction surfaces impossible instead of merely detectable.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
SKILL="$ROOT/skills/fable5-optimizer/SKILL.md"
TEMPLATE="$ROOT/claude-md/CLAUDE.md"

if ! diff -u <("$ROOT/install.sh" claude-md-print) "$TEMPLATE"; then
  echo "claude-md/CLAUDE.md is out of date. Regenerate with:" >&2
  echo "  ./install.sh claude-md-print > claude-md/CLAUDE.md" >&2
  exit 1
fi

ANCHORS=(
  "Fable 5"
  "Codex"
  "bounded"
  "verif"
  "destructive"
  "acceptance criteria"
)

for anchor in "${ANCHORS[@]}"; do
  if ! grep -qi -- "$anchor" "$SKILL"; then
    echo "missing anchor '$anchor' in $SKILL" >&2
    exit 1
  fi
done

for marker in "fable5-optimizer:start" "fable5-optimizer:end"; do
  if ! grep -q -- "$marker" "$TEMPLATE"; then
    echo "missing managed-block marker '$marker' in $TEMPLATE" >&2
    exit 1
  fi
done

echo "OK: always-on template matches the skill body"
