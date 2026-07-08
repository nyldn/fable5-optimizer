#!/usr/bin/env bash
set -euo pipefail

MODE="${1:-${FABLE5_OPTIMIZER_MODE:-user}}"
REPO_URL="${FABLE5_OPTIMIZER_REPO_URL:-https://github.com/nyldn/fable5-optimizer.git}"
SKILL_NAME="fable5-optimizer"

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

script_dir=""
script_source="${BASH_SOURCE[0]:-}"
if [[ -n "$script_source" && -e "$script_source" ]]; then
  script_dir="$(cd "$(dirname "$script_source")" >/dev/null 2>&1 && pwd -P || true)"
fi

if [[ -n "$script_dir" && -d "$script_dir/skills/$SKILL_NAME" ]]; then
  SOURCE_DIR="$script_dir"
else
  require git
  TMP_DIR="$(mktemp -d "${TMPDIR:-/tmp}/fable5-optimizer.XXXXXX")"
  SOURCE_DIR="$TMP_DIR/repo"
  git clone --quiet --depth 1 "$REPO_URL" "$SOURCE_DIR"
fi

copy_skill() {
  local src="$1"
  local dest="$2"

  if [[ -e "$dest" ]]; then
    local backup="${dest}.backup.$(date +%Y%m%d%H%M%S)"
    mv "$dest" "$backup"
    echo "Backed up existing skill to $backup"
  fi

  mkdir -p "$(dirname "$dest")"
  if command -v rsync >/dev/null 2>&1; then
    rsync -a "$src"/ "$dest"/
  else
    mkdir -p "$dest"
    cp -R "$src"/. "$dest"/
  fi
}

case "$MODE" in
  user|global)
    DEST="${FABLE5_OPTIMIZER_SKILLS_DIR:-$HOME/.claude/skills}/$SKILL_NAME"
    copy_skill "$SOURCE_DIR/skills/$SKILL_NAME" "$DEST"
    echo "Installed $SKILL_NAME to $DEST"
    ;;

  project)
    TARGET_DIR="${FABLE5_OPTIMIZER_TARGET:-$PWD}"
    DEST="$TARGET_DIR/.claude/skills/$SKILL_NAME"
    copy_skill "$SOURCE_DIR/skills/$SKILL_NAME" "$DEST"
    echo "Installed $SKILL_NAME to $DEST"
    ;;

  *)
    cat >&2 <<'USAGE'
Usage:
  install.sh [user|project]

Modes:
  user     Install to ~/.claude/skills/fable5-optimizer. Default.
  project  Install to ./.claude/skills/fable5-optimizer for the current project.
USAGE
    exit 2
    ;;
esac
