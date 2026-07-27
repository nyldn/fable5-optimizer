#!/usr/bin/env bash
set -euo pipefail

MODE="${1:-${FABLE5_OPTIMIZER_MODE:-skill}}"
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

backup_path() {
  local path="$1"
  local base="${path}.backup.$(date +%Y%m%d%H%M%S)"
  local candidate="$base"
  local counter=1

  while [[ -e "$candidate" ]]; do
    candidate="${base}.${counter}"
    counter=$((counter + 1))
  done

  printf '%s\n' "$candidate"
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
    local backup
    backup="$(backup_path "$dest")"
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

# The always-on block stays deliberately small. Detailed guidance lives in
# the project-local skill that claude-md mode installs alongside it.
print_claude_md_block() {
  local policy_md="$SOURCE_DIR/claude-md/POLICY.md"

  if [[ ! -f "$policy_md" ]]; then
    echo "Missing always-on policy source: $policy_md" >&2
    exit 1
  fi

  printf '<!-- fable5-optimizer:start -->\n'
  printf '<!-- Generated from claude-md/POLICY.md by install.sh. Do not hand-edit inside the markers. -->\n'
  cat "$policy_md"
  printf '<!-- fable5-optimizer:end -->\n'
}

install_project_skill() {
  local target_dir="$1"
  local dest="$target_dir/.claude/skills/$SKILL_NAME"

  copy_skill "$SOURCE_DIR/skills/$SKILL_NAME" "$dest"
  echo "Installed project-local $SKILL_NAME skill to $dest"
}

install_claude_md() {
  local target_dir="${FABLE5_OPTIMIZER_TARGET:-$PWD}"
  local dest="${FABLE5_OPTIMIZER_CLAUDE_MD:-$target_dir/.claude/CLAUDE.md}"
  local tmp

  mkdir -p "$(dirname "$dest")"
  tmp="$(mktemp "${TMPDIR:-/tmp}/fable5-optimizer-claude.XXXXXX")"

  if [[ -f "$dest" ]]; then
    local backup
    backup="$(backup_path "$dest")"
    cp "$dest" "$backup"
    echo "Backed up existing CLAUDE.md to $backup"
    awk '
      /<!-- fable5-optimizer:start -->/ { skip = 1; next }
      /<!-- fable5-optimizer:end -->/ { skip = 0; next }
      !skip { print }
    ' "$dest" > "$tmp"
  else
    : > "$tmp"
  fi

  if [[ -s "$tmp" ]]; then
    printf '\n' >> "$tmp"
  fi
  print_claude_md_block >> "$tmp"
  mv "$tmp" "$dest"
  echo "Installed always-on $SKILL_NAME policy to $dest"
}

case "$MODE" in
  skill|user|global)
    DEST="${FABLE5_OPTIMIZER_SKILLS_DIR:-$HOME/.claude/skills}/$SKILL_NAME"
    copy_skill "$SOURCE_DIR/skills/$SKILL_NAME" "$DEST"
    echo "Installed $SKILL_NAME to $DEST"
    ;;

  skill-project|project)
    TARGET_DIR="${FABLE5_OPTIMIZER_TARGET:-$PWD}"
    install_project_skill "$TARGET_DIR"
    ;;

  claude-md|always-on)
    TARGET_DIR="${FABLE5_OPTIMIZER_TARGET:-$PWD}"
    install_project_skill "$TARGET_DIR"
    install_claude_md
    ;;

  claude-md-print)
    print_claude_md_block
    ;;

  *)
    cat >&2 <<'USAGE'
Usage:
  install.sh [skill|skill-project|claude-md]

Modes:
  skill            Install to ~/.claude/skills/fable5-optimizer. Default.
  skill-project    Install to ./.claude/skills/fable5-optimizer for the current project.
  claude-md        Install a lightweight policy block to ./.claude/CLAUDE.md
                   plus the detailed project-local skill for on-demand use.
  claude-md-print  Print the generated block to stdout (used to regenerate
                   claude-md/CLAUDE.md in this repo).

Legacy aliases:
  user, global   Same as skill.
  project        Same as skill-project.
  always-on      Same as claude-md.
USAGE
    exit 2
    ;;
esac
