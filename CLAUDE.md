# Fable 5 Optimizer Project Instructions

This repo has two public instruction surfaces:

- On-demand skill: `skills/fable5-optimizer/SKILL.md`
- Always-on project policy template: `claude-md/CLAUDE.md`

The skill body is the single source of truth. `claude-md/CLAUDE.md` is generated from it: never hand-edit that file. After changing `SKILL.md`, regenerate with:

```bash
./install.sh claude-md-print > claude-md/CLAUDE.md
```

`tests/sync.sh` fails CI if the generated file is stale. Write the skill body so it reads correctly on both surfaces (avoid "this skill" phrasing). Update `README.md`, `install.sh`, and tests when install modes or target paths change.

Before release, run:

```bash
tests/install.sh
tests/sync.sh
tests/codex-smoke.sh
ruby -ryaml -e 'ARGV.each { |path| text = File.read(path); m = text.match(/\A---\n(.*?)\n---\n/m) or abort("missing frontmatter: #{path}"); data = YAML.safe_load(m[1]); abort("missing name: #{path}") unless data["name"]; abort("missing description: #{path}") unless data["description"]; puts "ok #{path}: #{data["name"]}" }' skills/*/SKILL.md
git diff --check
```
