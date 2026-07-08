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

# The always-on block is generated from the skill body so both install
# surfaces always carry identical, complete guidance.
print_claude_md_block() {
  local skill_md="$SOURCE_DIR/skills/$SKILL_NAME/SKILL.md"

  if [[ ! -f "$skill_md" ]]; then
    echo "Missing skill source: $skill_md" >&2
    exit 1
  fi

  printf '<!-- fable5-optimizer:start -->\n'
  printf '<!-- Generated from skills/%s/SKILL.md by install.sh. Do not hand-edit inside the markers. -->\n' "$SKILL_NAME"
  awk '
    NR == 1 && /^---$/ { fm = 1; next }
    fm == 1 && /^---$/ { fm = 2; body = 0; next }
    fm == 1 { next }
    fm == 2 && body == 0 && /^$/ { next }
    { body = 1; print }
  ' "$skill_md"
  printf '<!-- fable5-optimizer:end -->\n'
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
    DEST="$TARGET_DIR/.claude/skills/$SKILL_NAME"
    copy_skill "$SOURCE_DIR/skills/$SKILL_NAME" "$DEST"
    echo "Installed $SKILL_NAME to $DEST"
    ;;

  claude-md|always-on)
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
  claude-md        Install an always-on policy block to ./.claude/CLAUDE.md.
                   The block is generated from the skill body, so it carries
                   the complete guidance.
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
