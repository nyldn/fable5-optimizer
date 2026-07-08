<!-- fable5-optimizer:start -->
## Fable 5 / Codex routing policy

Claude/Fable 5 owns judgment: planning, architecture, product decisions, API design, user-facing work, and final reporting. Codex/GPT-5.5 (via the Codex CLI) handles bounded execution: mechanical implementation, migrations, repetitive edits, independent code review, large text/data review, and runtime/browser/computer-use verification.

Codex agreement never settles a judgment call between valid designs; that stays with Fable 5. Always escalate to Fable 5 judgment when a change touches API or schema contracts, security-sensitive code or CI, release artifacts, user-facing UI, a new module, or a breaking change.

### Delegating to Codex

Before delegating, state your assumptions and the task boundary: files, behavior, checkable acceptance criteria (not vibes), and what must not change. Check the worktree first; do not let Codex overwrite user changes. If the needed state is spread across files, diffs, or tool output, have Codex assemble a one-page context packet (ask, current state, decisions, paths/diffs, validation evidence, gaps) before asking Fable 5 for judgment.

Mechanics:

- Always use `codex exec` for noninteractive work; bare `codex "prompt"` opens an interactive TUI and hangs the session.
- Prompt Codex simply and directly; it is not Claude. Brief, self-contained prompts work best.
- Independent review: `codex review --uncommitted > "$REPORT"` or `codex review --base <branch> > "$REPORT"`. These take no custom prompt on current CLI versions; for a focused review, use `codex exec --sandbox read-only` and name the exact diff to inspect.
- Bounded implementation: `codex exec -C "$PWD" -o "$REPORT" "<task, acceptance criteria, what must not change; no destructive git operations>"`.
- Verification and data gathering: prefer read-only runs (`codex exec --sandbox read-only`).
- Brief a reviewer with the artifact and acceptance criteria only, never your reasoning or expected conclusion.
- Ask Codex to report: status, files changed or reviewed, checks run, evidence paths, blockers.
- If Codex is unavailable, say so and continue with Claude's own tools when practical.

### After Codex returns

Inspect the diff, report, or evidence yourself before relaying it: Codex output is evidence, not authority. Separate confirmed findings from unverified suggestions. Run important checks Codex skipped. For visual claims, look at the screenshot; do not accept a text-only pass. If Codex finds nothing, say so and name the target it inspected instead of rerunning the review. Do not guess APIs, versions, flags, or package names; verify by reading code or docs before asserting.

Run Fable 5 at `high` effort by default; effort applies per step, not to run length, and `xhigh`/`max`/ultracode mostly buy overthinking and cost.

Pause only for destructive or irreversible actions, a real scope change, or input only the user can provide; otherwise keep going and report at the end.
<!-- fable5-optimizer:end -->
