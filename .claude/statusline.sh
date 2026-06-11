#!/usr/bin/env bash
# statusline.sh — Shamt Claude Code status-line renderer.
#
# Output (priority order — first match wins):
#   1. Active story:
#        STORY {slug} | P{N} {phase-name} | feat: {feature-slug} | epic: {epic-slug}
#      The `| feat: …` / `| epic: …` segments are omitted when the active
#      story's ticket.md does not carry the corresponding back-ref headers.
#   2. Active feature (no active story):
#        FEATURE {feature-slug} | epic: {parent-epic-slug}
#      The `| epic: …` segment is omitted when the active feature is standalone
#      (no **Parent Epic:** header in feature.md).
#   3. Active epic (no active story, no active feature):
#        EPIC {epic-slug}
#   4. Idle:
#        Shamt | idle
#
# Active resolution for each altitude (story / feature / epic):
#   a. `{parent-dir}/.active` — explicit override (single line containing the
#      active folder name; lets the user pin status when mtime is misleading,
#      e.g. after a sweeping `git restore`).
#   b. Most recently modified `{parent-dir}/*/` directory — directory mtimes
#      update when files are added/removed inside, which matches how work
#      advances through phases in normal use.
#
# Cheap by design: only file reads and globs — no git, no network.
# Registered in .claude/settings.json under "statusLine".

# Intentionally no `set -e`: a status-line renderer must always exit 0 with
# *some* output. Critical reads use `|| true` for graceful degradation.

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"
cd "$PROJECT_DIR" 2>/dev/null || { printf 'Shamt | idle'; exit 0; }

idle() { printf 'Shamt | idle'; exit 0; }

# ---- Numbering scheme (testing enabled = 8 phases, disabled = 7 phases) -----
#
# Engineer flow expands when `testing: "enabled"`:
#   enabled : Intake(1) Spec(2) Plan(3) Build(4) Test(5)  Review(6) Polish(7) Finalize(8)
#   disabled: Intake(1) Spec(2) Plan(3) Build(4)          Review(5) Polish(6) Finalize(7)
#
# Default to the 7-phase scheme so projects without .shamt-core/shamt-config.json (or with
# testing absent / disabled) get the correct numbering shown by default.

TESTING_ENABLED=0
# Require the key to be preceded by a JSON object boundary (`{`, `,`, or
# whitespace including a newline). This handles both pretty-printed and compact
# JSON shapes while still rejecting incidental occurrences inside string values
# (JSON forbids unescaped quotes inside strings, so the boundary check is
# sufficient in practice).
if [ -f .shamt-core/shamt-config.json ] \
   && grep -qzE '[{,[:space:]]"testing"[[:space:]]*:[[:space:]]*"enabled"' .shamt-core/shamt-config.json 2>/dev/null; then
  TESTING_ENABLED=1
fi

# ---- Resolve the active folder under a given parent directory ---------------
#
# Shared resolution rule used for stories / features / epics. Two-step:
#   1. `{parent-dir}/.active` — explicit override (single line containing the
#      active folder name; lets the user pin status when mtime is misleading,
#      e.g. after a sweeping `git restore`).
#   2. Most recently modified `{parent-dir}/*/` directory — directory mtimes
#      update when files are added/removed inside, which matches how work
#      advances through phases in normal use.
#
# Prints the resolved path (or nothing) on stdout. Caller checks for empty.

resolve_active_dir() {
  local parent="$1"
  local active=""
  [ -d "$parent" ] || return 0
  if [ -f "$parent/.active" ]; then
    local pinned
    pinned="$(head -n 1 "$parent/.active" 2>/dev/null | tr -d '[:space:]')"
    # `archive` is the finalized-epic store (/p5-finalize-epic), never an active item.
    if [ -n "$pinned" ] && [ "$pinned" != "archive" ] && [ -d "$parent/$pinned" ]; then
      active="$parent/$pinned"
    fi
  fi
  if [ -z "$active" ]; then
    # Exclude the archive/ subdir (finalized epics) from most-recently-modified resolution.
    active="$(ls -1td "$parent"/*/ 2>/dev/null | grep -v '/archive/$' | head -1 | sed 's:/$::')"
  fi
  [ -n "$active" ] && [ -d "$active" ] && printf '%s' "$active"
}

# ---- Pick the active story --------------------------------------------------

ACTIVE_STORY_DIR="$(resolve_active_dir stories)"
SLUG=""
if [ -n "$ACTIVE_STORY_DIR" ]; then
  SLUG="${ACTIVE_STORY_DIR#stories/}"
fi

# ---- Story rendering --------------------------------------------------------
#
# When `ACTIVE_STORY_DIR` resolved, attempt to render the STORY line. If phase
# detection finds no artifact (an empty story folder, for example), the story
# branch falls through to the PO-flow fallback chain below.

if [ -n "$ACTIVE_STORY_DIR" ]; then
  ACTIVE_POINTER="$ACTIVE_STORY_DIR/active_artifacts.md"

  has_active_artifact() {
    # Return 0 if active_artifacts.md mentions a file matching the prefix.
    local prefix="$1"
    [ -f "$ACTIVE_POINTER" ] || return 1
    grep -qE "\`stories/[^/]+/${prefix}(_v[0-9]+)?\.md\`" "$ACTIVE_POINTER" 2>/dev/null
  }

  has_any_artifact() {
    # Return 0 if a versioned or unversioned artifact matching <prefix>.md exists.
    local prefix="$1"
    compgen -G "$ACTIVE_STORY_DIR/${prefix}.md" >/dev/null 2>&1 && return 0
    compgen -G "$ACTIVE_STORY_DIR/${prefix}_v*.md" >/dev/null 2>&1 && return 0
    if [ -f "$ACTIVE_POINTER" ] && has_active_artifact "$prefix"; then
      return 0
    fi
    return 1
  }

  PHASE_NUM=""
  PHASE_NAME=""

  if [ -f "$ACTIVE_STORY_DIR/ticket.md" ] && grep -qE '\*\*Status:.*Done' "$ACTIVE_STORY_DIR/ticket.md" 2>/dev/null; then
    # Finalize is terminal: /e8-finalize-story writes **Status: Done** into
    # ticket.md (profile-independent signal). Checked first — it outranks every
    # earlier-phase artifact a finalized story still carries on disk.
    PHASE_NAME=Finalize
    PHASE_NUM=$([ "$TESTING_ENABLED" -eq 1 ] && echo 8 || echo 7)
  elif [ -f "$ACTIVE_STORY_DIR/feedback/addressed_feedback.md" ]; then
    PHASE_NAME=Polish
    PHASE_NUM=$([ "$TESTING_ENABLED" -eq 1 ] && echo 7 || echo 6)
  elif compgen -G "$ACTIVE_STORY_DIR/feedback/review_v*.md" >/dev/null 2>&1; then
    PHASE_NAME=Review
    PHASE_NUM=$([ "$TESTING_ENABLED" -eq 1 ] && echo 6 || echo 5)
  elif [ "$TESTING_ENABLED" -eq 1 ] && has_any_artifact testing_plan; then
    # testing_plan only signals Test phase when testing is opted in. When
    # testing is disabled, no Test phase exists and any stray testing_plan.md
    # is treated as Plan-phase scaffolding.
    PHASE_NUM=5; PHASE_NAME=Test
  elif has_any_artifact implementation_plan; then
    PHASE_NUM=3; PHASE_NAME=Plan
  elif has_any_artifact spec; then
    PHASE_NUM=2; PHASE_NAME=Spec
  elif [ -f "$ACTIVE_STORY_DIR/ticket.md" ]; then
    PHASE_NUM=1; PHASE_NAME=Intake
  fi

  if [ -n "$PHASE_NAME" ]; then
    # Parent feature / epic from ticket.md (PO-flow back-refs).
    FEATURE_SLUG=""
    EPIC_SLUG=""
    if [ -f "$ACTIVE_STORY_DIR/ticket.md" ]; then
      FEATURE_SLUG="$(grep -m1 -oE '\*\*Parent Feature:\*\*[[:space:]]+[A-Za-z0-9._-]+' "$ACTIVE_STORY_DIR/ticket.md" 2>/dev/null \
        | sed -E 's/^\*\*Parent Feature:\*\*[[:space:]]+//' || true)"
      EPIC_SLUG="$(grep -m1 -oE '\*\*Parent Epic:\*\*[[:space:]]+[A-Za-z0-9._-]+' "$ACTIVE_STORY_DIR/ticket.md" 2>/dev/null \
        | sed -E 's/^\*\*Parent Epic:\*\*[[:space:]]+//' || true)"
    fi

    OUTPUT="STORY ${SLUG} | P${PHASE_NUM} ${PHASE_NAME}"
    [ -n "$FEATURE_SLUG" ] && OUTPUT="${OUTPUT} | feat: ${FEATURE_SLUG}"
    [ -n "$EPIC_SLUG" ]    && OUTPUT="${OUTPUT} | epic: ${EPIC_SLUG}"
    printf '%s' "$OUTPUT"
    exit 0
  fi
fi

# ---- PO-flow fallback: feature, then epic, then idle ------------------------

ACTIVE_FEATURE_DIR="$(resolve_active_dir features)"
if [ -n "$ACTIVE_FEATURE_DIR" ]; then
  FEATURE_SLUG="${ACTIVE_FEATURE_DIR#features/}"
  PARENT_EPIC_SLUG=""
  if [ -f "$ACTIVE_FEATURE_DIR/feature.md" ]; then
    # Same grep+sed pattern as the story-side back-ref reader above, kept
    # in sync deliberately.
    PARENT_EPIC_SLUG="$(grep -m1 -oE '\*\*Parent Epic:\*\*[[:space:]]+[A-Za-z0-9._-]+' "$ACTIVE_FEATURE_DIR/feature.md" 2>/dev/null \
      | sed -E 's/^\*\*Parent Epic:\*\*[[:space:]]+//' || true)"
  fi
  OUTPUT="FEATURE ${FEATURE_SLUG}"
  [ -n "$PARENT_EPIC_SLUG" ] && OUTPUT="${OUTPUT} | epic: ${PARENT_EPIC_SLUG}"
  printf '%s' "$OUTPUT"
  exit 0
fi

ACTIVE_EPIC_DIR="$(resolve_active_dir epics)"
if [ -n "$ACTIVE_EPIC_DIR" ]; then
  EPIC_SLUG="${ACTIVE_EPIC_DIR#epics/}"
  printf 'EPIC %s' "$EPIC_SLUG"
  exit 0
fi

idle

# Validated 2026-05-28 — Phase 12 implementation loop. Touched by Phase 12: PO-flow fallback chain (FEATURE / EPIC) + `resolve_active_dir` helper + `.active` override at every altitude; story rendering + back-ref reader preserved from Phase 7.
# <!-- Managed by Shamt — do not edit. Regenerate from shamt-core/host/templates/claude/statusline.sh. -->
