#!/usr/bin/env bash
set -euo pipefail

MODE="${1:-${FABLE5_OPTIMIZER_MODE:-project}}"
REPO_URL="${FABLE5_OPTIMIZER_REPO_URL:-https://github.com/nyldn/fable5-optimizer.git}"

TMP_DIR=""
cleanup() {
  if [[ -n "$TMP_DIR" && -d "$TMP_DIR" ]]; then
    rm -rf "$TMP_DIR"
  fi
}
trap cleanup EXIT

require() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "Missing required command: $1" >&2
    exit 1
  fi
}

copy_dir() {
  local src="$1"
  local dest="$2"

  mkdir -p "$dest"
  if command -v rsync >/dev/null 2>&1; then
    rsync -a "$src"/ "$dest"/
  else
    cp -R "$src"/. "$dest"/
  fi
}

backup_file() {
  local file="$1"
  if [[ -f "$file" ]]; then
    local backup="${file}.backup.$(date +%Y%m%d%H%M%S)"
    cp -p "$file" "$backup"
    echo "Backed up existing $(basename "$file") to $backup"
  fi
}

replace_file() {
  local src="$1"
  local dest="$2"

  mkdir -p "$(dirname "$dest")"
  backup_file "$dest"
  cp "$src" "$dest"
}

install_settings() {
  local src="$1"
  local dest="$2"

  mkdir -p "$(dirname "$dest")"
  if [[ -f "$dest" ]]; then
    local example
    example="$(dirname "$dest")/settings.fable5-optimizer.json"
    cp "$src" "$example"
    echo "Existing settings.json left in place. Wrote hook settings example to $example"
    echo "Merge that PreToolUse entry if you want the Codex exec guard in this project."
  else
    cp "$src" "$dest"
    echo "Installed Codex exec guard settings into $dest"
  fi
}

script_dir=""
script_source="${BASH_SOURCE[0]:-}"
if [[ -n "$script_source" && -e "$script_source" ]]; then
  script_dir="$(cd "$(dirname "$script_source")" >/dev/null 2>&1 && pwd -P || true)"
fi

if [[ -n "$script_dir" && -d "$script_dir/.claude" ]]; then
  SOURCE_DIR="$script_dir"
else
  require git
  TMP_DIR="$(mktemp -d "${TMPDIR:-/tmp}/fable5-optimizer.XXXXXX")"
  SOURCE_DIR="$TMP_DIR/repo"
  git clone --quiet --depth 1 "$REPO_URL" "$SOURCE_DIR"
fi

case "$MODE" in
  project)
    TARGET_DIR="${FABLE5_OPTIMIZER_TARGET:-$PWD}"
    DEST="$TARGET_DIR/.claude"
    echo "Installing Fable 5 Optimizer into $DEST"

    replace_file "$SOURCE_DIR/.claude/CLAUDE.md" "$DEST/CLAUDE.md"
    copy_dir "$SOURCE_DIR/.claude/skills" "$DEST/skills"
    copy_dir "$SOURCE_DIR/.claude/hooks" "$DEST/hooks"
    install_settings "$SOURCE_DIR/.claude/settings.json" "$DEST/settings.json"
    echo "Done. Start Claude Code from this project with: claude"
    ;;

  user-skills|skills)
    DEST="${FABLE5_OPTIMIZER_SKILLS_DIR:-$HOME/.claude/skills}"
    echo "Installing Fable 5 Optimizer skills into $DEST"
    copy_dir "$SOURCE_DIR/.claude/skills" "$DEST"
    echo "Done. Skills are installed globally for Claude Code."
    ;;

  user)
    BASE="${FABLE5_OPTIMIZER_USER_DIR:-$HOME/.claude}"
    echo "Installing Fable 5 Optimizer skills into $BASE/skills"
    copy_dir "$SOURCE_DIR/.claude/skills" "$BASE/skills"
    mkdir -p "$BASE/fable5-optimizer"
    cp "$SOURCE_DIR/.claude/CLAUDE.md" "$BASE/fable5-optimizer/CLAUDE.md"
    echo "Done. Add this to $BASE/CLAUDE.md if you want the routing rules globally:"
    echo "@$BASE/fable5-optimizer/CLAUDE.md"
    ;;

  *)
    cat >&2 <<'USAGE'
Usage:
  install.sh [project|user-skills|user]

Modes:
  project      Install .claude/ into the current project. Default.
  user-skills  Install only the skills into ~/.claude/skills.
  user         Install skills plus an importable CLAUDE.md under ~/.claude/fable5-optimizer.
USAGE
    exit 2
    ;;
esac
