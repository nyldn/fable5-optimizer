#!/usr/bin/env bash
# Verify the Codex CLI flags used by the skill's command templates still
# exist on the locally installed codex. Help-text probe only: no model
# calls, no auth, no repo changes. Skips cleanly when codex is absent
# (for example on CI runners).
set -euo pipefail

if ! command -v codex >/dev/null 2>&1; then
  echo "SKIP: codex not installed; template flag check not run"
  exit 0
fi

status=0

require_flag() {
  local help_text="$1"
  local flag="$2"
  local context="$3"
  if ! grep -q -- "$flag" <<<"$help_text"; then
    echo "missing flag '$flag' in $context help; skill templates need updating" >&2
    status=1
  fi
}

review_help="$(codex review --help 2>&1)"
require_flag "$review_help" "--uncommitted" "codex review"
require_flag "$review_help" "--base" "codex review"

exec_help="$(codex exec --help 2>&1)"
require_flag "$exec_help" "--cd" "codex exec"
require_flag "$exec_help" "--output-last-message" "codex exec"
require_flag "$exec_help" "--sandbox" "codex exec"
require_flag "$exec_help" "read-only" "codex exec"

if [[ "$status" -ne 0 ]]; then
  codex --version >&2 || true
  exit 1
fi
echo "OK: codex $(codex --version 2>/dev/null | tr -d '\n') exposes all flags used by skill templates"
