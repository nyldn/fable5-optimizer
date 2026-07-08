---
name: fable5-optimizer
version: 1.2.0
description: Use when the user asks how to route work between Claude/Fable 5 and Codex/GPT-5.5, wants to optimize Fable 5 usage, or wants Claude Code to delegate bounded implementation, independent code review, data gathering, or runtime verification to Codex. Trigger on phrases like Fable 5 model routing, Codex delegation, GPT-5.5 review, should Claude or Codex handle this, use Codex to implement or review, or have Codex verify with browser/computer-use/screenshots. Do not use for ordinary implementation or review unless the user is deciding model ownership or asking to involve Codex. Do not use for generic prompt rewriting.
---

# Fable 5 Optimizer

Use this skill to keep Fable 5 focused on judgment and coordination while Codex handles bounded execution or evidence gathering.

## Core Rule

Fable 5 owns the work. Codex can help, but it does not replace Claude's responsibility to plan, inspect, verify, and report.

Codex agreement never settles a judgment-class decision: choosing between valid architectures, design taste, or product tradeoffs stays with Fable 5 even when Codex output looks unanimous. And if making cheap-model output good would cost more supervision than doing the work with Fable 5, route it to Fable 5.

## Routing Gate

Route by the bottleneck:

| Work type | Default owner |
|---|---|
| Ambiguous architecture, product judgment, API design, UX taste, user-facing copy | Fable 5 or another high-taste Claude model |
| Final plan or implementation judgment | Fable 5, optionally with Codex as an independent reviewer |
| Clear mechanical implementation, migrations, repetitive edits, large text/data review | Codex |
| Independent code review of a diff, branch, commit, or implementation | Codex, then Claude verifies findings |
| Browser/app/simulator verification, screenshots, runtime UI checks | Codex if it has suitable local automation tools |
| Routine lookups, small rewrites, single-file fixes | Whichever is already in context; a cheaper model is often the right answer |

Escalate to Fable 5 judgment, regardless of the table, when the change touches a risk surface: API or schema contracts, security-sensitive code or CI configuration, release artifacts, user-facing UI, a new module, or a breaking change.

## Fable Preparedness Gate

Before asking Fable 5 for judgment on a complex active task, pick one path:

1. **Active context only** when the current conversation already holds the needed state.
2. **Prepared context packet** when state is spread across files, diffs, tool output, or prior decisions: have Codex assemble a short Markdown packet first.
3. **Quick checkpoint first** when Codex is near a natural stopping point: capture only the cheap nearby item (save the artifact, run the implied check, record the diff/status), then build the packet. Large missing work is recorded in the packet as a gap; it never blocks the judgment pass.

A useful packet fits on roughly a page: the ask, current state and decisions, relevant paths/diffs/screenshots, validation evidence or why it was skipped, what was tried or ruled out, known gaps, and the exact judgment requested. Do not create a packet just to look thorough; use it only when it saves Fable 5 from reconstructing state.

## Before Delegating

1. State the task boundary: files, behavior, acceptance criteria, and what must not change. Make criteria independently checkable ("the CSV has a numeric price column"), not vibes ("data looks right"). State your assumptions; if the ask has multiple readings, surface them instead of picking silently.
2. Check the worktree before asking Codex to edit. Do not overwrite user changes.
3. Prefer read-only Codex runs for review and verification.
4. Use `codex exec` for noninteractive work. Do not run bare `codex "prompt"` from Claude Code; that opens the interactive TUI.
5. If Codex is unavailable, say that clearly and continue with Claude's own tools when practical.

## Codex Report Contract

Every delegation below asks Codex to report the same five things:

- status: done, blocked, or found issues / no issues
- files changed or reviewed
- checks run and their results
- evidence paths: reports, logs, screenshots
- blockers or gaps

## Codex Review

Use Codex as a second reviewer, not as the only reviewer. Brief it like a fresh-context verifier: give it the diff or artifact and the acceptance criteria, not your reasoning or expected conclusion. A reviewer that sees the maker's reasoning tends to agree with it.

For uncommitted changes:

```bash
REPORT_DIR="$(mktemp -d "${TMPDIR:-/tmp}/fable5-review.XXXXXX")"
REPORT="$REPORT_DIR/report.md"
codex review --uncommitted > "$REPORT"
```

For a branch diff, use `codex review --base main > "$REPORT"`.

Current Codex CLI versions do not accept custom instructions together with `--uncommitted` or `--base`. When the review needs a specific focus (a requirement to check, a suspected failure mode), run a read-only exec instead:

```bash
codex exec -C "$PWD" --sandbox read-only -o "$REPORT" "Review the uncommitted changes for <focus>. Prioritize findings over summary: severity, file/line reference, concrete failure mode, suggested fix direction. Do not edit files. If there are no substantive findings, say so and name residual test gaps."
```

After Codex returns:

- Inspect each cited file or diff yourself.
- Report confirmed findings first.
- Separate confirmed issues from suggestions you did not verify.

## Codex Implementation

Use Codex for bounded implementation only when the expected change is clear. Where possible, phrase the task as a verifiable goal: "write a failing test that reproduces the bug, then make it pass" beats "fix the bug".

```bash
REPORT_DIR="$(mktemp -d "${TMPDIR:-/tmp}/fable5-implementation.XXXXXX")"
REPORT="$REPORT_DIR/report.md"
codex exec -C "$PWD" -o "$REPORT" "Implement this bounded change. Keep edits scoped. Preserve existing style. Do not perform unrelated refactors. Run relevant lightweight verification if available and report per the contract: status, files changed, checks run, evidence, blockers.

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
- Report per the contract: status, environment and steps, checks run, evidence paths, blockers."
```

Read the report and inspect screenshots or logs before summarizing. For visual claims, judge the screenshot against the intended result; a text-only pass/fail misses the failures that matter for UI work.

## Anti-Patterns

When writing prompts for Fable-directed or Codex-delegated work, avoid:

- asking for internal reasoning to be reproduced in the output; ask for the useful rationale instead
- token or context countdowns
- API parameter advice not confirmed against current official docs
- aggressive trigger language ("CRITICAL", "MUST") unless strict compliance wording is actually needed
- naming the target model as a role label inside a generated prompt body; use capability roles
- micromanaged step-by-step plans when a boundary and acceptance criteria are enough

## Checkpoints

Pause only for destructive or irreversible actions, a real scope change, or input only the user can provide. Otherwise keep going and report at the end.

## Reporting

When reporting back:

- Start with the decision or outcome.
- Name which parts Claude handled and which parts Codex handled.
- Cite concrete evidence: files changed, commands run, screenshots, logs, or reports.
- Call out anything not verified.
- If the work was already in good shape, say so and keep the diff minimal; do not invent changes to appear useful.
- Keep the explanation short unless the user asks for detail.
