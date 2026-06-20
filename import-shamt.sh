#!/usr/bin/env bash
# import-shamt.sh — Pull framework updates from master into a child project.
#
# Usage:
#   bash <child>/.shamt-core/import-shamt.sh [--target <dir>]
#
# Reads <target>/shamt-config.json:master_url. If it looks like a git URL
# (https://, http://, git@, ssh://, git://), the script clones master --depth 1
# to a temp dir. Otherwise master_url is treated as an absolute local path and
# used directly with no copy.
#
# Sync rule (Phase 9): every path in the explicit MASTER_SYNC_PATHS set is
# master-owned. Master wins on every diff. Anything under <child>/.shamt-core/
# that is NOT in the sync set is preserved with a warning.
#
# This is a pragmatic interpretation of an earlier proposed per-file
# "Managed by Shamt" footer contract: most canonical files under
# shamt-core/ do not currently carry that footer, so a strict reading would
# leave the bulk of canonical content un-synced. The subtree-level
# interpretation — "anything in the sync set is master-owned" — gives child
# projects working updates today and can be tightened by a follow-up proposal
# that backfills footers across templates/ and reference/.
#
# Already-merged proposals: walk both <child>/.shamt-core/proposals/{slug}.md
# (locally-authored, not yet submitted) and
# <child>/.shamt-core/proposals/submitted/{slug}.md (submitted via
# /sync-proposals, awaiting master's decision). If a master archive entry
# <master>/proposals/archive/{slug}.md matches the basename, the proposal landed
# upstream and came back via this sync; move the local copy to
# <child>/.shamt-core/proposals/already-merged/{slug}.md per §4.7 / §4.9.
#
# After the file sync, the script runs <child>/.shamt-core/scripts/
# regenerate-framework.sh --target <child> so <child>/.claude/ stays current.
#
# Self-updating: import-shamt.sh is itself in the sync set, so a new version
# overwrites the on-disk copy. The running script is already in memory and
# continues with the previous logic; the new version takes effect on the next
# invocation.

set -euo pipefail

# ---- Resolve script's true location (handle symlinks) ----------------------

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
  if ! resolved_dir="$(cd "$target_dir" 2>/dev/null && pwd -P)"; then
    printf 'ERROR: cannot resolve symlink target directory: %s\n' "$target_dir" >&2
    exit 1
  fi
  SCRIPT_PATH="$resolved_dir/$target_name"
done
SCRIPT_DIR="$(cd "$(dirname "$SCRIPT_PATH")" && pwd -P)"
# Re-absolutize SCRIPT_PATH so identity comparisons survive relative invocation.
SCRIPT_PATH="$SCRIPT_DIR/$(basename "$SCRIPT_PATH")"

log()  { printf '%s\n' "$*"; }
warn() { printf 'WARN: %s\n' "$*" >&2; }
err()  { printf 'ERROR: %s\n' "$*" >&2; }

usage() {
  cat <<'USAGE'
import-shamt.sh — Pull framework updates from master into a child project.

Usage:
  bash <child>/.shamt-core/import-shamt.sh [--target <dir>]

Options:
  --target <dir>   Target project directory. Defaults to the parent of the
                   directory containing this script (i.e., <child> when the
                   script lives at <child>/.shamt-core/import-shamt.sh).
  -h, --help       Show this help.

Reads master_url from <target>/shamt-config.json. master_url may be a git URL
(cloned with --depth 1) or an absolute local path.
USAGE
}

TARGET_DIR=""

while [ "$#" -gt 0 ]; do
  case "$1" in
    --target)
      TARGET_DIR="${2:-}"
      [ -n "$TARGET_DIR" ] || { err "--target requires an argument"; exit 2; }
      shift 2
      ;;
    --target=*)
      TARGET_DIR="${1#--target=}"
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

if [ -z "$TARGET_DIR" ]; then
  # Default: parent of the directory containing this script — i.e., when
  # invoked as <child>/.shamt-core/import-shamt.sh, the target is <child>.
  TARGET_DIR="$(cd "$SCRIPT_DIR/.." && pwd -P)"
fi
[ -d "$TARGET_DIR" ] || { err "target directory does not exist: $TARGET_DIR"; exit 1; }
TARGET_DIR="$(cd "$TARGET_DIR" && pwd -P)"

CHILD_SHAMT_CORE="$TARGET_DIR/.shamt-core"
[ -d "$CHILD_SHAMT_CORE" ] || { err "target has no .shamt-core/ — run init-shamt.sh first"; exit 1; }

CONFIG_PATH="$TARGET_DIR/.shamt-core/shamt-config.json"
[ -f "$CONFIG_PATH" ] || { err "shamt-config.json not found at $CONFIG_PATH — run init-shamt.sh first"; exit 1; }

# ---- Read master_url from shamt-config.json ---------------------------------

read_master_url() {
  # Prefer jq when available; fall back to a tolerant grep/sed pair for the
  # simple flat-JSON shape shamt-config.json uses.
  if command -v jq >/dev/null 2>&1; then
    jq -r '.master_url // empty' "$CONFIG_PATH"
    return
  fi
  # Match: "master_url": "value" — handles quoted strings without escapes.
  # If the value contains a literal " (unlikely for URLs/paths), use jq.
  sed -n 's/.*"master_url"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' "$CONFIG_PATH" | head -n 1
}

MASTER_URL="$(read_master_url)"
if [ -z "$MASTER_URL" ]; then
  err "master_url is empty in $CONFIG_PATH"
  err "  Edit shamt-config.json and set master_url to the canonical source location"
  err "  (a git URL like https://… / git@… / ssh://… or an absolute local path)."
  exit 1
fi

log "Importing framework updates from: $MASTER_URL"
log "  Target: $TARGET_DIR"

# ---- Obtain master source root ---------------------------------------------

TMPDIR_TO_CLEAN=""
cleanup() {
  if [ -n "$TMPDIR_TO_CLEAN" ] && [ -d "$TMPDIR_TO_CLEAN" ]; then
    rm -rf "$TMPDIR_TO_CLEAN"
  fi
}
trap cleanup EXIT

is_git_url() {
  case "$1" in
    https://*|http://*|git://*|ssh://*|git@*) return 0 ;;
    *) return 1 ;;
  esac
}

if is_git_url "$MASTER_URL"; then
  command -v git >/dev/null 2>&1 || { err "git not installed but master_url is a git URL"; exit 1; }
  TMPDIR_TO_CLEAN="$(mktemp -d -t shamt-import.XXXXXX)"
  log "Cloning master to $TMPDIR_TO_CLEAN …"
  if ! git clone --depth 1 --quiet "$MASTER_URL" "$TMPDIR_TO_CLEAN"; then
    err "git clone failed for: $MASTER_URL"
    exit 1
  fi
  MASTER_CLONE_ROOT="$TMPDIR_TO_CLEAN"
else
  [ -d "$MASTER_URL" ] || { err "master_url points at a non-existent directory: $MASTER_URL"; exit 1; }
  MASTER_CLONE_ROOT="$(cd "$MASTER_URL" && pwd -P)"
  log "Using local master at $MASTER_CLONE_ROOT (no clone)."
fi

# Resolve the shamt-core/ root within the cloned/local master. Two layouts:
#   1. Extracted shamt-core repo: MASTER_CLONE_ROOT/init-shamt.sh exists.
#   2. v2-dev container: MASTER_CLONE_ROOT/shamt-core/init-shamt.sh exists.
if [ -f "$MASTER_CLONE_ROOT/init-shamt.sh" ]; then
  MASTER_SHAMT_CORE="$MASTER_CLONE_ROOT"
elif [ -f "$MASTER_CLONE_ROOT/shamt-core/init-shamt.sh" ]; then
  MASTER_SHAMT_CORE="$MASTER_CLONE_ROOT/shamt-core"
else
  err "could not find init-shamt.sh in master at: $MASTER_CLONE_ROOT"
  err "  Expected either <master>/init-shamt.sh or <master>/shamt-core/init-shamt.sh"
  exit 1
fi

log "Master shamt-core root: $MASTER_SHAMT_CORE"

# ---- Sync set ---------------------------------------------------------------

# Top-level files under shamt-core/ that are individually owned.
MASTER_SYNC_FILES=(
  "CLAUDE.md"
  "README.md"
  "shamt-config.example.json"
  "init-shamt.sh"
  "import-shamt.sh"
  "proposals/_template.md"
)

# Subtrees under shamt-core/ where every file is master-owned.
MASTER_SYNC_DIRS=(
  "scripts"
  "templates"
  "reference"
  "host"
)

NEW_COUNT=0
UPDATED_COUNT=0
UNCHANGED_COUNT=0
PRESERVED_COUNT=0
PROMOTED_PROPOSAL_COUNT=0

apply_one() {
  # apply_one <relative-path-under-shamt-core>
  local rel="$1"
  local src="$MASTER_SHAMT_CORE/$rel"
  local dst="$CHILD_SHAMT_CORE/$rel"

  if [ ! -e "$src" ]; then
    return 0
  fi

  if [ -d "$src" ]; then
    return 0
  fi

  if [ -e "$dst" ] && cmp -s "$src" "$dst" 2>/dev/null; then
    UNCHANGED_COUNT=$((UNCHANGED_COUNT + 1))
    return 0
  fi

  local existed=0
  [ -e "$dst" ] && existed=1

  local parent
  parent="$(dirname "$dst")"
  [ -d "$parent" ] || mkdir -p "$parent"
  cp "$src" "$dst"
  case "$src" in
    *.sh) chmod +x "$dst" ;;
  esac

  if [ "$existed" -eq 1 ]; then
    log "  updated  $rel"
    UPDATED_COUNT=$((UPDATED_COUNT + 1))
  else
    log "  new      $rel"
    NEW_COUNT=$((NEW_COUNT + 1))
  fi
}

log ""
log "Syncing canonical sources …"

for rel in "${MASTER_SYNC_FILES[@]}"; do
  apply_one "$rel"
done

# Walk each managed subtree from master and apply every file.
for sub in "${MASTER_SYNC_DIRS[@]}"; do
  [ -d "$MASTER_SHAMT_CORE/$sub" ] || continue
  while IFS= read -r -d '' f; do
    rel="${f#./}"
    apply_one "$sub/$rel"
  done < <( cd "$MASTER_SHAMT_CORE/$sub" && find . -type f -print0 )
done

# Pass 2: warn about child-local files inside the managed subtrees that are
# NOT in master's sync set (and aren't covered by an in-progress file). These
# are user-authored additions; we preserve them.
for sub in "${MASTER_SYNC_DIRS[@]}"; do
  [ -d "$CHILD_SHAMT_CORE/$sub" ] || continue
  while IFS= read -r -d '' f; do
    rel="${f#./}"
    local_path="$CHILD_SHAMT_CORE/$sub/$rel"
    master_path="$MASTER_SHAMT_CORE/$sub/$rel"
    if [ ! -e "$master_path" ]; then
      warn "preserving local file not in master sync set: .shamt-core/$sub/$rel"
      PRESERVED_COUNT=$((PRESERVED_COUNT + 1))
    fi
  done < <( cd "$CHILD_SHAMT_CORE/$sub" && find . -type f -print0 )
done

# (Removed: the root-level proposals/_template.md mirror. Proposals now live
# under .shamt-core/proposals/, and proposals/_template.md is part of
# MASTER_SYNC_FILES — apply_one already syncs it to
# $CHILD_SHAMT_CORE/proposals/_template.md = .shamt-core/proposals/_template.md.
# /f1-propose-update reads it from there.)

# ---- Already-merged proposals: auto-move ------------------------------------

CHILD_PROPOSALS="$TARGET_DIR/.shamt-core/proposals"
MASTER_ARCHIVE="$MASTER_SHAMT_CORE/proposals/archive"

if [ -d "$CHILD_PROPOSALS" ] && [ -d "$MASTER_ARCHIVE" ]; then
  log ""
  log "Checking for already-merged proposals …"
  # Scan both proposals/ (locally-authored, not yet submitted) and
  # proposals/submitted/ (submitted, awaiting decision). Per §4.9, either is a
  # valid source for the auto-move — a proposal that landed in master's archive
  # may match a local draft OR a submitted copy.
  for scan_rel in "" "submitted"; do
    scan_dir="$CHILD_PROPOSALS${scan_rel:+/$scan_rel}"
    [ -d "$scan_dir" ] || continue
    while IFS= read -r -d '' local_proposal; do
      base="$(basename "$local_proposal")"
      # Skip the template file and dot-files.
      case "$base" in
        _template.md|.*) continue ;;
      esac
      # Master archive filenames carry a {NN}- numeric prefix (master-side
      # numbering; see shamt-core/CLAUDE.md §Conventions) while child-local
      # proposals stay unnumbered {slug}.md. Match the child basename against
      # both the exact name (grandfathered/unnumbered archives) and the
      # numbered-prefix glob {NN}-{slug}.md.
      matched_archive=""
      if [ -f "$MASTER_ARCHIVE/$base" ]; then
        matched_archive="$MASTER_ARCHIVE/$base"
      else
        for cand in "$MASTER_ARCHIVE"/[0-9]*-"$base"; do
          [ -e "$cand" ] || continue
          matched_archive="$cand"
          break
        done
      fi
      if [ -n "$matched_archive" ]; then
        dest_dir="$CHILD_PROPOSALS/already-merged"
        mkdir -p "$dest_dir"
        mv "$local_proposal" "$dest_dir/$base"
        src_label=".shamt-core/proposals${scan_rel:+/$scan_rel}/$base"
        log "  moved    $src_label → .shamt-core/proposals/already-merged/$base (matched master archive)"
        PROMOTED_PROPOSAL_COUNT=$((PROMOTED_PROPOSAL_COUNT + 1))
      fi
    done < <( find "$scan_dir" -maxdepth 1 -type f -name '*.md' -print0 )
  done
fi

# ---- Run regen --------------------------------------------------------------

regen_script="$CHILD_SHAMT_CORE/scripts/regenerate-framework.sh"
if [ -f "$regen_script" ]; then
  chmod +x "$regen_script" 2>/dev/null || true
  log ""
  log "Running regen → $TARGET_DIR/.claude/ …"
  bash "$regen_script" --target "$TARGET_DIR"
else
  warn "regenerate-framework.sh not found at $regen_script — .claude/ NOT regenerated."
fi

# ---- Re-seed the standing Tech Stories epic (idempotent) --------------------
# Existing children that predate the Tech Stories epic get it on next import.
# Create-if-absent — never overwrite an existing epic.md / feature.md (preserves
# any in-progress tickets the child has filed under it). The child work tree is
# rooted under the Shamt work root (.shamt-core/); it sits outside MASTER_SYNC_DIRS,
# so the sync passes above never clobber or warn on it.
ts="$TARGET_DIR/.shamt-core/epics/tech-stories"
if [ ! -f "$ts/epic.md" ]; then
  mkdir -p "$ts" && cat > "$ts/epic.md" <<'EOF'
# Epic: Tech Stories

**Status:** Standing

The permanent home for one-off work that does not belong to any real initiative —
bug fixes and small standalone improvements. File work under it with
`/ps0-draft [bugs|quick-wins]`. A local-only organizational container.
EOF
  log "Seeded standing Tech Stories epic (was absent)."
fi
for _f in bugs quick-wins; do
  _fd="$ts/features/$_f"
  if [ ! -f "$_fd/feature.md" ]; then
    mkdir -p "$_fd" && cat > "$_fd/feature.md" <<EOF
# Feature: ${_f}

**Status:** Standing

Standing Tech Stories feature. Tickets are filed via \`/ps0-draft $_f\`
and archived into \`archive/\` on finalize.
EOF
  fi
done

# ---- Summary ----------------------------------------------------------------

log ""
log "import-shamt complete:"
log "  new:        $NEW_COUNT"
log "  updated:    $UPDATED_COUNT"
log "  unchanged:  $UNCHANGED_COUNT"
log "  preserved:  $PRESERVED_COUNT  (local files outside master sync set)"
log "  proposals → already-merged: $PROMOTED_PROPOSAL_COUNT"
log ""
log "Review changes with: git -C $TARGET_DIR status"

# Validated 2026-05-28 — 8 rounds (4 primary + 4 adversarial), final adversarial sub-agent confirmed (Phase 9 implementation re-validation). No changes to this file in this round; sweep covered the master/child sync surface end-to-end.
# Managed by Shamt — do not edit. Regenerate from shamt-core/import-shamt.sh.
