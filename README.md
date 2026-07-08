# Fable 5 Optimizer

A Claude Code skill for deciding when Fable 5 should steer the work and when Codex/GPT-5.5 should handle bounded execution, independent review, or runtime verification.

Use it when you want Claude Code to:

- keep Fable 5 focused on architecture, product judgment, planning, and final decisions
- delegate bounded implementation, review, data gathering, or runtime checks to Codex/GPT-5.5
- bring back concrete evidence before reporting that work is complete

## What The Skill Adds

- A routing gate: which model owns which work, plus risk signals (API contracts, security surfaces, UI, breaking changes) that always go to Fable 5.
- A preparedness gate: when to have Codex assemble a context packet so Fable 5 starts with judgment instead of state reconstruction.
- Ready-to-run `codex` command templates for review, bounded implementation, and browser/computer-use verification, all reporting against one evidence contract.
- Guardrails: checkable acceptance criteria before delegating, fresh-context review briefs, and a checkpoint rule for autonomous runs.

## Install

Choose one install mode:

| Mode | Choose this if |
|---|---|
| On-demand skill (default) | You want `/fable5-optimizer` loaded only when a task is about Fable 5/Codex routing. Installs per user, works across all projects. |
| Project-local skill | Same as above, but scoped to one project's `.claude/skills/`. |
| Always-on `CLAUDE.md` | You want the routing policy active in every session of one project, even when the skill would not auto-trigger. Costs a small amount of always-loaded context. |

### On-Demand Skill

The easiest path is to ask Claude Code to install the skill directly:

```text
install this skill https://github.com/nyldn/fable5-optimizer
```

Shell install:

```bash
curl -fsSL https://raw.githubusercontent.com/nyldn/fable5-optimizer/main/install.sh | bash
```

From a cloned copy:

```bash
./install.sh
```

The default skill install writes to `~/.claude/skills/fable5-optimizer`. Existing skill folders are backed up before replacement.

For a project-local skill instead:

```bash
curl -fsSL https://raw.githubusercontent.com/nyldn/fable5-optimizer/main/install.sh | bash -s -- skill-project
```

### Always-On CLAUDE.md

Run from the project root:

```bash
curl -fsSL https://raw.githubusercontent.com/nyldn/fable5-optimizer/main/install.sh | bash -s -- claude-md
```

From a cloned copy:

```bash
./install.sh claude-md
```

This writes a managed block to `.claude/CLAUDE.md` in the current project. If that file already exists, it is backed up first; re-running the installer replaces the existing `fable5-optimizer` block instead of duplicating it.

## Usage

Invoke directly:

```text
/fable5-optimizer plan this change, then use Codex for an independent review
/fable5-optimizer use Codex to implement this bounded migration and verify the diff
/fable5-optimizer verify the running checkout flow with browser automation and screenshots
```

Claude Code can also load the skill automatically when the request is about Fable 5 model routing, Codex delegation, GPT-5.5 review, or computer-use verification.

## Requirements

- Claude Code with skills support.
- Codex CLI installed and authenticated if you want the Codex delegation parts to run.

Check local tools:

```bash
claude --version
codex --version
```

## Versioning

Releases follow semantic versioning and are tagged `vX.Y.Z`. See [CHANGELOG.md](CHANGELOG.md).

## Contributing

Keep changes focused on the skill itself. If a new behavior needs helper files, put them under `skills/fable5-optimizer/` and reference them from `SKILL.md` so Claude knows when to use them.

See [CONTRIBUTING.md](CONTRIBUTING.md).

## License

MIT. See [LICENSE](LICENSE).
