---
name: fable5-optimizer
version: 1.6.0
description: Load this skill before answering whenever a request mentions Codex, GPT-5.5, codex commands, or Fable 5, or asks which model or agent should handle, review, implement, or verify something. That includes advisory questions (should Claude or Codex handle this, who should review this branch diff, is this worth delegating), not just direct commands. Also covers delegating bounded implementation, independent code review, data gathering, or runtime verification to Codex; optimizing Fable 5 usage or effort settings; and requests to test a flow, verify UI behavior, inspect a running app, or capture screenshots needing local browser/computer-use automation. Do not use for ordinary implementation or review with no model-ownership question, and not for generic prompt rewriting.
---

# Fable 5 Optimizer

Keep Fable 5 focused on judgment and coordination while Codex handles bounded execution or evidence gathering.

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
| Cheap in-harness Claude subagent duty: Codex wrapper agents, structured summaries, glue between workflow stages | Sonnet 5 at low effort; for longer outputs Opus 4.8 is often cheaper because Sonnet 5 is token-hungry |

Escalate to Fable 5 judgment, regardless of the table, when the change touches a risk surface: API or schema contracts, security-sensitive code or CI configuration, release artifacts, user-facing UI, a new module, or a breaking change.

For large umbrella work, match the orchestration shape to the work: workflows suit deterministic fan-out and verification passes; checkpoint-driven work (each step needs CI, review, or a merge decision before the next) stays in the main session, spawning worktrees and using workflows only for the review passes.

## Effort Discipline

Run Fable 5 at `high` effort by default. Do not default to `xhigh`, `max`, or ultracode: effort applies per tool call and per change, not to how long the model can work, so higher settings do not extend runs. They make the model overthink each step, produce broader changes than asked, and cost far more. Long tasks run fine at `high` or below; raise effort only for a specific step that needs it.

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
5. Prompt Codex simply and directly; it is not Claude. Keep prompts brief and self-contained, and skip guardrails it does not need (Codex models rarely do things you did not ask for).
6. If Codex is unavailable, say that clearly and continue with Claude's own tools when practical.

## Codex Report Contract

Every delegation below asks Codex to report the same five things:

- status: done, blocked, or found issues / no issues
- files changed or reviewed
- checks run and their results
- evidence paths: reports, logs, screenshots
- blockers or gaps

## Codex Review

Use Codex as a second reviewer, not as the only reviewer. Keep small local checks with Claude; do not delegate review just to avoid reading the code yourself. Treat Codex's output as evidence, not authority.

Brief it like a fresh-context verifier: give it the diff or artifact and the acceptance criteria, not your reasoning or expected conclusion. A reviewer that sees the maker's reasoning tends to agree with it. Add task-specific context when it helps: requirements, risky areas, expected behavior, relevant tests, or files Claude is unsure about.

For uncommitted changes:

```bash
REPORT_DIR="$(mktemp -d "${TMPDIR:-/tmp}/fable5-review.XXXXXX")"
REPORT="$REPORT_DIR/report.md"
codex review --uncommitted > "$REPORT"
```

For a branch diff, use `codex review --base main > "$REPORT"`.

Current Codex CLI versions do not accept custom instructions together with `--uncommitted` or `--base`. When the review needs a specific focus (a requirement to check, a suspected failure mode), run a read-only exec instead:

```bash
codex exec -C "$PWD" --sandbox read-only -o "$REPORT" "Review <the uncommitted changes | the diff against <base>> for <focus>. Prioritize findings over summary: severity, file/line reference, concrete failure mode, suggested fix direction. Do not edit files. If there are no substantive findings, say so and name residual test gaps."
```

After Codex returns:

- Inspect each cited file or diff yourself.
- Report confirmed findings first.
- Separate confirmed issues from suggestions you did not verify.
- If Codex finds nothing, say that clearly and name the review target it inspected. Empty findings are a result, not a reason to rerun the review.

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

## Codex Inside Workflows And Subagents

Workflow and subagent model parameters only take Claude models, so reach Codex through a wrapper:

- Spawn a thin Claude wrapper agent (Sonnet 5 at low effort works well) whose prompt writes a self-contained Codex prompt, runs `codex exec` via Bash, and returns the report (use structured output on the wrapper when the caller needs fields).
- Label these agents with a `gpt-5.5` prefix (for example `gpt-5.5:review-auth`); the UI shows the wrapper's Claude model, so the label is the only sign the real worker is Codex.
- Codex runs can outlive the shell timeout: pass an explicit timeout, or run in the background and poll for the report file.
- Parallel Codex implementation agents need worktree isolation so their edits do not collide in a shared checkout.

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
