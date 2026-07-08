---
name: codex-review
description: Ask Codex CLI with GPT-5.5 for an independent code review of uncommitted changes, a branch diff, a commit, or a specific implementation. This is how GPT-5.5 is invoked for review work. Use when the user asks Claude to have Codex or GPT-5.5 review work, when the model-selection rubric calls for a GPT-5.5 review perspective, or when Codex should audit a diff, find bugs or regressions, or compare Claude's implementation against requirements. For a review by Claude itself, use the normal review process instead.
---

# Codex Review

Use Codex as an independent reviewer when the user wants a second-pass review or when a change is broad enough that another agent's perspective is useful.

Prefer Claude's normal review process for small local checks. Do not delegate review just to avoid reading the code yourself. Treat Codex's output as evidence, not authority.

## Workflow

1. Identify the review target: uncommitted changes, base branch, commit SHA, PR checkout, or specific files/implementation.
2. Create a temporary report path outside the review target:

```bash
REPORT_DIR="$(mktemp -d "${TMPDIR:-/tmp}/codex-review.XXXXXX")"
REPORT="$REPORT_DIR/report.md"
```

3. Run the appropriate Codex command.

For uncommitted changes:

```bash
codex review --uncommitted - > "$REPORT" <<'PROMPT'
Review these changes for bugs, regressions, missing tests, security issues, and requirement mismatches.

Prioritize findings over summary. For each finding include:
- severity
- file and line reference
- concrete failure mode
- suggested fix direction

Do not edit files. If there are no substantive findings, say so and name any residual test gaps.
PROMPT
```

For a branch diff:

```bash
codex review --base main - > "$REPORT" <<'PROMPT'
Review this branch diff for bugs, regressions, missing tests, security issues, and requirement mismatches.

Prioritize findings over summary. For each finding include severity, file and line reference, concrete failure mode, and suggested fix direction.
Do not edit files. If there are no substantive findings, say so and name any residual test gaps.
PROMPT
```

For a commit:

```bash
codex review --commit <sha> - > "$REPORT" <<'PROMPT'
Review this commit for bugs, regressions, missing tests, security issues, and requirement mismatches.

Prioritize findings over summary. For each finding include severity, file and line reference, concrete failure mode, and suggested fix direction.
Do not edit files. If there are no substantive findings, say so and name any residual test gaps.
PROMPT
```

For a review target that does not fit `codex review`, use `codex exec` with a self-contained prompt and write the final response to a report file:

```bash
codex exec -C "$PWD" -o "$REPORT" "Review the specified implementation for bugs, regressions, missing tests, security issues, and requirement mismatches. Do not edit files. Prioritize findings with file/line references and concrete failure modes."
```

4. Read the report and inspect any cited code or diff enough to decide whether each finding is real.
5. Report confirmed findings first. Separate confirmed issues from Codex suggestions you did not verify.

## Prompting Codex

Keep prompts brief and self-contained. Add task-specific context only when useful: requirements, risky areas, expected behavior, relevant tests, or files Claude is unsure about.

Use a code-review stance:

```text
Review these changes for bugs, regressions, missing tests, security issues, and requirement mismatches.

Prioritize findings over summary. For each finding include:
- severity
- file and line reference
- concrete failure mode
- suggested fix direction

Do not edit files. If there are no substantive findings, say so and name any residual test gaps.
```

## Reporting Back

Before relaying a Codex finding, inspect the cited code or diff enough to decide whether the finding is real. In the user-facing response, separate confirmed issues from Codex suggestions you did not verify.

If Codex finds nothing, say that clearly and mention what review target it inspected.

If `codex` is not installed or the command fails, report the error and offer to review the changes directly instead.
