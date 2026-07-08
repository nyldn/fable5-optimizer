# Contributing

Thanks for improving Fable 5 Optimizer.

This repo is intentionally small. It should stay focused on the `fable5-optimizer` routing policy and its two install surfaces.

## Instruction Surfaces

Keep these semantically in sync:

- `skills/fable5-optimizer/SKILL.md` for on-demand skill usage.
- `claude-md/CLAUDE.md` for always-on project instructions.

The skill can include detailed command templates and execution workflow. The `CLAUDE.md` template must work standalone: a project that installs only the template gets the full routing policy plus the Codex command mechanics needed to act on it. Keep it lean because it lives in always-loaded project memory, but self-sufficiency wins over brevity.

When a change affects routing guidance, delegation boundaries, verification requirements, install behavior, or release docs, update both instruction surfaces or explain why only one changed.

## What Makes a Good Change

- It solves a real failure mode from agent work.
- It keeps prompts and skill bodies short.
- It improves routing between Fable 5, Claude, and Codex without adding unnecessary ceremony.
- It avoids personal secrets, private paths, unpublished research, and raw screenshots/transcripts.
- It is easy for someone to adapt rather than blindly copy.

## Pull Request Checklist

- Explain the problem the change solves.
- Keep changes scoped to one behavior or documentation improvement.
- Confirm the skill and `CLAUDE.md` template are still semantically aligned.
- Validate YAML frontmatter in every changed `SKILL.md`.
- Run `tests/install.sh` if install behavior, target paths, README install commands, or `claude-md/CLAUDE.md` changed.
- Confirm no research/dropzone material was added.
- Confirm no credentials, tokens, private URLs, or account-specific secrets were added.

## Releases

Every release is versioned:

1. Move the `[Unreleased]` items in `CHANGELOG.md` into a new `[X.Y.Z] - YYYY-MM-DD` section and update the compare links.
2. Set the same version in the `version` field of `skills/fable5-optimizer/SKILL.md`.
3. Tag the release commit `vX.Y.Z` and push the tag.

Semantic versioning: major for breaking install/behavior changes, minor for new guidance or install surfaces, patch for fixes and wording.

## Local Validation

From the repo root:

```bash
ruby -ryaml -e 'ARGV.each { |path| text = File.read(path); m = text.match(/\A---\n(.*?)\n---\n/m) or abort("missing frontmatter: #{path}"); data = YAML.safe_load(m[1]); abort("missing name: #{path}") unless data["name"]; abort("missing description: #{path}") unless data["description"]; puts "ok #{path}: #{data["name"]}" }' skills/*/SKILL.md
tests/install.sh
tests/sync.sh
tests/codex-smoke.sh
git diff --check
```

Also read the changed skill as if you were Claude Code. The description should contain the trigger conditions, and the body should contain only instructions needed after the skill is selected.
