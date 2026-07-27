#!/usr/bin/env bash
set -euo pipefail

MODE="${1:-${FABLE5_OPTIMIZER_MODE:-skill}}"
REPO_URL="${FABLE5_OPTIMIZER_REPO_URL:-https://github.com/nyldn/fable5-optimizer.git}"
SKILL_NAME="fable5-optimizer"

TMP_DIR=""
TMP_FILE=""
cleanup() {
  if [[ -n "$TMP_DIR" && -d "$TMP_DIR" ]]; then
    rm -rf "$TMP_DIR"
  fi
  if [[ -n "$TMP_FILE" && -e "$TMP_FILE" ]]; then
    rm -f "$TMP_FILE"
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

# Backups of a skill folder must not land inside a skills root: Claude Code
# discovers every directory that contains a SKILL.md, so a sibling backup
# would register as a second skill with the same name.
skill_backup_target() {
  local dest="$1"
  local skills_dir claude_dir
  skills_dir="$(dirname "$dest")"
  claude_dir="$(dirname "$skills_dir")"
  printf '%s\n' "$claude_dir/skill-backups/$(basename "$dest")"
}

# GNU stat first: on GNU, `-f` means --file-system and would print filesystem
# details for the real path before failing, polluting the result. BSD stat
# rejects `-c` outright with no output, so this order is safe on both.
file_mode() {
  local mode
  if mode="$(stat -c '%a' "$1" 2>/dev/null)"; then
    printf '%s\n' "$mode"
    return 0
  fi
  stat -f '%Lp' "$1" 2>/dev/null
}

default_file_mode() {
  printf '%o\n' "$(( 0666 & ~8#$(umask) ))"
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

# Sets COPY_SKILL_CHANGED so callers can keep quiet about a no-op reinstall.
COPY_SKILL_CHANGED=0
copy_skill() {
  local src="$1"
  local dest="$2"

  COPY_SKILL_CHANGED=0
  if [[ -d "$dest" ]] && diff -rq "$src" "$dest" >/dev/null 2>&1; then
    return 0
  fi
  COPY_SKILL_CHANGED=1

  if [[ -e "$dest" ]]; then
    local backup
    backup="$(backup_path "$(skill_backup_target "$dest")")"
    mkdir -p "$(dirname "$backup")"
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
  if [[ "$COPY_SKILL_CHANGED" -eq 1 ]]; then
    echo "Installed project-local $SKILL_NAME skill to $dest"
  else
    echo "Project-local $SKILL_NAME skill already current at $dest"
  fi
}

install_claude_md() {
  local target_dir="${FABLE5_OPTIMIZER_TARGET:-$PWD}"
  local dest="${FABLE5_OPTIMIZER_CLAUDE_MD:-$target_dir/.claude/CLAUDE.md}"
  local dest_dir mode

  dest_dir="$(dirname "$dest")"
  mkdir -p "$dest_dir"

  # Stage in the destination directory so the final move is atomic and never
  # crosses a filesystem boundary.
  TMP_FILE="$(mktemp "$dest_dir/.fable5-optimizer-claude.XXXXXX")"

  if [[ -f "$dest" ]]; then
    # Drop the managed block plus any trailing blank lines, so rerunning the
    # installer reproduces the same bytes instead of growing a blank line.
    awk '
      /<!-- fable5-optimizer:start -->/ { skip = 1; next }
      /<!-- fable5-optimizer:end -->/ { skip = 0; next }
      skip { next }
      /^[[:space:]]*$/ { pending[count++] = $0; next }
      {
        for (i = 0; i < count; i++) print pending[i]
        count = 0
        print
      }
    ' "$dest" > "$TMP_FILE"
  fi

  if [[ -s "$TMP_FILE" ]]; then
    printf '\n' >> "$TMP_FILE"
  fi
  print_claude_md_block >> "$TMP_FILE"

  if [[ -f "$dest" ]] && cmp -s "$TMP_FILE" "$dest"; then
    rm -f "$TMP_FILE"
    TMP_FILE=""
    echo "Always-on $SKILL_NAME policy already current at $dest"
    return 0
  fi

  if [[ -f "$dest" ]]; then
    local backup
    backup="$(backup_path "$dest")"
    cp -p "$dest" "$backup"
    echo "Backed up existing CLAUDE.md to $backup"
    mode="$(file_mode "$dest")"
  fi

  # mktemp creates 0600; restore the previous mode, or the umask default for a
  # new file, so an installed CLAUDE.md stays readable like any other repo file.
  chmod "${mode:-$(default_file_mode)}" "$TMP_FILE"
  mv "$TMP_FILE" "$dest"
  TMP_FILE=""
  echo "Installed always-on $SKILL_NAME policy to $dest"
}

case "$MODE" in
  skill|user|global)
    DEST="${FABLE5_OPTIMIZER_SKILLS_DIR:-$HOME/.claude/skills}/$SKILL_NAME"
    copy_skill "$SOURCE_DIR/skills/$SKILL_NAME" "$DEST"
    if [[ "$COPY_SKILL_CHANGED" -eq 1 ]]; then
      echo "Installed $SKILL_NAME to $DEST"
    else
      echo "$SKILL_NAME already current at $DEST"
    fi
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
  install.sh [skill|skill-project|claude-md|claude-md-print]

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
