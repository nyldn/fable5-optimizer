# Skill Trigger Cases

Manual evaluation set for the `fable5-optimizer` skill description. After changing the frontmatter description, check each case in a fresh Claude Code session and confirm the load behavior matches.

## Should trigger

1. "Use Fable to judge this architecture and Codex to prepare the context."
2. "Have Codex implement this migration, then Fable review the plan."
3. "Use Codex browser automation to verify screenshots before Fable signs off."

## Should not trigger

4. "Review this diff." (no Fable/Codex routing intent)
5. "Rewrite this marketing prompt for Fable 5." (prompt rewriting, not routing or orchestration, unless the user also asks about model ownership)
