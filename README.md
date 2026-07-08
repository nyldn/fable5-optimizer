# Fable 5 Optimizer

A single Claude Code skill for deciding when Fable 5 should steer the work and when Codex should handle bounded execution, review, or runtime verification.

This repository is intentionally small. It follows the same basic shape as Anthropic skill releases: a `skills/<skill-name>/SKILL.md` folder, optional support files only when needed, and a short README.

## Install

Install globally for Claude Code:

```bash
curl -fsSL https://raw.githubusercontent.com/nyldn/fable5-optimizer/main/install.sh | bash
```

Install into the current project only:

```bash
curl -fsSL https://raw.githubusercontent.com/nyldn/fable5-optimizer/main/install.sh | bash -s -- project
```

From a cloned copy:

```bash
./install.sh
./install.sh project
```

The global install writes to `~/.claude/skills/fable5-optimizer`. The project install writes to `.claude/skills/fable5-optimizer` in the current directory. Existing skill folders are backed up before replacement.

## Usage

Invoke directly:

```text
/fable5-optimizer plan this change, then use Codex for an independent review
/fable5-optimizer use Codex to implement this bounded migration and verify the diff
/fable5-optimizer verify the running checkout flow with browser automation and screenshots
```

Claude Code can also load the skill automatically when the request is about Fable 5 model routing, Codex delegation, GPT-5.5 review, or computer-use verification.

## Included Files

```text
skills/
  fable5-optimizer/
    SKILL.md
```

The public repo does not include private research, screenshots, transcripts, personal Claude preferences, project-level `.claude/settings.json`, hooks, or generated demo media.

## Requirements

- Claude Code with skills support.
- Codex CLI installed and authenticated if you want the Codex delegation parts to run.

Check local tools:

```bash
claude --version
codex --version
```

## Public Boundary

This repository is the public release surface only. Keep raw research notes, transcripts, screenshots, experiments, and personal model-cost assumptions outside the repo.

## Fable 5 Review Handoff

Use [FABLE5_HANDOFF.md](FABLE5_HANDOFF.md) as a paste-ready prompt when asking Fable 5 to review this repo and suggest or make focused improvements.

## Contributing

Keep changes focused on the skill itself. If a new behavior needs helper files, put them under `skills/fable5-optimizer/` and reference them from `SKILL.md` so Claude knows when to use them.

See [CONTRIBUTING.md](CONTRIBUTING.md).

## License

MIT. See [LICENSE](LICENSE).
