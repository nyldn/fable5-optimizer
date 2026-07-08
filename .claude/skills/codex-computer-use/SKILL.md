---
name: codex-computer-use
description: Ask Codex CLI with GPT-5.5 to run local app verification that needs computer use, browser automation, screenshots, app launching, simulators, or independent runtime inspection. Use when the user asks Claude to test a flow, verify UI behavior, inspect a running app, capture screenshots, drive a browser, launch a simulator or desktop app, or report evidence from the actual runtime. For code-only review use codex-review instead.
---

# Codex Computer Use

Use this skill when verification needs eyes and hands on a running interface. In Claude Code, do not assume the Anthropic API `computer_20251124` tool is available locally. Route practical browser, app, screenshot, and simulator checks through Codex unless the active Claude session already exposes a suitable native tool.

Treat Codex's report as evidence, not authority. Verify important claims before presenting them.

## Native Computer-Use Context

Anthropic's computer-use tool is a beta client tool for API integrations. It can request screenshots, mouse actions, keyboard actions, scrolling, dragging, clicks, waits, and zoom, but the application must provide the sandboxed desktop environment, execute the tool calls, return screenshots/results, and maintain the agent loop.

For the current Anthropic API, the modern tool type is `computer_20251124` and the beta header is `computer-use-2025-11-24`. Current docs list this as a client beta tool for supported Claude models; do not assume Fable 5 in Claude Code has direct native desktop control unless the active runtime exposes it.

Do not build a native Anthropic computer-use harness unless the user asks for one. If they do ask, follow the current Anthropic docs, use a sandboxed VM/container, include the required computer-use beta header, and require human confirmation before actions involving credentials, purchases, terms acceptance, destructive operations, or other real-world consequences.

## Workflow

1. Define the verification target:
   - app URL, window, simulator, desktop app, or command to launch
   - exact user flow or behavior to verify
   - expected outcome and known risky areas
   - whether screenshots or a visual pass/fail are required
2. Prefer an already-running app. If no app is running and no launch command is provided, ask before starting a dev server unless the user explicitly asked for app launching.
3. Create a report directory:

```bash
REPORT_DIR="$(mktemp -d "${TMPDIR:-/tmp}/codex-computer-use.XXXXXX")"
REPORT="$REPORT_DIR/report.md"
```

4. Run Codex with a focused verification prompt:

```bash
codex exec -C "$PWD" -o "$REPORT" "Use local browser/app automation or computer-use tools if available to verify the requested runtime behavior. Do not edit files. Prefer Playwright or browser automation for web apps. Capture screenshots for visual claims and save them under the report directory if possible. Inspect console, network, logs, or DOM state when relevant. After each meaningful step, verify the result instead of assuming success. Report environment, steps performed, evidence, screenshot paths, pass/fail result, and any issues with reproduction steps."
```

5. If Codex needs task-specific context, rerun with a fuller prompt that includes the URL, flow, credentials handling rules, expected behavior, and files/components likely involved.
6. Read the report. Open or inspect screenshot paths if Codex produced them.
7. Report back with verified facts first, then limitations or unverified Codex observations.

## Prompt Template

Use a simple prompt like this and fill in the target details:

```text
Verify this runtime behavior with local browser/app automation or computer-use tools if available:

Target:
- URL/app:
- Flow:
- Expected result:
- Evidence needed:

Rules:
- Do not edit files.
- Do not use secrets unless they are already explicitly provided for this task.
- Do not perform purchases, destructive actions, account changes, or terms acceptance.
- Prefer keyboard shortcuts if mouse interactions are unreliable.
- Capture screenshots for visual claims and report their paths.
- Verify each meaningful step before moving on.

Final report:
- environment used
- steps performed
- pass/fail result
- evidence and screenshot paths
- issues found, with reproduction steps
- blockers or residual uncertainty
```

## Reporting Back

Do not simply paste Codex's report if the user needs a decision. Summarize the pass/fail result, cite the concrete evidence, and call out blockers.

If Codex cannot access a browser, simulator, app, or computer-use tool, report that exact blocker and fall back to direct code/test inspection if useful.
