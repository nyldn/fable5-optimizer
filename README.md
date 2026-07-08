# Fable 5 Optimizer

Claude Code guidance for splitting work between Fable 5 and Codex (GPT-5.5). It ships in two forms: a skill that loads on demand when a task is about model routing, and a `CLAUDE.md` policy block you can install into a project so the rule applies to every session.

The premise: Fable 5 is the model you want making judgment calls, and the one you least want burning tokens on mechanical work. Codex is far cheaper and will grind through a migration or a review pass without complaint, but it should not be picking your architecture. This package tells Claude Code where that line sits and how to hand work across it.

## What you get

- A routing table saying which model owns which kind of work, plus the risk signals (API contracts, security surfaces, user-facing UI, breaking changes) that always escalate to Fable 5.
- A preparedness gate for complex tasks: when Codex should assemble a context packet first, so Fable 5 starts with judgment instead of rebuilding state.
- Working `codex` commands for review, bounded implementation, and browser or computer-use verification. All of them report against the same evidence contract.
- Guardrails: checkable acceptance criteria before delegating, fresh-context review briefs, and a rule for when an autonomous run should pause.

## Install

Pick one mode:

| Mode | Pick this if |
|---|---|
| On-demand skill (default) | You want `/fable5-optimizer` loaded only when a task is about Fable 5/Codex routing. Installs per user, works across all your projects. |
| Project-local skill | Same, but scoped to one project's `.claude/skills/`. |
| Always-on `CLAUDE.md` | You want the routing policy active in every session of one project, even when the skill would not trigger on its own. Costs a small amount of always-loaded context. |

### On-demand skill

The easiest path is to ask Claude Code:

```text
install this skill https://github.com/nyldn/fable5-optimizer
```

Or from the shell:

```bash
curl -fsSL https://raw.githubusercontent.com/nyldn/fable5-optimizer/main/install.sh | bash
```

Or from a cloned copy:

```bash
./install.sh
```

The default install writes to `~/.claude/skills/fable5-optimizer`. An existing skill folder gets backed up before it is replaced.

For the project-local variant:

```bash
curl -fsSL https://raw.githubusercontent.com/nyldn/fable5-optimizer/main/install.sh | bash -s -- skill-project
```

### Always-on CLAUDE.md

Run from the project root:

```bash
curl -fsSL https://raw.githubusercontent.com/nyldn/fable5-optimizer/main/install.sh | bash -s -- claude-md
```

Or from a cloned copy:

```bash
./install.sh claude-md
```

This writes a managed block to `.claude/CLAUDE.md` in the current project. If the file already exists it is backed up first, and re-running the installer replaces the block instead of stacking duplicates.

## Usage examples

Invoke the skill directly:

```text
/fable5-optimizer plan this change, then use Codex for an independent review
/fable5-optimizer use Codex to implement this bounded migration and verify the diff
/fable5-optimizer verify the running checkout flow with browser automation and screenshots
```

Claude Code will also load it on its own when a request is about Fable 5 model routing, Codex delegation, GPT-5.5 review, or computer-use verification.

## Requirements

- Claude Code with skills support.
- Codex CLI, installed and authenticated, if you want the delegation parts to run. Without it the routing guidance still works; Claude just tells you Codex is unavailable and carries on with its own tools.

Check both:

```bash
claude --version
codex --version
```

## Versioning

Releases follow semantic versioning and are tagged `vX.Y.Z`. History lives in [CHANGELOG.md](CHANGELOG.md).

## Contributing

Keep changes focused on the skill itself. If a new behavior needs helper files, put them under `skills/fable5-optimizer/` and reference them from `SKILL.md` so Claude knows when to use them.

See [CONTRIBUTING.md](CONTRIBUTING.md).

## License

MIT. See [LICENSE](LICENSE).
