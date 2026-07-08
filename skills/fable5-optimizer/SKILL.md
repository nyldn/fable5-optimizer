---
name: fable5-optimizer
description: Decide when Claude/Fable 5 should steer work and when to delegate bounded execution, review, data gathering, or runtime verification to Codex/GPT-5.5. Use when the user asks about Fable 5 model routing, optimizing Fable 5 usage, using Codex for implementation or review, GPT-5.5 review, computer-use/browser verification, screenshots, or splitting work between Claude and Codex.
---

# Fable 5 Optimizer

Use this skill to keep Fable 5 focused on judgment and coordination while Codex handles bounded execution or evidence gathering.

## Core Rule

Fable 5 owns the work. Codex can help, but it does not replace Claude's responsibility to plan, inspect, verify, and report.

Route by the bottleneck:

| Work type | Default owner |
|---|---|
| Ambiguous architecture, product judgment, API design, UX taste, user-facing copy | Fable 5 or another high-taste Claude model |
| Final plan or implementation judgment | Fable 5, optionally with Codex as an independent reviewer |
| Clear mechanical implementation, migrations, repetitive edits, large text/data review | Codex |
| Independent code review of a diff, branch, commit, or implementation | Codex, then Claude verifies findings |
| Browser/app/simulator verification, screenshots, runtime UI checks | Codex if it has suitable local automation tools |

## Before Delegating

1. State the task boundary: files, behavior, acceptance criteria, and what must not change.
2. Check the worktree before asking Codex to edit. Do not overwrite user changes.
3. Prefer read-only Codex runs for review and verification.
4. Use `codex exec` for noninteractive work. Do not run bare `codex "prompt"` from Claude Code; that opens the interactive TUI.
5. If Codex is unavailable, say that clearly and continue with Claude's own tools when practical.

## Codex Review

Use Codex as a second reviewer, not as the only reviewer.

For uncommitted changes:

```bash
REPORT_DIR="$(mktemp -d "${TMPDIR:-/tmp}/fable5-review.XXXXXX")"
REPORT="$REPORT_DIR/report.md"
codex review --uncommitted - > "$REPORT" <<'PROMPT'
Review these changes for bugs, regressions, missing tests, security issues, and requirement mismatches.

Prioritize findings over summary. For each finding include severity, file/line reference, concrete failure mode, and suggested fix direction.
Do not edit files. If there are no substantive findings, say so and name residual test gaps.
PROMPT
```

For a branch diff, use `codex review --base main - > "$REPORT"` with the same prompt.

After Codex returns:

- Inspect each cited file or diff yourself.
- Report confirmed findings first.
- Separate confirmed issues from suggestions you did not verify.

## Codex Implementation

Use Codex for bounded implementation only when the expected change is clear.

```bash
REPORT_DIR="$(mktemp -d "${TMPDIR:-/tmp}/fable5-implementation.XXXXXX")"
REPORT="$REPORT_DIR/report.md"
codex exec -C "$PWD" -o "$REPORT" "Implement this bounded change. Keep edits scoped. Preserve existing style. Do not perform unrelated refactors. Run relevant lightweight verification if available and report files changed, checks run, failures, and blockers.

Task:
<exact task>

Acceptance criteria:
- <criterion>

Do not perform destructive git operations."
```

After Codex edits:

- Review the diff before reporting success.
- Run any important checks Codex skipped.
- Fix small misses directly when that is faster than another delegation.

## Runtime And Computer-Use Verification

Use this route for browser automation, screenshots, simulators, desktop app inspection, or checking a running UI.

```bash
REPORT_DIR="$(mktemp -d "${TMPDIR:-/tmp}/fable5-runtime.XXXXXX")"
REPORT="$REPORT_DIR/report.md"
codex exec -C "$PWD" -o "$REPORT" "Verify this runtime behavior using local browser/app automation or computer-use tools if available. Do not edit files. Prefer Playwright or browser automation for web apps. Capture screenshots for visual claims and save them under this report directory if possible.

Target:
- URL/app:
- Flow:
- Expected result:
- Evidence needed:

Rules:
- Do not use secrets unless explicitly provided for this task.
- Do not perform purchases, destructive actions, account changes, or terms acceptance.
- Report environment, steps performed, pass/fail result, evidence paths, and blockers."
```

Read the report and inspect screenshots or logs before summarizing.

## Reporting

When reporting back:

- Start with the decision or outcome.
- Name which parts Claude handled and which parts Codex handled.
- Cite concrete evidence: files changed, commands run, screenshots, logs, or reports.
- Call out anything not verified.
- Keep the explanation short unless the user asks for detail.
