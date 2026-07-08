#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
HOOK="$ROOT/.claude/hooks/codex-exec-guard.sh"

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

run_hook() {
  local command="$1"
  python3 - "$command" <<'PY' | "$HOOK"
import json
import sys

print(json.dumps({"tool_input": {"command": sys.argv[1]}}))
PY
}

output="$(run_hook 'codex "review this branch"')"
if [[ "$output" != *'"permissionDecision":"block"'* ]] || [[ "$output" != *'codex exec --skip-git-repo-check'* ]]; then
  fail "expected bare codex prompt to be blocked, got: ${output:-<empty>}"
fi

output="$(run_hook 'codex --approval-mode full-auto -q "review this branch"')"
if [[ "$output" != *'"permissionDecision":"block"'* ]] || [[ "$output" != *'interactive Codex TUI'* ]]; then
  fail "expected obsolete noninteractive flags to be blocked, got: ${output:-<empty>}"
fi

output="$(run_hook 'codex exec --skip-git-repo-check "review this branch"')"
if [[ "$output" != '{"decision":"allow"}' ]]; then
  fail "expected codex exec to be allowed, got: ${output:-<empty>}"
fi

output="$(run_hook 'codex review --help')"
if [[ "$output" != '{"decision":"allow"}' ]]; then
  fail "expected codex review to be allowed, got: ${output:-<empty>}"
fi

echo "OK: codex exec guard"
