# Fable 5 Optimizer

Claude Code configuration and skills for getting more out of Fable 5 without burning Fable 5 on work better handled by cheaper agents.

<p align="center">
  <img src="docs/assets/demo.gif" alt="Fable 5 Optimizer terminal demo showing Claude Code skills and routing rules" width="720">
</p>

This repo packages a small Claude Code setup:

- A project/user `CLAUDE.md` with model-routing rules for Fable 5, Opus 4.8, Sonnet 5, and Codex/GPT-5.5.
- A `codex-review` skill for independent second-pass review.
- A `codex-implementation` skill for bounded mechanical implementation work.
- A `codex-computer-use` skill for runtime verification, browser automation, screenshots, simulators, and desktop/app inspection through Codex.

The core idea is simple: let Fable 5 steer the work, make taste-heavy and ambiguous calls, and review important plans. Route token-heavy, mechanical, or computer-use work through Codex when that is the better tool.

## Why This Exists

Fable 5 is strongest when it is treated as an orchestrator and judgment model, not just a drop-in replacement for older Claude workflows.

The setup in this repo teaches Claude Code to:

- Use Fable 5 on `high` effort by default.
- Avoid `xhigh`, `max`, and Ultra Code unless there is a specific reason.
- Treat cost as a planning input, not a quality ceiling.
- Use Codex/GPT-5.5 for cheap, long-running, token-heavy work.
- Use Fable 5 or Opus 4.8 for user-facing UI, API design, copy, and final judgment.
- Keep Codex prompts short and task-specific instead of prompting Codex like Claude.
- Verify Codex findings before reporting them as true.

## What Is Included

```text
.claude/
  CLAUDE.md
  skills/
    codex-computer-use/
      SKILL.md
    codex-implementation/
      SKILL.md
    codex-review/
      SKILL.md
```

### `CLAUDE.md`

Sets the default working preferences and model-routing rubric:

- Fable 5 defaults to `high` effort.
- Codex/GPT-5.5 is preferred for bulk mechanical work, migrations, data analysis, log digging, and runtime verification.
- Taste-heavy work stays with Fable 5 or Opus 4.8.
- Reviews of plans and implementations should use Fable 5 or Opus 4.8, optionally with Codex as an independent extra perspective.

### `codex-review`

Runs Codex as an independent reviewer for:

- uncommitted changes
- branch diffs
- commits
- specific implementations

The skill tells Claude to verify Codex findings against the code before relaying them.

### `codex-implementation`

Uses Codex for bounded, clear-spec implementation work where the task is mechanical enough that taste and architecture judgment are not the bottleneck.

It is intentionally guarded: Claude still owns the plan, reviews the diff, and reports verification.

### `codex-computer-use`

Routes local app verification through Codex when the work needs:

- browser automation
- screenshots
- simulators
- desktop app inspection
- runtime UI checks
- long visual verification loops

It also records the important distinction that Anthropic's native computer-use tool is an API beta client tool, not something Claude Code should assume is locally available unless the runtime exposes it.

## Requirements

- Claude Code with skills support.
- Codex CLI installed and authenticated.
- A Codex configuration that routes to your intended GPT-5.5 model, or explicit `codex` command flags for your environment.
- Git.

Check local tools:

```bash
claude --version
codex --version
```

## Install

### Project-Level Install

Use this when you want the optimizer to apply to one repository.

```bash
git clone https://github.com/nyldn/fable5-optimizer.git
cd fable5-optimizer
rsync -av .claude/ /path/to/your-project/.claude/
```

Then start Claude Code from that project:

```bash
cd /path/to/your-project
claude
```

### User-Level Install

Use this when you want the skills available across projects.

```bash
git clone https://github.com/nyldn/fable5-optimizer.git ~/.claude/fable5-optimizer
mkdir -p ~/.claude/skills
rsync -av ~/.claude/fable5-optimizer/.claude/skills/ ~/.claude/skills/
```

For the routing rules, either merge the relevant parts of `.claude/CLAUDE.md` into your existing `~/.claude/CLAUDE.md`, or import it from your user-level file with an absolute path:

```md
@/Users/you/.claude/fable5-optimizer/.claude/CLAUDE.md
```

Do not blindly overwrite an existing `~/.claude/CLAUDE.md`; it likely contains your own preferences.

## Usage

Claude Code should load these automatically when they are relevant. You can also invoke the skills directly:

```text
/codex-review review the current uncommitted changes
/codex-implementation implement the bounded migration described in docs/plan.md
/codex-computer-use verify the checkout flow in the running app
```

Good requests are explicit about the target and evidence expected:

```text
Use Fable 5 to plan this change, then use Codex for a second-pass review of the branch diff before summarizing what is safe to merge.
```

```text
Verify the settings page in the running app. I care about the save flow, validation errors, and whether the confirmation toast appears. Use screenshots as evidence.
```

## Operating Model

Use this as a starting rubric, not a law:

| Work type | Default route |
|---|---|
| Ambiguous architecture or product judgment | Fable 5 |
| UI, copy, API design, SDK surface | Fable 5 or Opus 4.8 |
| Final plan/implementation review | Fable 5 or Opus 4.8, optionally Codex |
| Clear mechanical implementation | Codex/GPT-5.5 |
| Migrations, log digging, large-file review, data analysis | Codex/GPT-5.5 |
| Browser/app/simulator verification | Codex/GPT-5.5 through `codex-computer-use` |

The important habit is to ask: is this step about judgment and taste, or is it about cheap execution and evidence gathering?

## Safety Notes

- Review these files before installing. They encode one workflow and one set of preferences.
- Do not publish secrets in `CLAUDE.md`, skill files, prompts, screenshots, or reports.
- Keep computer-use tasks away from purchases, account changes, destructive actions, and terms acceptance unless a human explicitly confirms the action.
- Treat Codex output as evidence, not authority. Verify important claims.
- Keep public releases separate from research notes, transcripts, screenshots, and raw source material.

## Public Release Boundary

This public repo intentionally contains only the reusable Claude Code configuration and skills.

The working dropzone used to create it may contain private research material such as screenshots, transcripts, experiments, and notes. Those files are not part of the public release and should stay outside this repository.

## Contributing

Improvements are welcome. Keep changes small, practical, and grounded in real usage. If a change adds a new routing rule or skill behavior, include the problem it solves and the failure mode it prevents.

See [CONTRIBUTING.md](CONTRIBUTING.md) for details.

## License

MIT. See [LICENSE](LICENSE).
