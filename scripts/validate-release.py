#!/usr/bin/env python3
"""Validate the public Fable 5 Optimizer release package."""

from __future__ import annotations

import os
import json
import re
import subprocess
import sys
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
KEBAB_RE = re.compile(r"^[a-z0-9]+(?:-[a-z0-9]+)*$")
SEMVER_RE = re.compile(r"^\d+\.\d+\.\d+$")
DATE_RE = re.compile(r"^## \[\d+\.\d+\.\d+\] - \d{4}-\d{2}-\d{2}$", re.MULTILINE)


def fail(message: str, errors: list[str]) -> None:
    errors.append(message)


def read(path: Path) -> str:
    return path.read_text(encoding="utf-8", errors="replace")


def extract_frontmatter(path: Path) -> dict[str, str]:
    text = read(path)
    if not text.startswith("---\n"):
        raise ValueError("missing frontmatter")

    lines = text.splitlines()
    try:
        end = lines[1:].index("---") + 1
    except ValueError as exc:
        raise ValueError("missing closing frontmatter delimiter") from exc

    meta: dict[str, str] = {}
    for line in lines[1:end]:
        if not line.strip() or line.lstrip().startswith("#"):
            continue
        if ":" not in line:
            continue
        key, value = line.split(":", 1)
        meta[key.strip()] = value.strip().strip("\"'")
    return meta


def run(args: list[str], *, cwd: Path = ROOT) -> subprocess.CompletedProcess[str]:
    return subprocess.run(args, cwd=cwd, text=True, capture_output=True, check=False)


def validate_skills(errors: list[str]) -> None:
    skills_dir = ROOT / ".claude" / "skills"
    if not skills_dir.is_dir():
        fail(".claude/skills is missing", errors)
        return

    skills = sorted(skills_dir.glob("*/SKILL.md"))
    if not skills:
        fail("no skills found under .claude/skills/*/SKILL.md", errors)
        return

    for skill in skills:
        rel = skill.relative_to(ROOT)
        try:
            meta = extract_frontmatter(skill)
        except ValueError as exc:
            fail(f"{rel}: {exc}", errors)
            continue

        name = meta.get("name", "")
        description = meta.get("description", "")
        if not name:
            fail(f"{rel}: missing name", errors)
        elif not KEBAB_RE.match(name):
            fail(f"{rel}: name must be kebab-case: {name}", errors)
        if not description:
            fail(f"{rel}: missing description", errors)


def validate_installer(errors: list[str]) -> None:
    installer = ROOT / "install.sh"
    if not installer.is_file():
        fail("install.sh is missing", errors)
        return
    if not os.access(installer, os.X_OK):
        fail("install.sh is not executable", errors)

    result = run(["bash", "-n", str(installer)])
    if result.returncode != 0:
        fail(f"install.sh has bash syntax errors:\n{result.stderr}", errors)


def validate_metadata(errors: list[str]) -> None:
    version_path = ROOT / "VERSION"
    changelog_path = ROOT / "CHANGELOG.md"

    if not version_path.is_file():
        fail("VERSION is missing", errors)
        return

    version = read(version_path).strip()
    if not SEMVER_RE.match(version):
        fail(f"VERSION must be MAJOR.MINOR.PATCH, got: {version}", errors)

    if not changelog_path.is_file():
        fail("CHANGELOG.md is missing", errors)
        return

    changelog = read(changelog_path)
    if "## [Unreleased]" not in changelog:
        fail("CHANGELOG.md missing ## [Unreleased]", errors)
    if f"## [{version}] -" not in changelog:
        fail(f"CHANGELOG.md missing entry for VERSION {version}", errors)
    if not DATE_RE.search(changelog):
        fail("CHANGELOG.md missing dated release heading", errors)


def validate_hooks(errors: list[str]) -> None:
    settings = ROOT / ".claude" / "settings.json"
    hook = ROOT / ".claude" / "hooks" / "codex-exec-guard.sh"

    if not settings.is_file():
        fail(".claude/settings.json is missing", errors)
    else:
        try:
            data = json.loads(read(settings))
        except json.JSONDecodeError as exc:
            fail(f".claude/settings.json is invalid JSON: {exc}", errors)
        else:
            pre_tool = data.get("hooks", {}).get("PreToolUse", [])
            commands = [
                hook_def.get("command", "")
                for entry in pre_tool
                for hook_def in entry.get("hooks", [])
            ]
            if ".claude/hooks/codex-exec-guard.sh" not in commands:
                fail(".claude/settings.json does not register codex-exec-guard.sh", errors)

    if not hook.is_file():
        fail(".claude/hooks/codex-exec-guard.sh is missing", errors)
        return
    if not os.access(hook, os.X_OK):
        fail(".claude/hooks/codex-exec-guard.sh is not executable", errors)

    result = run(["bash", "-n", str(hook)])
    if result.returncode != 0:
        fail(f"codex-exec-guard.sh has bash syntax errors:\n{result.stderr}", errors)
        return

    blocked = subprocess.run(
        [str(hook)],
        input=json.dumps({"tool_input": {"command": 'codex "review this"'}}),
        text=True,
        capture_output=True,
        check=False,
    )
    if '"permissionDecision":"block"' not in blocked.stdout:
        fail("codex-exec-guard.sh did not block bare codex prompt", errors)

    allowed = subprocess.run(
        [str(hook)],
        input=json.dumps({"tool_input": {"command": 'codex exec --skip-git-repo-check "review this"'}}),
        text=True,
        capture_output=True,
        check=False,
    )
    if allowed.stdout.strip() != '{"decision":"allow"}':
        fail("codex-exec-guard.sh did not allow codex exec", errors)


def validate_docs(errors: list[str]) -> None:
    readme = ROOT / "README.md"
    if not readme.is_file():
        fail("README.md is missing", errors)
        return

    text = read(readme)
    required_snippets = [
        "docs/assets/demo.gif",
        "CHANGELOG.md",
        "VERSION",
        "codex-exec-guard",
        "curl -fsSL https://raw.githubusercontent.com/nyldn/fable5-optimizer/main/install.sh | bash",
        "curl -fsSL https://raw.githubusercontent.com/nyldn/fable5-optimizer/main/install.sh | bash -s -- user-skills",
        "/codex-review",
        "/codex-implementation",
        "/codex-computer-use",
    ]
    for snippet in required_snippets:
        if snippet not in text:
            fail(f"README.md missing expected snippet: {snippet}", errors)

    demo_gif = ROOT / "docs" / "assets" / "demo.gif"
    demo_tape = ROOT / "docs" / "assets" / "demo.tape"
    if not demo_gif.is_file():
        fail("docs/assets/demo.gif is missing", errors)
    elif demo_gif.stat().st_size > 5 * 1024 * 1024:
        fail("docs/assets/demo.gif is larger than 5 MB", errors)
    if not demo_tape.is_file():
        fail("docs/assets/demo.tape is missing", errors)


def validate_public_boundary(errors: list[str]) -> None:
    result = run(["git", "ls-files"])
    if result.returncode != 0:
        fail(f"git ls-files failed:\n{result.stderr}", errors)
        return

    blocked_patterns = [
        re.compile(r"(^|/)research/"),
        re.compile(r"(^|/)Docs/"),
        re.compile(r"(^|/)transcript\.md$"),
        re.compile(r"(^|/)example-claude\.md$"),
        re.compile(r"\.(png|jpe?g|webp|mov|mp4)$", re.IGNORECASE),
    ]
    allowed = {"docs/assets/demo.gif"}

    for file in result.stdout.splitlines():
        if file in allowed:
            continue
        for pattern in blocked_patterns:
            if pattern.search(file):
                fail(f"public release contains blocked research/media file: {file}", errors)
                break


def main() -> int:
    errors: list[str] = []
    if not (ROOT / ".claude" / "CLAUDE.md").is_file():
        fail(".claude/CLAUDE.md is missing", errors)

    validate_skills(errors)
    validate_installer(errors)
    validate_metadata(errors)
    validate_hooks(errors)
    validate_docs(errors)
    validate_public_boundary(errors)

    if errors:
        print(f"FAIL: {len(errors)} release validation issue(s)", file=sys.stderr)
        for error in errors:
            print(f"  - {error}", file=sys.stderr)
        return 1

    print("OK: release package validated")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
