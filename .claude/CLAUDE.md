# Personal Preferences

## TypeScript
- Never use `any` unless 100% necessary or specifically instructed.

## Commands
- Do not run dev server commands (for example, `bun run dev`) unless specifically told; assume the dev server is already running.
- Do not run build commands unless specifically told.
- Focus on checking commands like `bun run typecheck`, `bun run lint`, and equivalent project checks.

## Package Managers
- Use pnpm if the project already uses it; otherwise use bun.
- Never use npm or yarn.

## Tech Stack Preferences
When uncertain, prefer: Tailwind, TypeScript, Bun, React, Convex, Clerk, Vercel.

## Code Style
- Always strive for concise, simple solutions.
- If a problem can be solved in a simpler way, propose it.

## General Preferences
- If asked to do too much work at once, stop and state that clearly.
- If computer use is helpful for completing or verifying work, shell out to GPT-5.5 with Codex for it.

## Fable 5 Effort
- Default Fable 5 to `high` reasoning effort.
- Do not use `xhigh`, `max`, or Ultra Code by default. They tend to overthink, loop longer per step, make broader changes than needed, and cost much more without reliably improving the result.
- Low, medium, and high can still run for long end-to-end tasks. Effort changes how much the model thinks per tool call or change, not whether it can keep working through many steps.

## Picking the Right Models for Workflows and Subagents

Rankings, higher = better. Cost reflects what I actually pay (OpenAI is near-free for me due to a deal), not list price. Intelligence is how hard a problem you can hand the model unsupervised. Taste covers UI/UX, code quality, API design, and copy.

| model | cost | intelligence | taste |
|---|---:|---:|---:|
| gpt-5.5 | 9 | 8 | 5 |
| sonnet-5 | 5 | 5 | 7 |
| opus-4.8 | 4 | 7 | 8 |
| fable-5 | 2 | 9 | 9 |

How to apply:
- These are defaults, not limits. You have standing permission to override them: if a cheaper model's output does not meet the bar, rerun or redo the work with a smarter model without asking. Judge the output, not the price tag. Escalating costs less than shipping mediocre work.
- Do not let cost prevent you from using the right model for the job. Instead, take advantage of cheaper options to get more information and try things before moving the work to a more expensive option.
- Bulk/mechanical work (clear-spec implementation, data analysis, migrations): gpt-5.5 - it is effectively free.
- Anything user-facing (UI, copy, API design) needs taste >= 7.
- Reviews of plans/implementations: fable-5 or opus-4.8, optionally gpt-5.5 as an extra independent perspective.
- Never use Haiku.
- Mechanics: gpt-5.5 is only reachable through the Codex CLI - `codex exec` / `codex review` (my `~/.codex/config.toml` defaults to gpt-5.5). Use the codex-implementation, codex-review, and codex-computer-use skills; for work they do not cover (investigation, data analysis), run `codex exec-readonly` if available, or `codex exec --sandbox read-only`, with a simple self-contained prompt.
- Claude models (sonnet-5, opus-4.8, fable-5) run via the Agent/Workflow `model` parameter.

Using gpt-5.5 inside workflows and subagents (the model parameter only takes Claude models, so use a wrapper):
- Spawn a thin Claude wrapper agent with `model: 'sonnet'`, `effort: 'low'` whose prompt instructs it to write a self-contained Codex prompt, run `codex exec` via Bash, and return the report (use `schema` on the wrapper to get structured output back).
- Always label these agents with a `gpt-5.5` prefix, e.g. `{label: 'gpt-5.5:review-auth'}` - the workflow UI shows the wrapper's Claude model, so the label is the only indication the real worker is gpt-5.5.
- Codex runs can exceed Bash's 10-minute timeout: pass an explicit timeout, or run in the background and poll for the report file.
- Parallel gpt-5.5 implementation agents must use `isolation: 'worktree'` so Codex edits do not collide in the shared checkout.
- Workflow token budgets only count Claude tokens; Codex work is free and invisible to `budget.spent()`.
