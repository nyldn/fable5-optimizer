# Fable 5 Optimizer Project Instructions

This repo has two public instruction surfaces:

- On-demand skill: `skills/fable5-optimizer/SKILL.md`
- Always-on project policy template: `claude-md/CLAUDE.md`

Keep those surfaces semantically in sync. The skill may contain detailed command templates and delegation workflows. The `CLAUDE.md` template must stay concise because it is loaded in every project session after installation.

When changing routing guidance, delegation boundaries, verification requirements, install behavior, or release docs, update both surfaces or explicitly note why only one surface changed. Also update `README.md`, `install.sh`, and tests when install modes or target paths change.

Before release, run:

```bash
tests/install.sh
ruby -ryaml -e 'ARGV.each { |path| text = File.read(path); m = text.match(/\A---\n(.*?)\n---\n/m) or abort("missing frontmatter: #{path}"); data = YAML.safe_load(m[1]); abort("missing name: #{path}") unless data["name"]; abort("missing description: #{path}") unless data["description"]; puts "ok #{path}: #{data["name"]}" }' skills/*/SKILL.md
git diff --check
```
