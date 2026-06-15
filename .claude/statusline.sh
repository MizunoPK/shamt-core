#!/usr/bin/env bash
# statusline.sh — Shamt Claude Code status-line renderer.
#
# Output (priority order — first match wins):
#   1. Active story:
#        STORY {slug} | P{N} {phase-name} | feat: {feature-slug} | epic: {epic-slug}
#      The `| feat: …` / `| epic: …` segments are omitted when the active
#      the active-story pointer path has no parent feature/epic segment.
#   2. Active feature (no active story):
#        FEATURE {feature-slug} | epic: {parent-epic-slug}
#      The `| epic: …` segment is omitted when the active feature is standalone
#      (the active-feature pointer path has no parent epic segment).
#   3. Active epic (no active story, no active feature):
#        EPIC {epic-slug}
#   4. Idle:
#        Shamt | idle
#
# Active resolution for each altitude (story / feature / epic):
#   Read the pointer file at {work-root}/shamt-state/active-{epic,feature,story}
#   (work root = .shamt-core/ in a child, repo root on master/self-host) — each
#   holding the active item's work-root-relative nested path
#   (epics/<e>/features/<f>/stories/<s>/). The p*/e1
#   commands write these as work advances. Parentage (feat:/epic:) is derived by
#   walking up the active-story pointer path, not from back-ref headers.
#
# Cheap by design: only file reads and globs — no git, no network.
# Registered in .claude/settings.json under "statusLine".

# Intentionally no `set -e`: a status-line renderer must always exit 0 with
# *some* output. Critical reads use `|| true` for graceful degradation.

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"
cd "$PROJECT_DIR" 2>/dev/null || { printf 'Shamt | idle'; exit 0; }

idle() { printf 'Shamt | idle'; exit 0; }

# ---- Numbering scheme (Quick path = 7 phases, Standard path = 8 phases) -----
#
# Testing is a REQUIRED phase (Test) on every story past Build. The phase count is
# determined by PATH, not a config flag:
#   Standard: Intake(1) Spec(2) Plan(3) Build(4) Test(5) Review(6) Polish(7) Finalize(8)
#   Quick   : Intake(1) Spec(2)         Build(3) Test(4) Review(5) Polish(6) Finalize(7)
#
# Standard adds Phase 3 (Plan); Quick has no Plan. Detect Standard by the presence
# of an implementation plan in the resolved story folder (`has_any_artifact
# implementation_plan`); otherwise Quick. Default to Quick so projects without a
# plan artifact get the correct numbering shown by default.

# Phase numbering is determined by PATH, not a config flag. The path flag
# (STANDARD_PATH) is computed inside the story-rendering block below, where the
# `has_any_artifact` helper that detects the implementation plan is in scope.

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

# Read the active {epic|feature|story} from its pointer file at
# {work-root}/shamt-state/active-<altitude>, which holds the work-root-relative
# nested path. The work root is .shamt-core/ in a child, the repo root on
# master/self-host. archive/ never appears in a pointer (finalized epics are not
# active).
resolve_active_dir() {
  local altitude="$1"            # epic | feature | story
  # Work root: .shamt-core/ in a child, repo root on master/self-host.
  local wr="."; [ -d .shamt-core ] && wr=".shamt-core"
  local ptr="${wr}/shamt-state/active-${altitude}"
  [ -f "$ptr" ] || return 0
  local dir
  dir="$(head -n 1 "$ptr" 2>/dev/null | tr -d '[:space:]')"
  # Pointer content is work-root-relative; resolve it under the work root.
  [ -n "$dir" ] && dir="${wr}/${dir}"
  [ -n "$dir" ] && [ -d "$dir" ] && printf '%s' "$dir"
}

# ---- Pick the active story --------------------------------------------------

ACTIVE_STORY_DIR="$(resolve_active_dir story)"
SLUG=""
if [ -n "$ACTIVE_STORY_DIR" ]; then
  SLUG="$(basename "$ACTIVE_STORY_DIR")"
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

  # Path detection: Standard iff an implementation plan exists in this story folder
  # (Standard adds Phase 3 Plan → 8 phases; Quick has no Plan → 7).
  STANDARD_PATH=0
  if has_any_artifact implementation_plan; then STANDARD_PATH=1; fi

  if [ -f "$ACTIVE_STORY_DIR/ticket.md" ] && grep -qE '\*\*Status:.*Done' "$ACTIVE_STORY_DIR/ticket.md" 2>/dev/null; then
    # Finalize is terminal: /e8-finalize-story writes **Status: Done** into
    # ticket.md (profile-independent signal). Checked first — it outranks every
    # earlier-phase artifact a finalized story still carries on disk.
    PHASE_NAME=Finalize
    PHASE_NUM=$([ "$STANDARD_PATH" -eq 1 ] && echo 8 || echo 7)
  elif [ -f "$ACTIVE_STORY_DIR/feedback/addressed_feedback.md" ]; then
    PHASE_NAME=Polish
    PHASE_NUM=$([ "$STANDARD_PATH" -eq 1 ] && echo 7 || echo 6)
  elif compgen -G "$ACTIVE_STORY_DIR/feedback/review_v*.md" >/dev/null 2>&1; then
    PHASE_NAME=Review
    PHASE_NUM=$([ "$STANDARD_PATH" -eq 1 ] && echo 6 || echo 5)
  elif has_any_artifact agent_test_session || has_any_artifact testing_plan; then
    # Test is a REQUIRED phase on every story past Build. The agent-as-user run
    # log (agent_test_session.md) signals it always; testing_plan.md is a
    # secondary automated signal. Numbered 5 on Standard, 4 on Quick.
    PHASE_NAME=Test
    PHASE_NUM=$([ "$STANDARD_PATH" -eq 1 ] && echo 5 || echo 4)
  elif has_any_artifact implementation_plan; then
    PHASE_NUM=3; PHASE_NAME=Plan
  elif has_any_artifact spec; then
    PHASE_NUM=2; PHASE_NAME=Spec
  elif [ -f "$ACTIVE_STORY_DIR/ticket.md" ]; then
    PHASE_NUM=1; PHASE_NAME=Intake
  fi

  if [ -n "$PHASE_NAME" ]; then
    # Parent feature / epic derived from the active-story pointer's nested path:
    #   epics/<epic>/features/<feature>/stories/<story>/  → walk up two levels.
    FEATURE_SLUG=""
    EPIC_SLUG=""
    case "$ACTIVE_STORY_DIR" in
      */features/*/stories/*)
        FEATURE_SLUG="$(basename "$(dirname "$(dirname "$ACTIVE_STORY_DIR")")")"
        EPIC_SLUG="$(basename "$(dirname "$(dirname "$(dirname "$(dirname "$ACTIVE_STORY_DIR")")")")")"
        ;;
    esac

    OUTPUT="STORY ${SLUG} | P${PHASE_NUM} ${PHASE_NAME}"
    [ -n "$FEATURE_SLUG" ] && OUTPUT="${OUTPUT} | feat: ${FEATURE_SLUG}"
    [ -n "$EPIC_SLUG" ]    && OUTPUT="${OUTPUT} | epic: ${EPIC_SLUG}"
    printf '%s' "$OUTPUT"
    exit 0
  fi
fi

# ---- PO-flow fallback: feature, then epic, then idle ------------------------

ACTIVE_FEATURE_DIR="$(resolve_active_dir feature)"
if [ -n "$ACTIVE_FEATURE_DIR" ]; then
  FEATURE_SLUG="$(basename "$ACTIVE_FEATURE_DIR")"
  PARENT_EPIC_SLUG=""
  case "$ACTIVE_FEATURE_DIR" in
    epics/*/features/*) PARENT_EPIC_SLUG="$(basename "$(dirname "$(dirname "$ACTIVE_FEATURE_DIR")")")" ;;
  esac
  OUTPUT="FEATURE ${FEATURE_SLUG}"
  [ -n "$PARENT_EPIC_SLUG" ] && OUTPUT="${OUTPUT} | epic: ${PARENT_EPIC_SLUG}"
  printf '%s' "$OUTPUT"
  exit 0
fi

ACTIVE_EPIC_DIR="$(resolve_active_dir epic)"
if [ -n "$ACTIVE_EPIC_DIR" ]; then
  EPIC_SLUG="$(basename "$ACTIVE_EPIC_DIR")"
  printf 'EPIC %s' "$EPIC_SLUG"
  exit 0
fi

idle

# Validated 2026-05-28 — Phase 12 implementation loop. Touched by Phase 12: PO-flow fallback chain (FEATURE / EPIC) + `resolve_active_dir` helper + `.active` override at every altitude; story rendering + path-walk parentage preserved from Phase 7.
# <!-- Managed by Shamt — do not edit. Regenerate from shamt-core/host/templates/claude/statusline.sh. -->
