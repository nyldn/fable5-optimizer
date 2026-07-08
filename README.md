# Fable 5 Optimizer

A Claude Code skill for deciding when Fable 5 should steer the work and when Codex should handle bounded execution, review, or runtime verification.

Use it when you want Claude Code to:

- keep Fable 5 focused on architecture, product judgment, planning, and final decisions
- delegate bounded implementation, review, data gathering, or runtime checks to Codex/GPT-5.5
- bring back concrete evidence before reporting that work is complete

## Install

Choose one install mode.

### On-Demand Skill

Use this when you want `/fable5-optimizer` available as a skill that Claude Code can load when the task is about Fable 5/Codex routing.

The easiest path is to ask Claude Code to install the skill directly:

```text
install this skill https://github.com/nyldn/fable5-optimizer
```

You can also install it from the shell.

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

Use this when you want the Fable 5/Codex routing policy active for every Claude Code session in a project, even when the skill does not auto-trigger. Run it from the project root:

```bash
curl -fsSL https://raw.githubusercontent.com/nyldn/fable5-optimizer/main/install.sh | bash -s -- claude-md
```

From a cloned copy:

```bash
./install.sh claude-md
```

The always-on install writes a managed block to `.claude/CLAUDE.md` in the current project. If that file already exists, it is backed up first; re-running the installer replaces the existing `fable5-optimizer` block instead of duplicating it.

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

## Public Boundary

Keep raw research notes, transcripts, screenshots, experiments, personal Claude preferences, project settings, hooks, generated demo media, and private model-cost assumptions outside this repo.

## Fable 5 Review Handoff

Use [FABLE5_HANDOFF.md](FABLE5_HANDOFF.md) as a paste-ready prompt when asking Fable 5 to review this repo and suggest or make focused improvements.

## Contributing

Keep changes focused on the skill itself. If a new behavior needs helper files, put them under `skills/fable5-optimizer/` and reference them from `SKILL.md` so Claude knows when to use them.

See [CONTRIBUTING.md](CONTRIBUTING.md).

## License

MIT. See [LICENSE](LICENSE).
