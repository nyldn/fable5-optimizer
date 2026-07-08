#!/usr/bin/env bash
# PreToolUse Bash hook that blocks bare `codex "prompt"` dispatches.
set -euo pipefail

on_exit() {
  local code=$?
  if [[ $code -ne 0 ]]; then
    echo "[fable5-codex-exec-guard] exit $code" >&2 2>/dev/null || true
  fi
  return 0
}
trap on_exit EXIT

INPUT="$(cat 2>/dev/null || true)"
if [[ -z "$INPUT" ]]; then
  echo '{"decision":"allow"}'
  exit 0
fi

extract_command() {
  if command -v jq >/dev/null 2>&1; then
    jq -r '.tool_input.command // .command // ""' 2>/dev/null || true
    return
  fi

  if command -v python3 >/dev/null 2>&1; then
    python3 -c 'import json,sys; data=json.load(sys.stdin); print((data.get("tool_input") or {}).get("command") or data.get("command") or "")' 2>/dev/null || true
    return
  fi

  sed -n 's/.*"command"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' | head -1
}

COMMAND="$(printf '%s' "$INPUT" | extract_command)"
if [[ -z "$COMMAND" ]]; then
  echo '{"decision":"allow"}'
  exit 0
fi

if printf '%s\n' "$COMMAND" | grep -qE '^[[:space:]]*codex[[:space:]]+' && \
   ! printf '%s\n' "$COMMAND" | grep -qE '^[[:space:]]*codex[[:space:]]+(exec|exec-readonly|review|--version|version|--help|-h|login|auth|completion)\b'; then
  cat <<'JSON'
{"permissionDecision":"block","message":"BLOCKED: bare `codex \"prompt\"` opens the interactive Codex TUI, which is the wrong path for Claude Code Bash/tool automation.\n\nUse noninteractive Codex instead:\n```bash\ncodex exec --skip-git-repo-check \"YOUR PROMPT\"\n```\n\nFor long prompts, pipe stdin:\n```bash\ncodex exec --skip-git-repo-check - < prompt.md\n```\n\nFor review work, use `codex review` or the `/codex-review` skill."}
JSON
  exit 0
fi

echo '{"decision":"allow"}'
