# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html). Each release is tagged `vX.Y.Z` in git. The skill's frontmatter `version` field matches the latest release.

## [Unreleased]

## [1.5.0] - 2026-07-08

### Changed

- The always-on `CLAUDE.md` block is now generated from the skill body by `install.sh`, so an independent `claude-md` install carries the complete guidance (routing gate, effort discipline, preparedness gate, command templates, report contract, workflow wrapper pattern) instead of a hand-maintained subset.
- `claude-md/CLAUDE.md` in the repo is a generated artifact; `install.sh claude-md-print` regenerates it and `tests/sync.sh` now fails on any drift from the skill body, replacing the weaker anchor-only check.
- Skill body wording made surface-neutral so it reads correctly in both installs.

## [1.4.0] - 2026-07-08

### Added

- Effort discipline section: default Fable 5 to `high`; effort applies per step, not to run length, so `xhigh`/`max`/ultracode mostly add overthinking and cost.
- Codex-in-workflows section: thin Claude wrapper agent pattern, `gpt-5.5` label prefix, timeout/background handling, worktree isolation for parallel Codex implementers.
- Prompt-Codex-simply rule on both surfaces: brief, self-contained prompts; Codex is not Claude.
- Empty-findings rule on both surfaces: a clean review is a result, name the inspected target, do not rerun.
- Review boundaries: keep small local checks with Claude, treat Codex output as evidence not authority, add task-specific context (requirements, risky areas, tests) to review briefs.
- Orchestration-shape note: workflows for deterministic fan-out/verify; checkpoint-driven work stays in the main session with worktrees.
- Skill now also triggers when the user asks Claude to test a flow, verify UI behavior, or capture screenshots needing local automation, without naming Codex.

### Notes

- Derived from re-review of the source research material (video transcript and setup screenshots) against both surfaces.

## [1.3.0] - 2026-07-08

### Changed

- The always-on `CLAUDE.md` template is now standalone and complete: it carries the full routing policy plus the Codex command mechanics (noninteractive `codex exec`, review commands, read-only runs, report contract), so a project with only the template installed can act on the policy without the skill. Previously it was a summary that assumed the skill was present.
- Contributor docs updated: the template's rule is now "standalone first, lean second" instead of "keep it short".

## [1.2.2] - 2026-07-08

### Changed

- README rewritten in a plainer voice; the intro now presents both install surfaces (on-demand skill and always-on `CLAUDE.md` policy) instead of describing the project as a skill only.

## [1.2.1] - 2026-07-08

### Fixed

- Focused-review `codex exec` template no longer hardcodes "the uncommitted changes"; the diff target (uncommitted or against a base) is now an explicit placeholder. Found by an independent Codex review of the v1.2.0 diff.

## [1.2.0] - 2026-07-08

### Added

- Fable Preparedness Gate: three paths (active context, prepared context packet, quick checkpoint) with a compact packet field list and an anti-ceremony guard.
- Routing Gate: routine-work row, plus risk signals that force Fable 5 judgment (API/schema contracts, security surfaces, release artifacts, user-facing UI, new modules, breaking changes).
- Judgment-class rule: Codex agreement never settles architecture or taste decisions; route to Fable 5 when supervising cheaper output costs more than doing the work with Fable 5.
- Codex Report Contract: one report shape (status, files, checks, evidence, blockers) shared by review, implementation, and runtime verification.
- Fresh-context verifier briefing rule for Codex review: artifact and acceptance criteria only, never the maker's reasoning.
- Anti-pattern list for Fable-directed and Codex-delegated prompts.
- Checkpoint rule: pause only for destructive actions, real scope changes, or user-only input.
- Always-on template additions mirroring the skill: assumptions, checkable acceptance criteria, preparedness rule, no-guessing rule, checkpoint rule.
- `tests/sync.sh`: anchor sync check between the two instruction surfaces, wired into CI.
- `tests/codex-smoke.sh`: probes installed Codex CLI for the flags used by the skill's command templates (skips when codex is absent), wired into CI.
- `tests/trigger-cases.md`: manual trigger evaluation cases for the skill description.
- README install-mode chooser table.

### Fixed

- `codex review` command templates: Codex CLI 0.143.0 rejects a custom prompt combined with `--uncommitted`/`--base`; templates now use the plain form, with a read-only `codex exec` variant for focused reviews.

### Removed

- Internal review handoff prompt and internal maintainer notes moved out of the public repo; CI now blocks them from returning.

## [1.1.0] - 2026-07-08

### Added

- Always-on install surface: `claude-md/CLAUDE.md` template installed as a managed block into a project's `.claude/CLAUDE.md` via `install.sh claude-md` (idempotent, with backups).
- `tests/install.sh` covering the `skill`, `skill-project`, and `claude-md` install modes, wired into CI.
- Repo `CLAUDE.md` documenting the two-surface sync rule.

### Changed

- Tightened the skill trigger description: explicit trigger phrases plus negative triggers for ordinary implementation or review.

## [1.0.0] - 2026-07-08

### Added

- Initial public release: single `fable5-optimizer` skill routing work between Claude/Fable 5 and Codex/GPT-5.5, with review, implementation, and runtime verification command templates.
- One-shot installer (`install.sh`) with user and project modes.
- CI validation of the skill package and public boundary.

[Unreleased]: https://github.com/nyldn/fable5-optimizer/compare/v1.5.0...HEAD
[1.5.0]: https://github.com/nyldn/fable5-optimizer/compare/v1.4.0...v1.5.0
[1.4.0]: https://github.com/nyldn/fable5-optimizer/compare/v1.3.0...v1.4.0
[1.3.0]: https://github.com/nyldn/fable5-optimizer/compare/v1.2.2...v1.3.0
[1.2.2]: https://github.com/nyldn/fable5-optimizer/compare/v1.2.1...v1.2.2
[1.2.1]: https://github.com/nyldn/fable5-optimizer/compare/v1.2.0...v1.2.1
[1.2.0]: https://github.com/nyldn/fable5-optimizer/compare/v1.1.0...v1.2.0
[1.1.0]: https://github.com/nyldn/fable5-optimizer/compare/v1.0.0...v1.1.0
[1.0.0]: https://github.com/nyldn/fable5-optimizer/releases/tag/v1.0.0
