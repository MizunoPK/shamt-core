#!/usr/bin/env bash
# init-shamt.sh — First-time install of Shamt into a target project.
#
# Usage:
#   bash /path/to/shamt-core/init-shamt.sh [--target <dir>]
#
# Invoked from inside the target project (or with --target pointing at it).
# The script lives in shamt-core/, so its own directory is the canonical source
# root — no clone-to-temp-dir is needed.
#
# Behavior:
#   1. Resolve target directory (default: cwd).
#   2. Detect self-host: when <target>/shamt-core/init-shamt.sh resolves (by
#      realpath) to the script being invoked, the target is the master repo
#      itself. In self-host the framework-source copy step is skipped.
#   3. Halt if the install config already exists (root shamt-config.json on
#      self-host, <target>/.shamt-core/shamt-config.json otherwise) — use
#      import-shamt.sh to pull updates on an already-installed project.
#   4. Prompt interactively for every shamt-config.json field. No flag-based
#      unattended mode (deferred until a real need surfaces).
#   5. Copy canonical sources into <target>/.shamt-core/ (skipped on self-host).
#      The set matches what import-shamt.sh syncs going forward, plus
#      init-shamt.sh / import-shamt.sh themselves so re-invocation works.
#      CHEATSHEET.md and proposals/_template.md travel inside this set — they
#      are NOT separately seeded at the project root.
#   6. Seed the child's CLAUDE.md (from templates/SHAMT_RULES.template.md) at
#      <target>/, and the two project-specific docs (ARCHITECTURE.md,
#      CODING_STANDARDS.md, Last Updated = today) under
#      <target>/.shamt-core/project-specific-files/. Skipped on self-host.
#   7. Write shamt-config.json (root on self-host, <target>/.shamt-core/
#      otherwise) from the prompted answers.
#   8. Run scripts/regenerate-framework.sh --target <target> to produce
#      <target>/.claude/.
#
# Exit status: 0 on success, non-zero on any failure.
#
# Per Phase 9: no remote-hosted curl-bash; invoked
# locally with master cloned in advance.

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
# Re-absolutize SCRIPT_PATH so self-host detection compares apples to apples
# even when the script was invoked via a relative path (e.g.,
# `bash ./shamt-core/init-shamt.sh`).
SCRIPT_PATH="$SCRIPT_DIR/$(basename "$SCRIPT_PATH")"
SHAMT_CORE_SRC="$SCRIPT_DIR"

# ---- Argument parsing -------------------------------------------------------

TARGET_DIR=""

usage() {
  cat <<'USAGE'
init-shamt.sh — First-time install of Shamt into a target project.

Usage:
  bash /path/to/shamt-core/init-shamt.sh [--target <dir>]

Options:
  --target <dir>   Target project directory. Defaults to the current working
                   directory.
  -h, --help       Show this help.

Halts if the install config already exists (root shamt-config.json on
self-host, <target>/.shamt-core/shamt-config.json otherwise). Use the
installed .shamt-core/import-shamt.sh to pull framework updates afterwards.
USAGE
}

log()  { printf '%s\n' "$*"; }
warn() { printf 'WARN: %s\n' "$*" >&2; }
err()  { printf 'ERROR: %s\n' "$*" >&2; }

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
  TARGET_DIR="$(pwd)"
fi
[ -d "$TARGET_DIR" ] || { err "target directory does not exist: $TARGET_DIR"; exit 1; }
TARGET_DIR="$(cd "$TARGET_DIR" && pwd -P)"

# ---- Pre-install checks -----------------------------------------------------
# The "already installed" config precheck runs AFTER self-host detection below:
# the config path is self-host-dependent (root for self-host, .shamt-core/
# otherwise), so it cannot be tested until SELF_HOST is known.

# ---- Self-host detection ----------------------------------------------------

SELF_HOST=0
candidate_self_host="$TARGET_DIR/shamt-core/init-shamt.sh"
if [ -f "$candidate_self_host" ]; then
  # Match by realpath identity. Both sides may have been reached via symlinks;
  # we want true filesystem identity, not path equality.
  cand_real="$(cd "$(dirname "$candidate_self_host")" 2>/dev/null && pwd -P)/$(basename "$candidate_self_host")"
  if [ "$cand_real" = "$SCRIPT_PATH" ]; then
    SELF_HOST=1
  fi
fi

if [ "$SELF_HOST" -eq 1 ]; then
  log "Self-host detected: target is the master repo itself."
  log "  shamt-core/ already present — skipping framework-source copy."
fi

# ---- Already-installed guard (config path is self-host-dependent) -----------

if [ "$SELF_HOST" -eq 1 ]; then
  precheck_config="$TARGET_DIR/shamt-config.json"
  precheck_import="$TARGET_DIR/shamt-core/import-shamt.sh"
else
  precheck_config="$TARGET_DIR/.shamt-core/shamt-config.json"
  precheck_import="$TARGET_DIR/.shamt-core/import-shamt.sh"
fi
if [ -f "$precheck_config" ]; then
  err "Shamt is already installed at: $TARGET_DIR/"
  err "  $precheck_config exists — refusing to overwrite."
  err "To pull updates, run:"
  err "  bash $precheck_import"
  exit 1
fi

# ---- Interactive prompts ----------------------------------------------------

prompt_value() {
  # prompt_value <var-name> <prompt-text> <default> [validator-pattern]
  local __var="$1" __prompt="$2" __default="${3:-}" __pattern="${4:-}"
  local __answer
  while :; do
    if [ -n "$__default" ]; then
      printf '%s [%s]: ' "$__prompt" "$__default" >&2
    else
      printf '%s: ' "$__prompt" >&2
    fi
    if ! IFS= read -r __answer; then
      err "input stream closed before prompt was answered: $__prompt"
      exit 1
    fi
    if [ -z "$__answer" ]; then
      __answer="$__default"
    fi
    if [ -z "$__answer" ]; then
      printf '  (value is required)\n' >&2
      continue
    fi
    if [ -n "$__pattern" ] && ! [[ "$__answer" =~ $__pattern ]]; then
      printf '  (invalid — must match: %s)\n' "$__pattern" >&2
      continue
    fi
    printf -v "$__var" '%s' "$__answer"
    break
  done
}

prompt_choice() {
  # prompt_choice <var-name> <prompt-text> <default> <choice1> [choice2] ...
  local __var="$1" __prompt="$2" __default="$3"
  shift 3
  local __choices=("$@") __joined __answer __ok
  __joined="$(IFS='/'; echo "${__choices[*]}")"
  while :; do
    printf '%s (%s) [%s]: ' "$__prompt" "$__joined" "$__default" >&2
    if ! IFS= read -r __answer; then
      err "input stream closed before prompt was answered: $__prompt"
      exit 1
    fi
    if [ -z "$__answer" ]; then
      __answer="$__default"
    fi
    __ok=0
    for c in "${__choices[@]}"; do
      [ "$c" = "$__answer" ] && { __ok=1; break; }
    done
    if [ "$__ok" -eq 1 ]; then
      printf -v "$__var" '%s' "$__answer"
      break
    fi
    printf '  (invalid — must be one of: %s)\n' "$__joined" >&2
  done
}

log ""
log "Initializing Shamt at: $TARGET_DIR"
log ""

PROJECT_NAME=""
WORK_ITEM_TRACKER=""
PR_PROVIDER=""
TESTING=""
AI_SERVICE="anthropic"
MASTER_URL=""
DOC_STALENESS=""

prompt_value PROJECT_NAME \
  "Project name (used by /sync-submit-proposal to namespace upstream submissions)" \
  "$(basename "$TARGET_DIR")" \
  '^[A-Za-z0-9._-]+$'

prompt_choice WORK_ITEM_TRACKER \
  "Work-item tracker (where /e1-start-story fetches tickets from)" \
  "github" \
  "ado" "github" "local" "none"

prompt_choice PR_PROVIDER \
  "PR provider (where /e6-review-changes formal mode posts review)" \
  "github" \
  "ado" "github" "none"

prompt_choice TESTING \
  "Automated testing infrastructure present in this project?" \
  "disabled" \
  "enabled" "disabled"

# master_url default: the path we were invoked from (works for both local-clone
# and self-host cases). User can override with a git URL after init.
default_master_url="$SHAMT_CORE_SRC"
prompt_value MASTER_URL \
  "Master canonical-source location (git URL like https://… / git@… / ssh://… or an absolute local path)" \
  "$default_master_url"

prompt_value DOC_STALENESS \
  "ARCHITECTURE.md / CODING_STANDARDS.md staleness threshold (days, integer)" \
  "60" \
  '^[0-9]+$'

# ---- Helpers ----------------------------------------------------------------

# Set of paths under SHAMT_CORE_SRC that init copies into <target>/shamt-core/.
# Matches the import-shamt.sh sync set so the two stay coherent.
SHAMT_CORE_INSTALL_PATHS=(
  "CLAUDE.md"
  "CHEATSHEET.md"
  "shamt-config.example.json"
  "init-shamt.sh"
  "import-shamt.sh"
  "scripts"
  "templates"
  "reference"
  "host"
  "proposals/_template.md"
)

ensure_parent() {
  local path="$1" parent
  parent="$(dirname "$path")"
  [ -d "$parent" ] || mkdir -p "$parent"
}

copy_tree() {
  # copy_tree <src> <dst>
  # Plain recursive copy preserving executable bit. Refuses to descend into
  # .git directories (defensive — shamt-core/ is a subfolder of the v2-dev
  # repo today; once extracted it will have its own .git that we never want
  # to copy into a child). The exclusion pattern is precise — `*/.git` and
  # `*/.git/*` only, NOT `*/.git*` which would also drop `.github/`,
  # `.gitignore`, `.gitattributes`, etc. that legitimate canonical content
  # may add later.
  local src="$1" dst="$2"
  ensure_parent "$dst"
  if [ -d "$src" ]; then
    ( cd "$src" && find . -type d -not -path '*/.git' -not -path '*/.git/*' -print0 ) \
      | while IFS= read -r -d '' d; do
          mkdir -p "$dst/$d"
        done
    ( cd "$src" && find . -type f -not -path '*/.git/*' -print0 ) \
      | while IFS= read -r -d '' f; do
          cp "$src/$f" "$dst/$f"
          case "$f" in
            *.sh) chmod +x "$dst/$f" ;;
          esac
        done
  else
    cp "$src" "$dst"
    case "$src" in
      *.sh) chmod +x "$dst" ;;
    esac
  fi
}

seed_doc_with_today() {
  # seed_doc_with_today <template-path> <target-path>
  # Copy a template, replacing the first two YYYY-MM-DD occurrences with today.
  # The architecture / coding_standards templates put YYYY-MM-DD in the Last
  # Updated header and in the first Update History entry; both should be today.
  local src="$1" dst="$2" today
  today="$(date -u +%Y-%m-%d)"
  awk -v today="$today" '
    BEGIN { replaced = 0 }
    {
      while (replaced < 2 && match($0, /YYYY-MM-DD/)) {
        $0 = substr($0, 1, RSTART - 1) today substr($0, RSTART + RLENGTH)
        replaced++
      }
      print
    }
  ' "$src" > "$dst"
}

# ---- Step: copy canonical sources to <target>/shamt-core/ -------------------

if [ "$SELF_HOST" -eq 0 ]; then
  log ""
  log "Copying canonical sources to $TARGET_DIR/.shamt-core/ …"
  dest_root="$TARGET_DIR/.shamt-core"
  mkdir -p "$dest_root"
  for rel in "${SHAMT_CORE_INSTALL_PATHS[@]}"; do
    src="$SHAMT_CORE_SRC/$rel"
    if [ ! -e "$src" ]; then
      warn "expected source missing — skipping: $rel"
      continue
    fi
    copy_tree "$src" "$dest_root/$rel"
    log "  copied  $rel"
  done
fi

# ---- Step: seed top-level docs ----------------------------------------------

# In self-host the target IS the master repo; its top-level CLAUDE.md is the
# v2-dev primer (not a child rendering of SHAMT_RULES). Don't touch it.
if [ "$SELF_HOST" -eq 0 ]; then
  log ""
  log "Seeding top-level docs …"

  rules_src="$SHAMT_CORE_SRC/templates/SHAMT_RULES.template.md"
  if [ -f "$TARGET_DIR/CLAUDE.md" ]; then
    warn "CLAUDE.md already exists — preserving. Merge SHAMT_RULES content by hand if needed."
  elif [ -f "$rules_src" ]; then
    cp "$rules_src" "$TARGET_DIR/CLAUDE.md"
    log "  seeded  CLAUDE.md (from SHAMT_RULES.template.md)"
  else
    warn "SHAMT_RULES.template.md not found at $rules_src — CLAUDE.md not seeded."
  fi

fi

# Project-specific docs live under .shamt-core/project-specific-files/ on a
# child install. Skipped entirely on self-host: the master repo keeps its own
# top-level docs and never grows a .shamt-core/ tree.
#
# proposals/_template.md is NOT seeded here — it is part of SHAMT_CORE_INSTALL_PATHS
# and is copied to .shamt-core/proposals/_template.md by the canonical-source copy
# step above; /f1-propose-update reads it from there.
if [ "$SELF_HOST" -eq 0 ]; then
  psf_dir="$TARGET_DIR/.shamt-core/project-specific-files"
  mkdir -p "$psf_dir"

  arch_src="$SHAMT_CORE_SRC/templates/architecture.template.md"
  if [ -f "$psf_dir/ARCHITECTURE.md" ]; then
    warn "ARCHITECTURE.md already exists — preserving."
  elif [ -f "$arch_src" ]; then
    seed_doc_with_today "$arch_src" "$psf_dir/ARCHITECTURE.md"
    log "  seeded  .shamt-core/project-specific-files/ARCHITECTURE.md (Last Updated set to today)"
  else
    warn "architecture.template.md not found — ARCHITECTURE.md not seeded."
  fi

  cs_src="$SHAMT_CORE_SRC/templates/coding_standards.template.md"
  if [ -f "$psf_dir/CODING_STANDARDS.md" ]; then
    warn "CODING_STANDARDS.md already exists — preserving."
  elif [ -f "$cs_src" ]; then
    seed_doc_with_today "$cs_src" "$psf_dir/CODING_STANDARDS.md"
    log "  seeded  .shamt-core/project-specific-files/CODING_STANDARDS.md (Last Updated set to today)"
  else
    warn "coding_standards.template.md not found — CODING_STANDARDS.md not seeded."
  fi
fi

# ---- Step: write shamt-config.json ------------------------------------------

# Escape a string for safe inclusion inside a JSON double-quoted value:
# backslash → \\, double-quote → \". MASTER_URL is the only field that
# isn't already constrained by a regex / choice list, but the helper is
# applied uniformly so a future loosened validator can't silently produce
# malformed JSON.
json_escape() {
  local s="$1"
  s="${s//\\/\\\\}"   # backslash first
  s="${s//\"/\\\"}"   # then double-quote
  printf '%s' "$s"
}

JSON_PROJECT_NAME="$(json_escape "$PROJECT_NAME")"
JSON_WORK_ITEM_TRACKER="$(json_escape "$WORK_ITEM_TRACKER")"
JSON_PR_PROVIDER="$(json_escape "$PR_PROVIDER")"
JSON_TESTING="$(json_escape "$TESTING")"
JSON_AI_SERVICE="$(json_escape "$AI_SERVICE")"
JSON_MASTER_URL="$(json_escape "$MASTER_URL")"

# Self-host keeps its config at the repo root; a child install puts it under
# .shamt-core/ (the dest_root created by the canonical-source copy step).
if [ "$SELF_HOST" -eq 1 ]; then
  config_dest="$TARGET_DIR/shamt-config.json"
else
  config_dest="$TARGET_DIR/.shamt-core/shamt-config.json"
fi
mkdir -p "$(dirname "$config_dest")"
cat > "$config_dest" <<EOF
{
  "project_name": "$JSON_PROJECT_NAME",
  "work_item_tracker": "$JSON_WORK_ITEM_TRACKER",
  "pr_provider": "$JSON_PR_PROVIDER",
  "testing": "$JSON_TESTING",
  "ai_service": "$JSON_AI_SERVICE",
  "master_url": "$JSON_MASTER_URL",
  "doc_staleness_threshold_days": $DOC_STALENESS
}
EOF
log ""
log "Wrote $config_dest"

# ---- Step: run regen --------------------------------------------------------

regen_script=""
if [ "$SELF_HOST" -eq 1 ]; then
  regen_script="$TARGET_DIR/shamt-core/scripts/regenerate-framework.sh"
else
  regen_script="$TARGET_DIR/.shamt-core/scripts/regenerate-framework.sh"
fi

if [ ! -x "$regen_script" ]; then
  # Could happen if cp dropped the executable bit on a noexec filesystem; retry.
  if [ -f "$regen_script" ]; then
    chmod +x "$regen_script" 2>/dev/null || true
  fi
fi

if [ -x "$regen_script" ]; then
  log ""
  log "Running regen → $TARGET_DIR/.claude/ …"
  bash "$regen_script" --target "$TARGET_DIR"
else
  warn "regenerate-framework.sh not found or not executable at $regen_script"
  warn "  Run it manually after init: bash $regen_script --target $TARGET_DIR"
fi

# ---- Summary ----------------------------------------------------------------

log ""
log "Shamt initialization complete."
log "  Target:        $TARGET_DIR"
log "  Project name:  $PROJECT_NAME"
log "  Tracker:       $WORK_ITEM_TRACKER"
log "  PR provider:   $PR_PROVIDER"
log "  Testing:       $TESTING"
log "  master_url:    $MASTER_URL"
log ""
if [ "$SELF_HOST" -eq 1 ]; then
  import_hint="$TARGET_DIR/shamt-core/import-shamt.sh"
else
  import_hint="$TARGET_DIR/.shamt-core/import-shamt.sh"
fi
log "Next steps:"
log "  - Author a first story via: /e1-start-story {slug}"
log "  - To pull master updates later: bash $import_hint"
log ""
if [ "$SELF_HOST" -eq 0 ]; then
  log "To finish setup, paste the following prompt into a fresh Claude Code"
  log "session at the project root — it fills in the two project-specific docs"
  log "and validates each:"
  log ""
  cat <<'PROMPT'
────────────────────────────────────────────────────────────────────────
Research this codebase and complete the two Shamt project-specific
documents, then validate each.

1. Read .shamt-core/project-specific-files/ARCHITECTURE.md and
   .shamt-core/project-specific-files/CODING_STANDARDS.md — both are
   templates full of placeholders.
2. Explore the repository (entry points, services, data stores, build and
   test tooling, naming and structure conventions) and replace every
   placeholder with content true to THIS project. Keep an explicit "Open
   Questions" list as you draft; ask me each question one at a time and
   fold the answer in before continuing (Shamt Principle 2).
3. When ARCHITECTURE.md is complete, run:
     /validate-artifact .shamt-core/project-specific-files/ARCHITECTURE.md
   When CODING_STANDARDS.md is complete, run:
     /validate-artifact .shamt-core/project-specific-files/CODING_STANDARDS.md
   Resolve every finding until each document carries a validation footer.
────────────────────────────────────────────────────────────────────────
PROMPT
  log ""
fi

# Validated 2026-05-28 — 8 rounds (4 primary + 4 adversarial), final adversarial sub-agent confirmed (Phase 9 implementation re-validation). Fixes since prior round: json_escape helper added for all string fields; copy_tree `find` patterns tightened to `*/.git` and `*/.git/*` (no longer overmatches `.github/`, `.gitignore`, etc.).
# Managed by Shamt — do not edit. Regenerate from shamt-core/init-shamt.sh.
