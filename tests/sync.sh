#!/usr/bin/env bash
# Both public instruction surfaces must keep the core routing anchors.
# This catches semantic drift between the on-demand skill and the
# always-on CLAUDE.md template; it does not replace reading both files.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
SKILL="$ROOT/skills/fable5-optimizer/SKILL.md"
TEMPLATE="$ROOT/claude-md/CLAUDE.md"

ANCHORS=(
  "Fable 5"
  "Codex"
  "bounded"
  "verif"
  "destructive"
  "acceptance criteria"
)

status=0
for file in "$SKILL" "$TEMPLATE"; do
  for anchor in "${ANCHORS[@]}"; do
    if ! grep -qi -- "$anchor" "$file"; then
      echo "missing anchor '$anchor' in $file" >&2
      status=1
    fi
  done
done

for marker in "fable5-optimizer:start" "fable5-optimizer:end"; do
  if ! grep -q -- "$marker" "$TEMPLATE"; then
    echo "missing managed-block marker '$marker' in $TEMPLATE" >&2
    status=1
  fi
done

if [[ "$status" -ne 0 ]]; then
  exit 1
fi
echo "OK: instruction surfaces share core anchors"
