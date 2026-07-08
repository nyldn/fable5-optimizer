<!-- fable5-optimizer:start -->
## Fable 5 Optimizer

When work could be split between Claude/Fable 5 and Codex/GPT-5.5, keep Claude/Fable 5 responsible for judgment, planning, architecture, product decisions, and final reporting.

Use Codex for bounded execution only when the task boundary is clear:

- independent code review of a diff, branch, commit, or implementation
- mechanical implementation, migrations, repetitive edits, or large text/data review
- runtime, browser, computer-use, screenshot, or evidence-gathering verification

Before delegating, state your assumptions and the task boundary: files, behavior, checkable acceptance criteria, and what must not change. If the needed state is spread across files, diffs, or tool output, have Codex assemble a short context packet before asking Fable 5 for judgment. Prefer read-only Codex runs for review and verification.

After Codex returns, inspect the diff, report, or evidence yourself and separate confirmed findings from unverified suggestions. Do not guess APIs, versions, flags, or package names; verify by reading code or docs before asserting.

Pause only for destructive or irreversible actions, a real scope change, or input only the user can provide; otherwise keep going and report at the end.
<!-- fable5-optimizer:end -->
