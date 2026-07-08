# Fable 5 Review Handoff

Paste this prompt into Claude Fable 5 from the repository root when you want a fresh review of this public skill release.

```text
I'm working on the public Claude Code skill repo `nyldn/fable5-optimizer`. The goal is to keep Fable 5 in charge of planning, judgment, and final verification while using Codex/GPT-5.5 for bounded implementation, independent review, and runtime evidence gathering.

Review what is currently in this repository and make focused improvements if they are clearly warranted.

Important context:
- This is intentionally a small public skill release, not a full Claude Code plugin.
- The public release should stay simple: `skills/fable5-optimizer/SKILL.md`, install instructions, lightweight repo hygiene, and no private research.
- Raw research, screenshots, transcripts, experiments, personal settings, private paths, hooks, generated demo media, and project-specific `.claude/settings.json` should not be added to the public repo.
- Do not reintroduce a repo-level `CLAUDE.md`, multiple skills, PostToolUse hooks, demo GIFs, plugin packaging, or broad automation unless the current files prove it is necessary.
- Follow current Anthropic skill conventions: a clear `SKILL.md` frontmatter block, a concise body, and optional support files only when they reduce complexity.
- Avoid prompts that ask Claude to reveal, transcribe, or explain hidden reasoning.

Fable 5 operating style for this review:
- When you have enough information to act, act. Do not narrate options you will not pursue.
- Keep changes scoped. Do not add features, abstractions, compatibility layers, or cleanup beyond what the review requires.
- Before reporting progress or success, audit each claim against an actual tool result from this session.
- Pause only for destructive or irreversible actions, a real scope change, or input that only the user can provide.
- If a user asks a question rather than asking for a change, answer the question and stop instead of editing files.
- Lead final output with the outcome, then give the smallest useful supporting detail.

Files to inspect first:
- `README.md`
- `install.sh`
- `skills/fable5-optimizer/SKILL.md`
- `CONTRIBUTING.md`
- `.github/workflows/test.yml`

Review questions:
1. Does the skill trigger description clearly match when Claude Code should load it?
2. Is the routing guidance between Fable 5, Codex review, Codex implementation, and computer-use verification clear without being over-prescriptive?
3. Will this install and behave well in Claude Code and Claude Code Desktop?
4. Does the README set expectations correctly for a single Claude Code skill?
5. Are the one-shot install commands safe, understandable, and easy to audit?
6. Is the public boundary clean, with no private research or local-only artifacts exposed?
7. Are there any instructions that could cause Fable 5 to overbuild, ask unnecessary permission, fabricate progress, or leak hidden reasoning?

If you make changes:
- Keep the diff small and directly tied to a review finding.
- Preserve the single-skill release shape.
- Do not perform destructive git operations.
- Do not force-push or change remotes.
- Do not add dependencies or a build system.
- Update documentation only when it reduces user confusion.

Validation to run before final response:
- `bash -n install.sh`
- Validate `skills/fable5-optimizer/SKILL.md` frontmatter parses as YAML and contains `name` and `description`.
- Run the repository's public-boundary checks from `.github/workflows/test.yml` or an equivalent local command.
- Smoke-test global and project installs in temporary directories if you changed install behavior.
- Run `git diff --check`.
- Inspect `git status --short`.

Final response format:
- Start with what changed or what you found.
- List files changed, if any.
- List validation commands and whether they passed.
- State anything important that was not verified.
```

Source used to shape this prompt: Anthropic's Fable 5 prompting guide (https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/prompting-claude-fable-5), especially the guidance on acting once enough context is available, keeping high-effort work scoped, grounding progress claims in tool evidence, setting boundaries, and refactoring older prompts or skills that are too prescriptive.
