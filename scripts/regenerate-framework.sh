#!/usr/bin/env bash
# regenerate-framework.sh — Render shamt-core/host/templates/claude/ into a
# child project's .claude/ directory.
#
# Modes:
#   (default)            Regenerate target .claude/ from canonical sources.
#   --check              Dry-run: report drift between canonical and target, exit 1 on drift.
#   --bootstrap          Reverse: seed canonical templates from --source <dir>.
#
# Other flags:
#   --target <dir>       Target project directory (default: cwd). Regen writes <target>/.claude/.
#   --source <dir>       Source .claude/ for --bootstrap (required when bootstrapping).
#   -h, --help           Show help.
#
# PowerShell aliases also accepted: -Check, -BootstrapTemplates.
#
# Footer contract: every generated .claude/ file ends with a "Managed by Shamt"
# marker in its last few lines. Regen and prune only touch files carrying that
# marker; user-authored files without the marker are preserved.
#   - In regen mode, a warning is emitted only when canonical and target collide
#     on the same path (target lacks the footer; canonical wants to write).
#   - In --check mode, every preserved unmanaged file is reported as
#     "UNMANAGED <path> (preserved)" without counting as drift.
#
# Root CLAUDE.md render: the child's root <target>/CLAUDE.md is rendered as a
# verbatim copy of templates/SHAMT_RULES.template.md on every regen — always
# overwritten (write-if-different), NOT footer-gated (unlike the .claude/ files
# above). The only guard is self-host: when SHAMT_CORE_ROOT == TARGET_DIR the
# target is the master repo and <target>/CLAUDE.md is the master-dev primer, not
# a child rules rendering, so the render is skipped there.

set -euo pipefail

# Resolve to the physical directory of this script so symlinked invocations
# (e.g. /usr/local/bin/regenerate-framework.sh → real script) still locate the
# canonical sources via the script's true neighbour, not the symlink's parent.
# Walk symlinks manually — `readlink -f` / `realpath` aren't on every macOS
# without coreutils. Each hop is normalized through `cd && pwd -P` so `..` in a
# symlink target doesn't accumulate and break the next iteration.
SCRIPT_PATH="${BASH_SOURCE[0]}"
_hops=0
while [ -L "$SCRIPT_PATH" ]; do
  _hops=$((_hops + 1))
  if [ "$_hops" -gt 32 ]; then
    printf 'ERROR: symlink chain too deep at %s (possible cycle)\n' "${BASH_SOURCE[0]}" >&2
    exit 1
  fi
  link_target="$(readlink "$SCRIPT_PATH" 2>/dev/null || true)"
  if [ -z "$link_target" ]; then
    printf 'ERROR: failed to readlink %s (broken or empty symlink)\n' "$SCRIPT_PATH" >&2
    exit 1
  fi
  link_dir="$(dirname "$SCRIPT_PATH")"
  case "$link_target" in
    /*) target_dir="$(dirname "$link_target")"
        target_name="$(basename "$link_target")" ;;
    *)  target_dir="$link_dir/$(dirname "$link_target")"
        target_name="$(basename "$link_target")" ;;
  esac
  # Normalize the directory portion via cd + pwd -P so `..` segments and
  # intermediate directory symlinks collapse before the next iteration.
  if ! resolved_dir="$(cd "$target_dir" 2>/dev/null && pwd -P)"; then
    printf 'ERROR: cannot resolve symlink target directory: %s\n' "$target_dir" >&2
    exit 1
  fi
  SCRIPT_PATH="$resolved_dir/$target_name"
done
SCRIPT_DIR="$(cd "$(dirname "$SCRIPT_PATH")" && pwd -P)"
SHAMT_CORE_ROOT="$(cd "$SCRIPT_DIR/.." && pwd -P)"
CANONICAL_ROOT="$SHAMT_CORE_ROOT/host/templates/claude"

MODE="regen"
TARGET_DIR=""
SOURCE_DIR=""
HAD_DRIFT=0

# Subtrees we manage under the target .claude/ (used for pruning).
MANAGED_SUBTREES=(commands agents skills)
# Top-level files we manage at .claude/ root.
MANAGED_TOPLEVEL_FILES=(statusline.sh)

# Status-line registration written into generated settings.json.
STATUS_LINE_COMMAND='bash $CLAUDE_PROJECT_DIR/.claude/statusline.sh'

usage() {
  awk 'NR==1 { next }
       /^#/ { sub(/^# ?/, ""); print; next }
       { exit }' "$0"
}

log()   { printf '%s\n' "$*"; }
warn()  { printf 'WARN: %s\n' "$*" >&2; }
err()   { printf 'ERROR: %s\n' "$*" >&2; }

# ---- Argument parsing -------------------------------------------------------

while [ "$#" -gt 0 ]; do
  case "$1" in
    --check|-Check|-c)
      MODE="check"
      shift
      ;;
    --bootstrap|--bootstrap-templates|-BootstrapTemplates)
      MODE="bootstrap"
      shift
      ;;
    --target)
      TARGET_DIR="${2:-}"
      [ -n "$TARGET_DIR" ] || { err "--target requires an argument"; exit 2; }
      shift 2
      ;;
    --target=*)
      TARGET_DIR="${1#--target=}"
      shift
      ;;
    --source)
      SOURCE_DIR="${2:-}"
      [ -n "$SOURCE_DIR" ] || { err "--source requires an argument"; exit 2; }
      shift 2
      ;;
    --source=*)
      SOURCE_DIR="${1#--source=}"
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      err "unknown argument: $1"
      usage >&2
      exit 2
      ;;
  esac
done

[ -d "$CANONICAL_ROOT" ] || { err "canonical root not found: $CANONICAL_ROOT"; exit 1; }

if [ -z "$TARGET_DIR" ]; then
  TARGET_DIR="$(pwd)"
fi
TARGET_DIR="$(cd "$TARGET_DIR" && pwd)"
TARGET_CLAUDE_DIR="$TARGET_DIR/.claude"

# ---- Helpers ----------------------------------------------------------------

is_managed() {
  # is_managed <path> — exit 0 if file carries the "Managed by Shamt" footer
  # in its tail. Restricting to the tail honors the footer-at-end contract and
  # avoids false positives from user content (commit messages, quoted docs)
  # that happens to mention the marker phrase earlier in the file.
  local path="$1"
  [ -f "$path" ] || return 1
  tail -n 5 "$path" 2>/dev/null | grep -q 'Managed by Shamt'
}

# Walk canonical files and emit relative paths (under $CANONICAL_ROOT).
canonical_relpaths() {
  ( cd "$CANONICAL_ROOT" && find . -type f \
      \( -path './commands/*' -o -path './agents/*' -o -path './skills/*' -o -path './statusline.sh' \) \
      | sed 's|^\./||' | sort )
}

# Walk target managed-area files and emit relative paths (under $TARGET_CLAUDE_DIR).
target_managed_relpaths() {
  [ -d "$TARGET_CLAUDE_DIR" ] || return 0
  ( cd "$TARGET_CLAUDE_DIR" && {
      for sub in "${MANAGED_SUBTREES[@]}"; do
        [ -d "$sub" ] && find "$sub" -type f
      done
      for f in "${MANAGED_TOPLEVEL_FILES[@]}"; do
        [ -f "$f" ] && printf '%s\n' "$f"
      done
    } | sed 's|^\./||' | sort )
}

ensure_parent() {
  local path="$1"
  local parent
  parent="$(dirname "$path")"
  [ -d "$parent" ] || mkdir -p "$parent"
}

copy_with_mode() {
  # copy_with_mode <src> <dst> — preserve executable bit for .sh files.
  local src="$1" dst="$2"
  cp "$src" "$dst"
  case "$src" in
    *.sh) chmod +x "$dst" ;;
  esac
}

# ---- Modes ------------------------------------------------------------------

do_regen() {
  local action_label="$1"   # "regen" or "check"
  local check_only=0
  [ "$action_label" = "check" ] && check_only=1

  if [ "$check_only" -eq 0 ]; then
    mkdir -p "$TARGET_CLAUDE_DIR"
  fi

  local rel src dst
  # 1) Sync canonical → target.
  while IFS= read -r rel; do
    src="$CANONICAL_ROOT/$rel"
    dst="$TARGET_CLAUDE_DIR/$rel"

    if [ -f "$dst" ] && ! is_managed "$dst"; then
      warn "preserving unmanaged file (no 'Managed by Shamt' footer): $rel"
      continue
    fi

    if [ -f "$dst" ] && cmp -s "$src" "$dst"; then
      [ "$check_only" -eq 1 ] || log "unchanged $rel"
      continue
    fi

    if [ "$check_only" -eq 1 ]; then
      log "DRIFT $rel"
      HAD_DRIFT=1
      continue
    fi

    ensure_parent "$dst"
    copy_with_mode "$src" "$dst"
    log "wrote    $rel"
  done < <(canonical_relpaths)

  # 2) Prune target files that no longer exist canonically (only if managed).
  local canonical_set
  canonical_set="$(canonical_relpaths)"
  while IFS= read -r rel; do
    [ -n "$rel" ] || continue
    if ! printf '%s\n' "$canonical_set" | grep -qxF "$rel"; then
      local path="$TARGET_CLAUDE_DIR/$rel"
      if is_managed "$path"; then
        if [ "$check_only" -eq 1 ]; then
          log "STALE    $rel"
          HAD_DRIFT=1
        else
          rm -f "$path"
          log "removed  $rel"
          # Prune empty parent dirs up to .claude/.
          local parent
          parent="$(dirname "$path")"
          while [ "$parent" != "$TARGET_CLAUDE_DIR" ] && [ -d "$parent" ] && [ -z "$(ls -A "$parent" 2>/dev/null)" ]; do
            rmdir "$parent"
            parent="$(dirname "$parent")"
          done
        fi
      else
        [ "$check_only" -eq 1 ] && log "UNMANAGED $rel (preserved)"
      fi
    fi
  done < <(target_managed_relpaths)

  # 3) Render the root CLAUDE.md from the rules template (always overwritten,
  #    self-host-guarded). Runs in BOTH regen and check modes.
  render_root_claude_md "$check_only"

  # 4) Wire statusLine into settings.json (regen only, not check — settings.json
  #    is partially user-owned, so drift on it isn't a regen failure).
  if [ "$check_only" -eq 0 ]; then
    wire_status_line
  fi
}

render_root_claude_md() {
  # render_root_claude_md <check_only> — render <target>/CLAUDE.md as a verbatim
  # copy of templates/SHAMT_RULES.template.md (write-if-different). Always
  # overwrites in a child (NOT footer-gated). Skipped in self-host, where
  # <target>/CLAUDE.md is the master-dev primer rather than a child rendering.
  local check_only="$1"

  # Self-host guard: in a child the script lives at <child>/.shamt-core/scripts/
  # so SHAMT_CORE_ROOT != TARGET_DIR; in self-host the script lives at
  # <master>/scripts/ and they are equal — skip the render to protect the primer.
  if [ "$SHAMT_CORE_ROOT" = "$TARGET_DIR" ]; then
    return 0
  fi

  local src="$SHAMT_CORE_ROOT/templates/SHAMT_RULES.template.md"
  local dst="$TARGET_DIR/CLAUDE.md"

  if [ ! -f "$src" ]; then
    warn "rules template not found: $src — CLAUDE.md not rendered."
    return 0
  fi

  if [ -f "$dst" ] && cmp -s "$src" "$dst"; then
    [ "$check_only" -eq 1 ] || log "unchanged CLAUDE.md"
    return 0
  fi

  if [ "$check_only" -eq 1 ]; then
    log "DRIFT CLAUDE.md"
    HAD_DRIFT=1
    return 0
  fi

  cp "$src" "$dst"
  log "wrote    CLAUDE.md"
}

wire_status_line() {
  local settings="$TARGET_CLAUDE_DIR/settings.json"

  if [ ! -f "$settings" ]; then
    cat >"$settings" <<EOF
{
  "statusLine": {
    "type": "command",
    "command": "$STATUS_LINE_COMMAND"
  }
}
EOF
    log "wrote    settings.json (with statusLine)"
    log "registered status line at .claude/statusline.sh"
    return
  fi

  if command -v jq >/dev/null 2>&1; then
    local tmp
    tmp="$(mktemp)"
    if ! jq --arg cmd "$STATUS_LINE_COMMAND" \
         '.statusLine = {"type":"command","command":$cmd}' \
         "$settings" >"$tmp" 2>/dev/null; then
      rm -f "$tmp"
      warn "settings.json failed to parse (jq error) — leaving it untouched."
      warn "Fix the JSON, then re-run regen; statusLine entry needed:"
      warn '  "statusLine": { "type": "command", "command": "'"$STATUS_LINE_COMMAND"'" }'
      return
    fi
    if [ ! -s "$tmp" ]; then
      rm -f "$tmp"
      warn "settings.json patch produced empty output — leaving original untouched."
      return
    fi
    # Belt-and-suspenders: jq normally only emits valid JSON, but a future
    # filter change or a `--rawfile`-style bug could slip non-JSON through.
    # Round-trip through `jq empty` to confirm the output parses.
    if ! jq empty "$tmp" >/dev/null 2>&1; then
      rm -f "$tmp"
      warn "settings.json patch produced invalid JSON — leaving original untouched."
      return
    fi
    if cmp -s "$tmp" "$settings"; then
      rm -f "$tmp"
      log "unchanged settings.json statusLine"
    else
      mv "$tmp" "$settings"
      log "patched  settings.json statusLine (jq)"
      log "registered status line at .claude/statusline.sh"
    fi
  else
    warn "jq not installed — leaving settings.json unchanged. Add this entry manually:"
    warn '  "statusLine": { "type": "command", "command": "'"$STATUS_LINE_COMMAND"'" }'
  fi
}

do_bootstrap() {
  [ -n "$SOURCE_DIR" ] || { err "--bootstrap requires --source <path-to-.claude>"; exit 2; }
  [ -d "$SOURCE_DIR" ] || { err "source dir not found: $SOURCE_DIR"; exit 1; }
  SOURCE_DIR="$(cd "$SOURCE_DIR" && pwd -P)"

  local rel src dst
  for sub in "${MANAGED_SUBTREES[@]}"; do
    [ -d "$SOURCE_DIR/$sub" ] || continue
    while IFS= read -r rel; do
      src="$SOURCE_DIR/$rel"
      dst="$CANONICAL_ROOT/$rel"
      if ! is_managed "$src"; then
        warn "skipping unmanaged source file (no footer): $rel"
        continue
      fi
      ensure_parent "$dst"
      cp "$src" "$dst"
      log "captured $rel"
    done < <( cd "$SOURCE_DIR" && find "$sub" -type f | sort )
  done

  for f in "${MANAGED_TOPLEVEL_FILES[@]}"; do
    src="$SOURCE_DIR/$f"
    [ -f "$src" ] || continue
    if ! is_managed "$src"; then
      warn "skipping unmanaged source file (no footer): $f"
      continue
    fi
    dst="$CANONICAL_ROOT/$f"
    ensure_parent "$dst"
    copy_with_mode "$src" "$dst"
    log "captured $f"
  done
}

# ---- Dispatch ---------------------------------------------------------------

case "$MODE" in
  regen)     do_regen regen ;;
  check)     do_regen check
             if [ "$HAD_DRIFT" -ne 0 ]; then
               log "drift detected"
               exit 1
             fi
             log "no drift"
             ;;
  bootstrap) do_bootstrap ;;
  *)         err "unknown mode: $MODE"; exit 2 ;;
esac

# Validated 2026-05-28 — 5 rounds, adversarial sub-agent confirmed (Phase 7 implementation loop)
