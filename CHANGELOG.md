# Changelog

All notable changes to Fable 5 Optimizer are documented here.

This project follows semantic versioning:

- Patch: documentation, validation, or wording changes that do not change installed behavior.
- Minor: new skills, hooks, install options, or routing behavior that remain backward compatible.
- Major: renamed skills, removed behavior, or install changes likely to break existing setups.

## [Unreleased]

## [0.1.0] - 2026-07-08

### Added

- Initial public `.claude/` package for Fable 5 routing with `codex-review`, `codex-implementation`, and `codex-computer-use` skills.
- One-shot installer for project and user-level installs.
- Terminal demo GIF and VHS source.
- Public release validator and GitHub Actions workflow.
- Codex exec guard hook that blocks bare `codex "prompt"` commands and points Claude Code toward `codex exec`.
