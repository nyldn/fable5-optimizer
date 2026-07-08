# Security Policy

## Supported Versions

This repository publishes the latest version of the Claude Code configuration and skills. Older snapshots are not maintained separately.

## Reporting a Vulnerability

If you find a security issue, open a private security advisory on GitHub or contact the maintainers through the repository owner.

Please do not file public issues for:

- leaked credentials
- prompt injection paths that expose secrets
- unsafe computer-use behavior that could cause real-world actions
- private research material accidentally included in a release

## Handling Secrets

Do not put secrets in:

- `CLAUDE.md`
- skill files
- issue reports
- screenshots
- transcripts
- Codex or Claude prompts

Computer-use workflows should require human confirmation for purchases, account changes, destructive actions, accepting terms, or anything with real-world consequences.
