<!-- fable5-optimizer:start -->
## Fable 5 Optimizer

When work could be split between Claude/Fable 5 and Codex/GPT-5.5, keep Claude/Fable 5 responsible for judgment, planning, architecture, product decisions, and final reporting.

Use Codex for bounded execution only when the task boundary is clear:

- independent code review of a diff, branch, commit, or implementation
- mechanical implementation, migrations, repetitive edits, or large text/data review
- runtime, browser, computer-use, screenshot, or evidence-gathering verification

Before delegating, state the files, behavior, acceptance criteria, and what must not change. Prefer read-only Codex runs for review and verification. After Codex returns, inspect the diff, report, or evidence yourself and separate confirmed findings from unverified suggestions.
<!-- fable5-optimizer:end -->
