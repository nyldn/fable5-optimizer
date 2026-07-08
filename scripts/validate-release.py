#!/usr/bin/env python3
"""Validate the public Fable 5 Optimizer release package."""

from __future__ import annotations

import os
import re
import subprocess
import sys
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
KEBAB_RE = re.compile(r"^[a-z0-9]+(?:-[a-z0-9]+)*$")


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


def validate_docs(errors: list[str]) -> None:
    readme = ROOT / "README.md"
    if not readme.is_file():
        fail("README.md is missing", errors)
        return

    text = read(readme)
    required_snippets = [
        "docs/assets/demo.gif",
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
