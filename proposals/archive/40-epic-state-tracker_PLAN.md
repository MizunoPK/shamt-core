# Implementation Plan: 40-epic-state-tracker

**Proposal:** proposals/40-epic-state-tracker.md
**Created:** 2026-06-18
**File operations:** 11 (CREATE: 4, EDIT: 7, DELETE: 0, MOVE: 0)

## Pre-execution checklist
- [ ] On a clean working tree (or working in a worktree dedicated to this proposal).
- [ ] `proposals/40-epic-state-tracker.md` validation footer present (`Validated 2026-06-18 — 2 rounds, 1 adversarial sub-agent confirmed`).
- [ ] Branch created by `/f3-implement-update`: `proposal/40-epic-state-tracker` from the base branch, immediately before the canonical edits. (Authoring/validation/planning happen on the base branch; the architect/builder path's executor creates this branch when it runs this pre-execution checklist at Phase 4.)

## Files manifest

| # | Path | Operation | Sibling / template (if any) |
|---|------|-----------|------------------------------|
| 1 | `templates/epic_status.template.md` | CREATE | sibling shape: `templates/epic.template.md` (HTML-comment provenance banner + section skeleton) |
| 2 | `reference/epic_status_board.md` | CREATE | sibling shape: `reference/audit_dimensions.md` (title + "Extends …" pointer + Purpose + sections) |
| 3 | `templates/SHAMT_RULES.template.md` | EDIT | — (§PO-tree resolution) |
| 4 | `host/templates/claude/commands/po-status.md` | CREATE | sibling shape: `host/templates/claude/commands/pe2-decompose.md` (front-matter + Purpose + Usage/Arguments/Prerequisites + Step-by-step + Exit criteria + managed footer) |
| 5 | `host/templates/claude/skills/po-status/SKILL.md` | CREATE | sibling shape: `host/templates/claude/skills/pe2-decompose/SKILL.md` (pointer-form `## Protocol`) |
| 6 | `host/templates/claude/commands/pe2-decompose.md` | EDIT | — |
| 7 | `host/templates/claude/commands/pf2-decompose.md` | EDIT | — |
| 8 | `host/templates/claude/commands/ps1-define.md` | EDIT | — |
| 9 | `host/templates/claude/commands/e4-execute-plan.md` | EDIT | — |
| 10 | `host/templates/claude/commands/e8-finalize-story.md` | EDIT | — |
| 11 | `README.md` | EDIT | — |

> **Note on the four states (proposal Resolved Q4) — used verbatim across Steps 1, 2, 4, 6–10:**
> New (stub/defined, no `Validated` footer) → Validated (footer present) → Building (Engineer-flow artifacts present, not yet finalized) → Released (`**Status: Done**`).
> **Feature-state precedence (proposal Resolved Q5):** any child story Building/Released → **Building**; all stories Released (and ≥1 exists) → **Released**; else if `feature.md` carries a `Validated` footer → **Validated**; else → **New**.

---

## Step-by-step

### Step 1 — CREATE the per-epic STATUS.md template

**Operation:** CREATE
**File:** `templates/epic_status.template.md`
**Sibling shape:** mirrors `templates/epic.template.md` — leading HTML-comment provenance line, then the skeleton body.
**Initial content (write the file exactly as below):**
```markdown
<!-- Per-epic state rollup. Lives at epics/{ID}-{slug}-{brief}/STATUS.md. GENERATED — do not hand-edit; run /po-status {epic-slug} to refresh. A derived VIEW of the artifacts' own on-disk state signals (NOT an authoritative source). See reference/epic_status_board.md for the derivation contract. -->
# STATUS: {epic-slug}

**Generated:** {YYYY-MM-DD} by /po-status — **do not hand-edit.** This is a derived rollup, re-computed from each artifact's on-disk state. Re-run `/po-status {epic-slug}` to refresh; never patch a single cell.

**States:** New (defined, no `Validated` footer) · Validated (footer present) · Building (Engineer-flow artifacts present, not finalized) · Released (`**Status: Done**`).

| Feature / Story | State |
|-----------------|-------|
| `{feature-slug}` | {New \| Validated \| Building \| Released} |
| &nbsp;&nbsp;↳ `{story-slug}` | {New \| Validated \| Building \| Released} |

<!-- One row per feature (rolled up from its child stories per reference/epic_status_board.md), each followed by its nested child-story rows. Whole table re-derived on every refresh. -->
```
**Verification:**
- `test -f templates/epic_status.template.md` succeeds.
- `grep -F 'GENERATED — do not hand-edit' templates/epic_status.template.md` returns one match.
- `grep -F 'reference/epic_status_board.md' templates/epic_status.template.md` returns one match.

### Step 2 — CREATE the state-derivation reference contract

**Operation:** CREATE
**File:** `reference/epic_status_board.md`
**Sibling shape:** mirrors `reference/audit_dimensions.md` — `# Title`, a bold "extends/companion" pointer line, a `**Purpose:**` line, then `---` and sections.
**Initial content (write the file exactly as below):**
```markdown
# Epic Status Board — State-Derivation Contract

**Companion to the `/po-status` command — read [`host/templates/claude/commands/po-status.md`](../host/templates/claude/commands/po-status.md) first.** Referenced from the rules file §PO-tree resolution (the one-line pointer there; full detail lives here to respect the D12 size budget).

**Purpose:** Define, authoritatively, how each epic's per-feature/per-story `STATUS.md` rollup is **derived** from the artifacts' own on-disk signals — for stories and for features — plus the refresh semantics and `STATUS.md`'s place in the PO tree. This is the single source of truth the `/po-status` command and the five auto-refresh hooks compute against.

---

## What STATUS.md is (and is not)

`STATUS.md` is a **derived rollup** — a re-computable VIEW of state the artifacts already carry, written at `epics/{ID}-{slug}-{brief}/STATUS.md`. It is **never** an authoritative source and is **never** hand-edited: the per-artifact signals (footers, Engineer-flow artifacts, `**Status: Done**`) stay authoritative, and `STATUS.md` is recomputed from them. This keeps the framework disk-authoritative and drift-free by construction — re-running `/po-status` always reproduces truth.

**Hard rule — whole-table re-derivation.** Every refresh (the `/po-status` command and every auto-refresh hook) **re-derives the entire table from disk**. A refresh must never patch a single cell or row in place — patching re-opens the very mirror-drift class the derived model closes. The template's "GENERATED — do not hand-edit" banner states this for the reader; this contract states it for the implementer.

It is distinct from the **work-item tracker** profile concept in `reference/trackers/` (the external ADO/GitHub/local *source* of ticket content). `STATUS.md` is a local derived rollup, not a tracker.

## The four states

A work item is in exactly one of four states, in lifecycle order:

1. **New** — the artifact exists (a stub from decomposition, or defined) but carries **no** `Validated …` footer.
2. **Validated** — the artifact carries a `Validated …` footer.
3. **Building** — Engineer-flow artifacts are present under the story folder (e.g. `spec.md`, `implementation_plan.md`) and the story is **not** yet finalized.
4. **Released** — the story's `ticket.md` carries `**Status: Done**` (written by `/e8-finalize-story`).

## Story state derivation

For a story folder (`epics/{epic-folder}/features/{feature-folder}/stories/{ID}-{slug}-{brief}/`), in precedence order (first match wins):

1. `ticket.md` contains `**Status: Done**` → **Released**.
2. An Engineer-flow artifact exists under the story folder (`spec.md` or `implementation_plan.md`, including `_vN`/`_phase_*` variants) → **Building**.
3. `ticket.md` carries a `Validated …` footer → **Validated**.
4. Otherwise → **New**.

## Feature state derivation (rollup of child stories)

For a feature row, aggregate its child stories with this precedence (first match wins):

1. Any child story is **Building** or **Released** → **Building**.
2. All child stories are **Released** (and ≥1 story exists) → **Released**.
3. Else if `feature.md` carries a `Validated …` footer → **Validated**.
4. Else → **New**.

## Refresh semantics

`STATUS.md` is refreshed two ways, both of which **re-derive the whole table from disk** (never patch a cell):

- **On demand** — `/po-status {epic-slug}` regenerates the epic's `STATUS.md` from the current subtree.
- **Auto-refresh hooks** — five transition commands re-derive the parent epic's `STATUS.md` after their own work, so the rollup stays live: `/pe2-decompose` (new features → New), `/pf2-decompose` (new stories → New), `/ps1-define` (story → Validated), `/e4-execute-plan` (story → Building), `/e8-finalize-story` (story → Released; feature rollup recomputed).

## Place in the PO tree

`STATUS.md` lives at the epic-folder root alongside `epic.md`: `epics/{ID}-{slug}-{brief}/STATUS.md`. It is generated lazily — an epic gains a `STATUS.md` the first time `/po-status` (or a hooked command) runs in its subtree; existing epics are not back-filled automatically.
```
**Verification:**
- `test -f reference/epic_status_board.md` succeeds.
- `grep -F 'whole-table re-derivation' reference/epic_status_board.md` returns one match.
- `grep -F 'not a tracker' reference/epic_status_board.md` returns one match.
- `grep -F 'Feature state derivation' reference/epic_status_board.md` returns one match (the Q5 precedence block is present).

### Step 3 — EDIT §PO-tree resolution: add STATUS.md to the layout + a pointer to the reference

**Operation:** EDIT
**File:** `templates/SHAMT_RULES.template.md`
**Edit 3a — add `STATUS.md` to the epic-folder layout block.**
**Locate:**
```
epics/{ID}-{epic-slug}-{brief}/
  epic.md
  features/{ID}-{feature-slug}-{brief}/
```
**Replace:**
```
epics/{ID}-{epic-slug}-{brief}/
  epic.md
  STATUS.md          # derived per-feature/per-story state rollup (regen via /po-status; never hand-edited)
  features/{ID}-{feature-slug}-{brief}/
```
**Edit 3b — add a one-line pointer to the reference doc.** Append a sentence to the end of the §PO-tree resolution paragraph that ends with `… its project root holds only `CLAUDE.md` + `.claude/`.`
**Locate:**
```
A child writes work-tree artifacts only under `.shamt-core/`; its project root holds only `CLAUDE.md` + `.claude/`.
```
**Replace:**
```
A child writes work-tree artifacts only under `.shamt-core/`; its project root holds only `CLAUDE.md` + `.claude/`. **Epic state rollup.** Each epic folder also carries a generated `STATUS.md` — a **derived** per-feature/per-story state rollup (New / Validated / Building / Released), re-computed from on-disk signals by `/po-status {epic-slug}` and the transition commands; never hand-edited. Derivation contract: [`reference/epic_status_board.md`](../reference/epic_status_board.md).
```
**Verification:**
- `grep -F 'STATUS.md          # derived per-feature' templates/SHAMT_RULES.template.md` returns one match.
- `grep -F 'reference/epic_status_board.md' templates/SHAMT_RULES.template.md` returns one match.

### Step 4 — CREATE the /po-status command

**Operation:** CREATE
**File:** `host/templates/claude/commands/po-status.md`
**Sibling shape:** mirrors `host/templates/claude/commands/pe2-decompose.md` — YAML front-matter (`description:`), `# /po-status`, `**Purpose:**`, `## Usage`, `## Arguments`, `## Prerequisites`, `## Step-by-step`, `## Exit criteria`, `## Notes`, then the managed-by-Shamt HTML footer (note: command bodies live two dirs below `templates/` and `reference/`, so relative links use `../../../../`).
**Initial content (write the file exactly as below):**
```markdown
---
description: Regenerate an epic's STATUS.md — a derived per-feature/per-story state rollup (New / Validated / Building / Released) re-computed from on-disk signals; the single regenerate entry point
---

# /po-status

**Purpose:** (Re)derive the per-epic `STATUS.md` state rollup from the epic's on-disk subtree. `STATUS.md` is a **derived VIEW**, not an authoritative source — this command recomputes the whole table from each artifact's own state signals, so re-running it always yields truth. The state-derivation rules are the contract in [`reference/epic_status_board.md`](../../../../reference/epic_status_board.md); this command applies them.

## Usage

```
/po-status {epic-slug}
```

## Arguments

- `{epic-slug}` (required) — epic ticket ID (`T{N}`) or slug. Resolves to exactly one epic folder per the **Epic** rule in [`SHAMT_RULES.template.md`](../../../../templates/SHAMT_RULES.template.md#po-tree-resolution) §PO-tree resolution (tree-wide glob + legacy-flat fallback); halt on zero or multiple matches.

## Prerequisites

- The resolved epic folder exists and contains `epic.md`. If not, halt and report.

## Step-by-step

### Step 1 — Resolve the epic folder

Resolve `{epic-slug}` to its epic folder per §PO-tree resolution (work-root-relative — `.shamt-core/` in a child). `epics/{epic-folder}/` below denotes the resolved folder.

### Step 2 — Re-derive the whole table from disk

Walk the epic's subtree and compute every row from on-disk signals per [`reference/epic_status_board.md`](../../../../reference/epic_status_board.md):

1. For each feature under `epics/{epic-folder}/features/`, and for each story under that feature's `stories/`, compute the **story state** by the story-derivation precedence (Released if `ticket.md` has `**Status: Done**`; else Building if an Engineer-flow artifact — `spec.md` / `implementation_plan.md` incl. `_vN`/`_phase_*` — exists; else Validated if `ticket.md` carries a `Validated …` footer; else New).
2. Compute each **feature state** by the feature-rollup precedence (any child Building/Released → Building; all children Released and ≥1 exists → Released; else `feature.md` `Validated` footer → Validated; else New).
3. **Re-derive the entire table** — never patch a single cell. This whole-table recomputation is the hard rule (see the reference doc) that keeps the rollup drift-free.

### Step 3 — Write STATUS.md

Write (overwriting) `epics/{epic-folder}/STATUS.md` from [`templates/epic_status.template.md`](../../../../templates/epic_status.template.md): the provenance banner, today's date, the states legend, and one row per feature (each followed by its nested child-story rows).

### Step 4 — Exit

Report the path written and a one-line state tally, e.g. `STATUS.md refreshed: N features, M stories.`

## Exit criteria

- `epics/{epic-folder}/STATUS.md` exists, regenerated wholesale (no cell patched), with one row per feature and nested rows per story, each carrying a derived state.

## Notes

- **Derived, never hand-authored.** `STATUS.md` mirrors no state of its own — it is recomputed from the artifacts. This is the deliberate anti-mirror-drift design (proposal `epic-state-tracker`).
- **Not a tracker.** `STATUS.md` (a local state rollup) is distinct from the **work-item tracker** profile (`reference/trackers/`, the external ticket-content source).
- **Fresh-agent runnable** per Principle 1: the slug resolves the folder; all state lives on disk.

<!-- Managed by Shamt — do not edit. Regenerate from shamt-core/host/templates/claude/commands/po-status.md. -->
```
**Verification:**
- `test -f host/templates/claude/commands/po-status.md` succeeds.
- `grep -F '# /po-status' host/templates/claude/commands/po-status.md` returns one match.
- `grep -F 'Managed by Shamt' host/templates/claude/commands/po-status.md` returns one match.
- `grep -F 'reference/epic_status_board.md' host/templates/claude/commands/po-status.md` returns matches (the command cites the contract).

### Step 5 — CREATE the /po-status skill mirror (pointer form)

**Operation:** CREATE
**File:** `host/templates/claude/skills/po-status/SKILL.md`
**Sibling shape:** mirrors `host/templates/claude/skills/pe2-decompose/SKILL.md` — YAML front-matter (`name`, `description`, `triggers`), `## Overview`, `## Protocol` (the **canonical pointer form** — a single sentence pointing at the command body, never a step paraphrase, per the D2 Command→Skill rule), and the managed footer. (Skill bodies live one dir deeper than command bodies, so cross-tree relative links use `../../../../../`.)
**Initial content (write the file exactly as below):**
```markdown
---
name: po-status
description: >
  Regenerate an epic's STATUS.md — a derived per-feature/per-story state
  rollup (New / Validated / Building / Released) re-computed from each
  artifact's on-disk signals, never hand-edited. STATUS.md is a VIEW, not an
  authoritative source: re-running always yields truth, so it is drift-free by
  construction. Distinct from the work-item tracker profile (the external
  ticket-content source). Invoke when the user wants to refresh the epic
  status, see the state of every feature / story under an epic, regenerate
  STATUS.md, or get a board-style rollup of an epic's progress.
triggers:
  - "refresh the status for {epic-slug}"
  - "regenerate STATUS.md"
  - "epic status rollup"
  - "state of every story under this epic"
  - "po-status {epic-slug}"
  - "show the epic status board"
---

## Overview

Mirrors the `/po-status {epic-slug}` slash command. Same canonical body, two host wirings.

## Protocol

Follow the canonical `/po-status` command body verbatim — see [`commands/po-status.md`](../../commands/po-status.md).

## Key distinction

- **Derived rollup, not a tracker.** `STATUS.md` is a re-computed VIEW of state the artifacts already carry (the anti-mirror-drift design); it is **not** the external work-item **tracker** profile (`reference/trackers/`). Every refresh re-derives the whole table from disk — never patch a single cell.

## Recommended model

Cheap (Haiku) — mechanical disk walk + table regeneration, no design judgment. See [`reference/model_selection.md`](../../../../../reference/model_selection.md).

## Exit criteria

`epics/{epic-folder}/STATUS.md` regenerated wholesale from on-disk signals, one row per feature with nested story rows, each carrying a derived New / Validated / Building / Released state.

<!-- Managed by Shamt — do not edit. Regenerate from shamt-core/host/templates/claude/skills/po-status/SKILL.md. -->
```
**Verification:**
- `test -f host/templates/claude/skills/po-status/SKILL.md` succeeds.
- `grep -F 'Follow the canonical `/po-status` command body verbatim' host/templates/claude/skills/po-status/SKILL.md` returns one match (pointer form, not a step paraphrase).
- `grep -F 'Managed by Shamt' host/templates/claude/skills/po-status/SKILL.md` returns one match.

### Step 6 — EDIT /pe2-decompose: refresh epic STATUS.md after writing feature stubs (new features → New)

**Operation:** EDIT
**File:** `host/templates/claude/commands/pe2-decompose.md`
**Insert a new step between Step 9 and Step 10.** Insert immediately before the `### Step 10 — Exit gate` line.
**Locate:**
```
### Step 10 — Exit gate

Verify before exiting:
```
**Replace:**
```
### Step 9b — Refresh the epic STATUS.md

After writing the feature stubs and updating the parent epic, **re-derive the epic's `STATUS.md` from disk** per [`commands/po-status.md`](po-status.md) — every new feature appears as `New` (no `Validated` footer yet). Re-derive the **whole table** (never patch a cell); the rollup is a derived VIEW per [`reference/epic_status_board.md`](../../../../reference/epic_status_board.md).

### Step 10 — Exit gate

Verify before exiting:
```
**Verification:**
- `grep -F '### Step 9b — Refresh the epic STATUS.md' host/templates/claude/commands/pe2-decompose.md` returns one match.
- `grep -F 'commands/po-status.md' host/templates/claude/commands/pe2-decompose.md` returns one match.

### Step 7 — EDIT /pf2-decompose: refresh parent epic STATUS.md after writing story stubs (new stories → New)

**Operation:** EDIT
**File:** `host/templates/claude/commands/pf2-decompose.md`
**Insert a new step between Step 9 and Step 10.** Insert immediately before the `### Step 10 — Exit gate` line.
**Locate:**
```
### Step 10 — Exit gate

Verify before exiting:
```
**Replace:**
```
### Step 9b — Refresh the parent epic STATUS.md

After writing the story stubs and updating the parent feature, **re-derive the parent epic's `STATUS.md` from disk** per [`commands/po-status.md`](po-status.md) (resolve the epic from the feature's folder path) — every new story appears as `New`. Re-derive the **whole table** (never patch a cell); the rollup is a derived VIEW per [`reference/epic_status_board.md`](../../../../reference/epic_status_board.md).

### Step 10 — Exit gate

Verify before exiting:
```
**Verification:**
- `grep -F '### Step 9b — Refresh the parent epic STATUS.md' host/templates/claude/commands/pf2-decompose.md` returns one match.
- `grep -F 'commands/po-status.md' host/templates/claude/commands/pf2-decompose.md` returns one match.

### Step 8 — EDIT /ps1-define: refresh epic STATUS.md after stamping the Validated footer (story → Validated)

**Operation:** EDIT
**File:** `host/templates/claude/commands/ps1-define.md`
**Insert a new step between Step 7 and Step 8.** Insert immediately before the `### Step 8 — Exit` line.
**Locate:**
```
### Step 8 — Exit

On successful inline validation (footer stamped), suggest the next command:
```
**Replace:**
```
### Step 7b — Refresh the epic STATUS.md

After the inline validation loop stamps the `Validated …` footer (Step 7), **re-derive the parent epic's `STATUS.md` from disk** per [`commands/po-status.md`](po-status.md) (resolve the epic from the story's folder path) — this story now shows as `Validated`. Re-derive the **whole table** (never patch a cell); the rollup is a derived VIEW per [`reference/epic_status_board.md`](../../../../reference/epic_status_board.md). In parent-slug batch mode, refresh once per child after that child's footer is stamped.

### Step 8 — Exit

On successful inline validation (footer stamped), suggest the next command:
```
**Verification:**
- `grep -F '### Step 7b — Refresh the epic STATUS.md' host/templates/claude/commands/ps1-define.md` returns one match.
- `grep -F 'commands/po-status.md' host/templates/claude/commands/ps1-define.md` returns one match.

### Step 9 — EDIT /e4-execute-plan: refresh epic STATUS.md on Build entry (story → Building)

**Operation:** EDIT
**File:** `host/templates/claude/commands/e4-execute-plan.md`
**Two edits — the command has two disjoint Build-entry flows (`## Standard build` and `## Quick build (direct execution)`) selected by the spec's `Path:` header; a story enters Build through exactly one of them, so the refresh must be placed on BOTH or it silently lags for the other path (proposal Risk "Touch-point sprawl" — an omitted hook lags that transition).**

**Edit 9a — Standard build entry.** Append a sub-item to Standard build Step 1's (Plan preflight) numbered list.
**Locate:**
```
3. For phase-decomposed plans (per the single-session sizing constraint in [`SHAMT_RULES.template.md`](../../../../templates/SHAMT_RULES.template.md#principle-1-phase-per-command--slug-resumability) Principle 1), hand off **one phase at a time in deploy order**. Do not hand off `implementation_plan_phase_2.md` until phase 1 has reported `All steps completed. Verification passed.`.
```
**Replace:**
```
3. For phase-decomposed plans (per the single-session sizing constraint in [`SHAMT_RULES.template.md`](../../../../templates/SHAMT_RULES.template.md#principle-1-phase-per-command--slug-resumability) Principle 1), hand off **one phase at a time in deploy order**. Do not hand off `implementation_plan_phase_2.md` until phase 1 has reported `All steps completed. Verification passed.`.
4. **Refresh the epic STATUS.md.** On Build entry, **re-derive the parent epic's `STATUS.md` from disk** per [`commands/po-status.md`](po-status.md) (resolve the epic from the story's folder path) — this story now shows as `Building`. Re-derive the **whole table** (never patch a cell); the rollup is a derived VIEW per [`reference/epic_status_board.md`](../../../../reference/epic_status_board.md).
```

**Edit 9b — Quick build entry.** Insert a refresh sub-item into the Quick build numbered list, immediately after its step 1 (resolve the spec path), as step `1b` (mirrors the plan's `9b`/`7b`/`5c` insert convention — no renumber of the Quick-build list).
**Locate:**
```
1. Apply the active-artifact pointer; resolve the spec path.
```
**Replace:**
```
1. Apply the active-artifact pointer; resolve the spec path.
1b. **Refresh the epic STATUS.md.** On Build entry, **re-derive the parent epic's `STATUS.md` from disk** per [`commands/po-status.md`](po-status.md) (resolve the epic from the story's folder path) — this story now shows as `Building`. Re-derive the **whole table** (never patch a cell); the rollup is a derived VIEW per [`reference/epic_status_board.md`](../../../../reference/epic_status_board.md).
```
**Verification:**
- `grep -F '4. **Refresh the epic STATUS.md.**' host/templates/claude/commands/e4-execute-plan.md` returns one match (Standard build entry).
- `grep -F '1b. **Refresh the epic STATUS.md.**' host/templates/claude/commands/e4-execute-plan.md` returns one match (Quick build entry).
- `grep -c -F 'commands/po-status.md' host/templates/claude/commands/e4-execute-plan.md` returns 2 (both build entries cite the command).

### Step 10 — EDIT /e8-finalize-story: refresh epic STATUS.md after writing **Status: Done** (story → Released; recompute feature rollup)

**Operation:** EDIT
**File:** `host/templates/claude/commands/e8-finalize-story.md`
**Insert a new step between Step 5b and Step 6.** Insert immediately before the `### Step 6 — Exit` line.
**Locate:**
```
### Step 6 — Exit

State the exit clearly:
```
**Replace:**
```
### Step 5c — Refresh the epic STATUS.md

After writing the local `**Status: Done**` marker (Step 5), **re-derive the parent epic's `STATUS.md` from disk** per [`commands/po-status.md`](po-status.md) (resolve the epic from the story's folder path) — this story now shows as `Released`, and the feature rollup is recomputed (a feature becomes `Released` once all its stories are). Re-derive the **whole table** (never patch a cell); the rollup is a derived VIEW per [`reference/epic_status_board.md`](../../../../reference/epic_status_board.md). For a Tech-Stories story archived in Step 5b, resolve the epic to the standing Tech Stories epic.

### Step 6 — Exit

State the exit clearly:
```
**Verification:**
- `grep -F '### Step 5c — Refresh the epic STATUS.md' host/templates/claude/commands/e8-finalize-story.md` returns one match.
- `grep -F 'commands/po-status.md' host/templates/claude/commands/e8-finalize-story.md` returns one match.

### Step 11 — EDIT README: document STATUS.md + add /po-status to the PO command table

**Operation:** EDIT
**File:** `README.md`
**Edit 11a — add `/po-status` to the PO-flow command table.** Add a row immediately after the `/ps1-define` row.
**Locate:**
```
| `/ps1-define {slug}` | Story stage-1 define (flesh-out **+ inline Pattern-1 validation** → engineer-ready ticket; a **parent feature slug** defines all its stories) | shipped |
```
**Replace:**
```
| `/ps1-define {slug}` | Story stage-1 define (flesh-out **+ inline Pattern-1 validation** → engineer-ready ticket; a **parent feature slug** defines all its stories) | shipped |
| `/po-status {epic-slug}` | Regenerate the epic's derived `STATUS.md` state rollup (New / Validated / Building / Released) from on-disk signals | shipped |
```
**Edit 11b — document `STATUS.md` under §"Hierarchy + folder layout".** Add `STATUS.md` to the layout diagram next to `epic.md`.
**Locate:**
```
    ├── {ID}-{epic-slug}-{brief}/
    │   ├── epic.md
    │   └── features/                            # features nest under their epic
```
**Replace:**
```
    ├── {ID}-{epic-slug}-{brief}/
    │   ├── epic.md
    │   ├── STATUS.md                            # derived state rollup (regen via /po-status; never hand-edited)
    │   └── features/                            # features nest under their epic
```
**Edit 11c — add a one-line prose note after the layout's trailing paragraph.** Append a sentence to the paragraph that ends with `… new work is written nested.`
**Locate:**
```
Pre-existing flat layouts resolve via the legacy fallback — new work is written nested.
```
**Replace:**
```
Pre-existing flat layouts resolve via the legacy fallback — new work is written nested. Each epic folder also carries a generated **`STATUS.md`** — a **derived** per-feature/per-story state rollup (New / Validated / Building / Released) re-computed from on-disk signals by `/po-status {epic-slug}` and the transition commands (`/pe2`, `/pf2`, `/ps1`, `/e4`, `/e8`); never hand-edited. It is a local state rollup, **not** the external work-item tracker. Derivation contract: `templates/SHAMT_RULES.template.md` §PO-tree resolution → `reference/epic_status_board.md`.
```
**Verification:**
- `grep -F '| `/po-status {epic-slug}` |' README.md` returns one match.
- `grep -F 'STATUS.md                            # derived state rollup' README.md` returns one match.
- `grep -F 'not** the external work-item tracker' README.md` returns one match.

---

## Verification (post-execution, whole plan)

<!-- Whole-plan / cross-phase invariants — run by the architect at /f3-implement-update post-build (Step 3), never by the builder. -->

- [ ] Every row in the Proposed Changes table (1–11) has a corresponding step (Steps 1–11 map 1:1 to rows 1–11).
- [ ] Every CREATE file exists and matches the named sibling shape: `templates/epic_status.template.md` (vs `templates/epic.template.md`), `reference/epic_status_board.md` (vs `reference/audit_dimensions.md`), `host/templates/claude/commands/po-status.md` (vs `pe2-decompose.md`), `host/templates/claude/skills/po-status/SKILL.md` (vs `skills/pe2-decompose/SKILL.md`).
- [ ] No edits landed in generated `.claude/` paths: `git diff --name-only <base>..HEAD | grep -E '(^|/)\.claude/'` returns zero lines.
- [ ] `grep -rn "Managed by Shamt" host/templates/claude/` returns its prior footer count **+2** (one new command + one new skill; no other generated files leaked in).
- [ ] The new `SKILL.md` `## Protocol` is the pointer form, not a step paraphrase: `grep -F 'Follow the canonical `/po-status` command body verbatim' host/templates/claude/skills/po-status/SKILL.md` returns one match, and the skill body carries no numbered step list paraphrasing the command (D2 Command→Skill rule).
- [ ] Terminology guard (proposal Validation Considerations): no canonical prose calls the new rollup a "tracker". Run `grep -rniE 'STATUS\.md[^\n]*tracker|tracker[^\n]*STATUS\.md' templates/ reference/ host/templates/claude/ README.md` and confirm every hit is an explicit *distinction* ("not a tracker" / "distinct from the … tracker"), never a misnomer.
- [ ] Cross-doc agreement on the state set + derivation: the four states (New/Validated/Building/Released) and the feature-rollup precedence (Q5) read identically across `templates/SHAMT_RULES.template.md` §PO-tree pointer, `reference/epic_status_board.md`, `templates/epic_status.template.md`, and `host/templates/claude/commands/po-status.md`.
- [ ] All five auto-refresh hooks landed: `grep -rl 'commands/po-status.md' host/templates/claude/commands/{pe2-decompose,pf2-decompose,ps1-define,e4-execute-plan,e8-finalize-story}.md` returns all five files.
- [ ] Markdown / relative-link targets in edited and created files still resolve — in particular the `../../../../reference/epic_status_board.md` (command), `../reference/epic_status_board.md` (rules), `../../../../../reference/model_selection.md` (skill), and `po-status.md` (sibling command) links resolve to real files.

## Notes

- **Ordering.** Steps 1–2 (CREATE template + reference) and Step 3 (rules pointer) establish the contract the command and hooks cite, so they come first; Step 4 (command) before Step 5 (skill, which points at the command) and before Steps 6–10 (hooks, which cite the command). Step 11 (README) last. The builder should execute in numeric order; no step depends on a later step.
- **CREATE content is authoritative.** The full initial content for Steps 1, 2, 4, 5 is supplied verbatim above — derived from the proposal's Resolved Questions (Q1 derived-rollup model, Q3 naming/anti-tracker, Q4 four states, Q5 feature precedence). The builder writes the blocks as given; no design judgment.
- **No `.claude/` edits.** Regen (Phase 5, `/f4-regen-framework`) propagates the new command + skill into `.claude/`. The plan touches only canonical sources.
- **Story-altitude sections omitted (per `/f2` command body).** This framework-altitude plan carries no `## Review Prevention Gate Mapping` and no `## CODING_STANDARDS Compliance` mapping; `plan-executor` treats both as N/A.
- **Lazy generation, no back-fill.** Existing epics gain a `STATUS.md` the first time `/po-status` (or a hooked command) runs in their subtree; this plan introduces no migration step (matches proposal Risks "Child-project compatibility").
- **Re-baseline.** If Phase 4 reports a plan defect, patch the plan, re-run `/validate-artifact proposals/40-epic-state-tracker_PLAN.md`, then re-invoke `/f3-implement-update`.

---
Validated 2026-06-18 — 2 rounds, 1 adversarial sub-agent confirmed
