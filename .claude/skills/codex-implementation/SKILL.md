---
name: codex-implementation
description: Ask Codex CLI with GPT-5.5 to make bounded, mechanical code changes and return a verified report. Use for clear-spec implementations, migrations, repetitive edits, data transformations, or isolated fixes where GPT-5.5's low cost is useful. Prefer Fable 5 or Opus 4.8 for ambiguous architecture, user-facing UI taste, API design judgment, or final review.
---

# Codex Implementation

Use Codex for bounded implementation work with a clear spec. Do not use it as a substitute for Claude reading the code, owning the plan, or reviewing the final diff.

Prefer an isolated worktree for parallel agents or risky edits. Use the current checkout only when the user asked for direct edits and there is no collision risk.

## Workflow

1. Define the exact task, files or areas in scope, acceptance criteria, and verification commands.
2. Check current worktree state before delegating. Do not overwrite user changes.
3. Create a report path:

```bash
REPORT_DIR="$(mktemp -d "${TMPDIR:-/tmp}/codex-implementation.XXXXXX")"
REPORT="$REPORT_DIR/report.md"
```

4. Run Codex with a concise, self-contained prompt:

```bash
codex exec -C "$PWD" -o "$REPORT" "Implement the bounded change described below. Keep edits scoped. Preserve existing style. Do not perform unrelated refactors. After editing, run the relevant verification commands if available and report the diff summary, files changed, verification results, and any blockers.

Task:
<describe the exact implementation request>

Acceptance criteria:
- <criterion>

Verification:
- <command or 'identify and run the relevant lightweight checks'>"
```

5. Inspect the resulting diff yourself before reporting success.
6. Run or review verification. If Codex skipped a needed check, run it directly or report why it could not be run.
7. Present the final outcome with changed files, verification results, and any remaining risks.

## Guardrails

- Do not delegate vague product judgment, visual taste, architecture tradeoffs, or final user-facing copy to Codex unless the result will be reviewed by Fable 5 or Opus 4.8.
- Do not allow Codex to make destructive git operations.
- Do not run multiple Codex implementation agents against the same checkout. Use isolated worktrees for parallel work.
- If Codex cannot complete the task, read the report, inspect the partial diff, and either finish directly or report the blocker.
