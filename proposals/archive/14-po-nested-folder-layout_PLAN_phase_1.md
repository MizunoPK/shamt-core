# Implementation Plan — Phase 1 (Foundation): po-nested-folder-layout (#14)

**Index:** [`14-po-nested-folder-layout_PLAN.md`](14-po-nested-folder-layout_PLAN.md) · **Rows:** 1–4 · **Deploy order:** FIRST (defines §PO-tree resolution C1 + active-pointer C2 + back-ref drop C3 that Phases 2–4 reference).

> Canonical-only. No `.claude/` edits. Execute steps in order; each has a verification.

---

## Step 1 — `templates/SHAMT_RULES.template.md`: add §PO-tree resolution, nest the layout, reword the standalone statement (row 1)

### 1a — Reword the "standalone stories" sentence (drop the top-level-orphan claim)

**LOCATE** (exact, in the paragraph at the PO-flow intro):
```
The PO flow exists for initiatives large enough to warrant top-down decomposition; standalone stories with no parent epic/feature are first-class and run the Engineer flow directly.
```
**REPLACE WITH:**
```
The PO flow exists for initiatives large enough to warrant top-down decomposition. There are no top-level orphans: every feature nests under an epic and every story under a feature (see §PO-tree resolution). One-off / standalone work (bugs, quick wins, tech stories) lives under the standing **Tech Stories** epic and runs the Engineer flow from there.
```
**VERIFY:** `grep -c "no top-level orphans" templates/SHAMT_RULES.template.md` returns 1; the phrase "run the Engineer flow directly" is gone (`grep -c "run the Engineer flow directly" …` returns 0).

### 1b — Add the `### §PO-tree resolution` subsection

**LOCATE** (anchor — the end of the `### Finalize phase (terminal)` subsection added by #13; the `/p5-finalize-epic` bullet ends with):
```
`epics/archive/` is excluded from active-epic status-line resolution.
```
**INSERT IMMEDIATELY AFTER that line** (new blank line + subsection):
```
### §PO-tree resolution

The PO hierarchy nests: features under their epic, stories under their feature.

​```
epics/{ID}-{epic-slug}-{brief}/
  epic.md
  features/{ID}-{feature-slug}-{brief}/
    feature.md
    stories/{ID}-{story-slug}-{brief}/
      ticket.md, spec.md, implementation_plan.md, feedback/, raw/, ...
​```

Slug-first commands resolve a folder by a **tree-wide glob with a legacy-flat fallback** (slugs are globally unique, so the `{slug}-*` tail is unambiguous; exactly one match — halt on zero or multiple):

- **Epic** (top-level): `epics/{ID}-*/` · `epics/{slug}-*/` · `epics/*-{slug}-*/`.
- **Feature**: `epics/*/features/{ID}-*/` · `epics/*/features/{slug}-*/` · `epics/*/features/*-{slug}-*/`; legacy fallback `features/{slug}-*/`.
- **Story**: `epics/*/features/*/stories/{ID}-*/` · `…/stories/{slug}-*/` · `…/stories/*-{slug}-*/`; legacy fallback `stories/{slug}-*/`.

New work is **written nested**; pre-existing flat folders stay and resolve via the fallback (no migration). Parentage is encoded by the path — there are **no `**Parent Epic:**` / `**Parent Feature:**` back-ref headers**. Throughout command / skill / template / reference bodies, `epics/{slug}/`, `features/{slug}/`, and `stories/{slug}/` denote **the resolved folder** (located via the globs above; leaf still `…-{brief}/`) — path-relative shorthands, not literal top-level paths.

**Active-item pointers.** The status line resolves the active epic / feature / story from root-level pointer files in the project work tree — `.shamt-state/active-epic`, `.shamt-state/active-feature`, `.shamt-state/active-story` — each holding the active item's full resolved nested path (parentage derived by walking up that path). The `p*` start/decompose commands and `/e1-start-story` write/refresh the matching pointer when they create or advance an item. Pointers live outside `.shamt-core/` so `import-shamt` never clobbers them.
```
> NOTE TO EXECUTOR: the inserted text contains **one fenced code block** (the layout diagram) — its opening and closing delimiters are shown above as `​```` with a zero-width character, used only to keep *this plan file's* own fences balanced. Write them as plain triple-backticks (```` ``` ````) in the rules file. No other fences are introduced.

**VERIFY:** `grep -c "§PO-tree resolution" templates/SHAMT_RULES.template.md` returns ≥ 2 (the section heading + the 1a cross-reference); `grep -c "\.shamt-state/active-story" templates/SHAMT_RULES.template.md` returns 1.

---

## Step 2 — `README.md`: nest the hierarchy block, remove the back-ref section, rewrite the status-line section (row 2)

### 2a — Replace the flat hierarchy diagram with the nested tree

**LOCATE** the fenced layout block under `#### Hierarchy + folder layout` (the block beginning `<child-project>/` and ending at the `feedback/, ...` line + closing fence; it currently shows top-level `epics/` with an `archive/` child, `features/`, `stories/`). **REPLACE the whole fenced block** with:
```
<child-project>/
└── epics/                                       # epics are top-level; globally unique slugs
    ├── {ID}-{epic-slug}-{brief}/
    │   ├── epic.md
    │   └── features/                            # features nest under their epic
    │       └── {ID}-{feature-slug}-{brief}/
    │           ├── feature.md
    │           └── stories/                     # stories nest under their feature
    │               └── {ID}-{story-slug}-{brief}/
    │                   ├── ticket.md            # no back-ref headers — parentage is the path
    │                   ├── raw/                 # tracker payloads
    │                   ├── spec.md, implementation_plan.md, ...
    │                   └── feedback/, ...
    └── archive/{ID}-{epic-slug}-{brief}/        # finalized epics (/p5-finalize-epic); excluded from active-epic resolution
```
Then **REPLACE** the paragraph immediately under the block:
**LOCATE:**
```
Epic and feature folders contain **only the main artifact** — no `raw/`, no `feedback/`, no nested per-story content. Per-story artifacts stay under their own story folder. Slugs are **globally unique at each altitude** (flat layout); collisions across `epics/`, `features/`, `stories/` are surfaced at write time by every command.
```
**REPLACE WITH:**
```
Epic and feature folders carry their own artifact (`epic.md` / `feature.md`) plus their nested children. Slugs are **globally unique at each altitude**; the global uniqueness is what lets the `{slug}-*` tail resolve unambiguously by tree-wide glob (see `templates/SHAMT_RULES.template.md` §PO-tree resolution). Pre-existing flat layouts resolve via the legacy fallback — new work is written nested.
```
**VERIFY:** the README hierarchy block contains `features/` indented under an epic folder (`grep -A12 "Hierarchy + folder layout" README.md | grep -c "features nest under their epic"` returns 1); the phrase "flat layout" no longer appears in this paragraph.

### 2b — Remove the back-ref-headers section

**LOCATE** the `#### Back-ref headers and the story handoff` heading and its entire body (the "Linking is plain-markdown header lines…" intro + the `epic.md` / `feature.md` / `ticket.md` bullets) **down to but not including** the next `####` heading (`#### Individually-testable rubric`). **DELETE** that whole section (heading + body).
**REPLACE WITH** a single short subsection in its place:
```
#### Parentage is the path

Linking is encoded by the folder path — `feature.md` lives inside its epic, `ticket.md` inside its feature. There are no `**Parent Epic:**` / `**Parent Feature:**` back-ref headers and no sidecar file; `/e1-start-story` derives parentage by walking up the resolved path (see §PO-tree resolution). One-off / parentless work lives under the standing **Tech Stories** epic.
```
**VERIFY:** `grep -c "Back-ref headers and the story handoff" README.md` returns 0; `grep -c "Parentage is the path" README.md` returns 1.

### 2c — Rewrite the Status-line PO-modes resolution note

**LOCATE:**
```
"Active" at every altitude resolves the same way: `{altitude}/.active` (single-line override pinning a folder) if present, else most-recently-modified subdirectory. See the [Status-line registration](#status-line-registration) table below for the full layout.
```
**REPLACE WITH:**
```
"Active" at every altitude resolves from a root-level pointer file in the project work tree — `.shamt-state/active-epic`, `.shamt-state/active-feature`, `.shamt-state/active-story` — each holding the active item's full resolved nested path; the `p*` / `e1` commands write them as work advances. The `feat:` / `epic:` segments are derived by walking up the active-story pointer's path (not from back-ref headers). See the [Status-line registration](#status-line-registration) table below.
```
Also **LOCATE** the story-line description and drop its back-ref phrasing:
```
1. **Active story** → `STORY {slug} | P{N} {phase} | feat: {feature-slug} | epic: {epic-slug}` (the `feat:` / `epic:` segments come from the active `ticket.md`'s back-ref headers — omitted when absent).
```
**REPLACE WITH:**
```
1. **Active story** → `STORY {slug} | P{N} {phase} | feat: {feature-slug} | epic: {epic-slug}` (the `feat:` / `epic:` segments are derived from the active-story pointer's path — omitted for a story directly under the Tech Stories epic with no distinct feature).
```
**VERIFY:** `grep -c "{altitude}/.active" README.md` returns 0; `grep -c ".shamt-state/active-story" README.md` returns 1.

---

## Step 3 — `host/templates/claude/statusline.sh`: pointer-file resolution + path-derived parentage (row 3 — statusline part of #14)

> This replaces the `resolve_active_dir` flat-scan model and the back-ref greps with pointer-file reads. The Finalize render branch + `epics/archive/` exclusion added by #13 are **preserved**.
>
> **Transient-state note (expected, not a defect):** between this phase and Phases 2–3 (which add the pointer *writes* to the `p*` / `e1` commands), no `.shamt-state/active-*` file exists yet, so `resolve_active_dir` returns empty and the status line shows `Shamt | idle`. This is graceful degradation — the new reader simply finds no pointer until a command writes one. The whole plan lands as one branch (regen + archive happen only after all phases), so end users never see the intermediate state.

### 3a — Replace `resolve_active_dir` with a pointer reader

**LOCATE** the entire `resolve_active_dir()` function body (from `resolve_active_dir() {` through its closing `}`). **REPLACE the function** with:
```
# Read the active {epic|feature|story} from its root-level pointer file
# (.shamt-state/active-<altitude>), which holds the full resolved nested path.
# Replaces the old flat {parent}/.active + most-recently-modified scan: under the
# nested layout there is no flat top-level dir to scan. archive/ never appears in
# a pointer (finalized epics are not active).
resolve_active_dir() {
  local altitude="$1"            # epic | feature | story
  local ptr=".shamt-state/active-${altitude}"
  [ -f "$ptr" ] || return 0
  local dir
  dir="$(head -n 1 "$ptr" 2>/dev/null | tr -d '[:space:]')"
  [ -n "$dir" ] && [ -d "$dir" ] && printf '%s' "$dir"
}
```

### 3b — Update the three resolution call sites + slug extraction

**LOCATE:** `ACTIVE_STORY_DIR="$(resolve_active_dir stories)"` → **REPLACE:** `ACTIVE_STORY_DIR="$(resolve_active_dir story)"`
**LOCATE:** `ACTIVE_FEATURE_DIR="$(resolve_active_dir features)"` → **REPLACE:** `ACTIVE_FEATURE_DIR="$(resolve_active_dir feature)"`
**LOCATE:** `ACTIVE_EPIC_DIR="$(resolve_active_dir epics)"` → **REPLACE:** `ACTIVE_EPIC_DIR="$(resolve_active_dir epic)"`

The pointer now holds a full nested path, so the `${VAR#prefix}` slug extractions must take the basename's slug. **LOCATE:** `SLUG="${ACTIVE_STORY_DIR#stories/}"` → **REPLACE:** `SLUG="$(basename "$ACTIVE_STORY_DIR")"`. **LOCATE:** `FEATURE_SLUG="${ACTIVE_FEATURE_DIR#features/}"` → **REPLACE:** `FEATURE_SLUG="$(basename "$ACTIVE_FEATURE_DIR")"`. **LOCATE:** `EPIC_SLUG="${ACTIVE_EPIC_DIR#epics/}"` → **REPLACE:** `EPIC_SLUG="$(basename "$ACTIVE_EPIC_DIR")"`.

### 3c — Derive story-line `feat:` / `epic:` from the pointer path, not back-ref greps

**LOCATE** the story-side back-ref reader block (the `# Parent feature / epic from ticket.md (PO-flow back-refs).` comment through the two `EPIC_SLUG="$(grep -m1 -oE '\*\*Parent Epic:\*\*…` assignments and the closing `fi`). **REPLACE** the block with path-walk derivation:
```
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
```

### 3d — Derive the feature-line parent epic from the pointer path

**LOCATE** from the `PARENT_EPIC_SLUG=""` initializer line **through** the following `if [ -f "$ACTIVE_FEATURE_DIR/feature.md" ]; then` block (containing the `PARENT_EPIC_SLUG="$(grep -m1 -oE '\*\*Parent Epic:\*\*…` assignment) to its closing `fi` — i.e. include the pre-existing `PARENT_EPIC_SLUG=""` so it is not left duplicated. **REPLACE the whole span** with:
```
  PARENT_EPIC_SLUG=""
  case "$ACTIVE_FEATURE_DIR" in
    epics/*/features/*) PARENT_EPIC_SLUG="$(basename "$(dirname "$(dirname "$ACTIVE_FEATURE_DIR")")")" ;;
  esac
```

### 3e — Update the two inline back-ref doc comments (exact)

**LOCATE:** `#      story's ticket.md does not carry the corresponding back-ref headers.` → **REPLACE WITH** (exact): `#      the active-story pointer path has no parent feature/epic segment.`
**LOCATE:** `#      (no **Parent Epic:** header in feature.md).` → **REPLACE WITH** (exact): `#      (the active-feature pointer path has no parent epic segment).`

### 3f — Update the file-header "Active resolution" comment block (exact)

The file-level header documents the OLD resolution model and goes stale after 3a. **LOCATE** the block — the **7 comment lines** from `# Active resolution for each altitude (story / feature / epic):` through `#      advances through phases in normal use.` (the intro line + items `a.` and `b.`, three lines each). **REPLACE the whole 7-line block** (with the 6-line replacement below — a block replace need not preserve line count):
```
# Active resolution for each altitude (story / feature / epic):
#   Read the root-level pointer file in the project work tree —
#   .shamt-state/active-{epic,feature,story} — each holding the active item's
#   full resolved nested path (epics/<e>/features/<f>/stories/<s>/). The p*/e1
#   commands write these as work advances. Parentage (feat:/epic:) is derived by
#   walking up the active-story pointer path, not from back-ref headers.
```
**VERIFY (3a–3f):** `bash -n host/templates/claude/statusline.sh` exits 0; `grep -c "Parent Epic" host/templates/claude/statusline.sh` returns 0; `grep -c "{parent-dir}/.active" host/templates/claude/statusline.sh` returns 0; `grep -c ".shamt-state/active-" host/templates/claude/statusline.sh` returns ≥ 3.

---

## Step 4 — `reference/review_categories.md`: annotate the story-mode path as resolved-relative (row 4)

**LOCATE:**
```
If issues are found, the reviewer should create a durable review artifact at `stories/{slug}/feedback/review_v1.md` following the standard template and categories.
```
**REPLACE WITH:**
```
If issues are found, the reviewer should create a durable review artifact at `stories/{slug}/feedback/review_v1.md` (the resolved story folder, located per `templates/SHAMT_RULES.template.md` §PO-tree resolution — nested under `epics/.../features/...`) following the standard template and categories.
```
**VERIFY:** `grep -c "§PO-tree resolution" reference/review_categories.md` returns 1.

---

## Phase 1 verification (all steps)

- [ ] `bash -n host/templates/claude/statusline.sh` exits 0; no `Parent Epic:` / `Parent Feature:` greps remain; 3 `.shamt-state/active-*` reads present; Finalize render branch + `epics/archive/` exclusion (from #13) intact.
- [ ] Rules carry a `### §PO-tree resolution` section + the reworded standalone statement; README hierarchy is nested, the back-ref section is replaced by "Parentage is the path", and the status-line note reads from `.shamt-state/` pointers.
- [ ] `review_categories.md` annotates its story path as resolved-relative.
- [ ] No `.claude/` file edited.

Report `All steps completed. Verification passed.` then halt for the orchestrator to start Phase 2.

---
Validated 2026-06-11 — 1 round, 1 adversarial sub-agent confirmed
